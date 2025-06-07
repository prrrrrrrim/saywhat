/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
// Start writing functions
// https://firebase.google.com/docs/functions/typescript

import * as functions from "firebase-functions";
import ffmpeg from "fluent-ffmpeg";
import * as ffmpegInstaller from "@ffmpeg-installer/ffmpeg";
import * as os from "os";
import * as path from "path";
import * as fs from "fs";
import Busboy from "busboy";

import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import OpenAI from "openai";
import { TranslationServiceClient } from "@google-cloud/translate"; // Google Cloud Translation Client


admin.initializeApp();

const LANGUAGE_CODE_MAP: Record<string, string> = {
  English: "en",
  Thai: "th",
  Chinese: "zh",
};

export const translateText = onCall(async (request) => {
  const { text, targetLang, fromLang } = request.data;

  // Map the language names to their codes
  const targetCode = LANGUAGE_CODE_MAP[targetLang];
  const sourceCode = fromLang ? LANGUAGE_CODE_MAP[fromLang] : undefined;

  if (!text || !targetCode) {
    throw new HttpsError("invalid-argument", "Missing or invalid input.");
  }

  try {
    // Create a TranslationServiceClient instance
    const translationClient = new TranslationServiceClient();

    // Call the translateText API
    const [response] = await translationClient.translateText({
      parent: `projects/${process.env.GCLOUD_PROJECT}/locations/global`,
      contents: [text],
      mimeType: "text/plain",
      sourceLanguageCode: sourceCode,
      targetLanguageCode: targetCode,
    });

    // Extract the translation from the response
    const translation = response.translations?.[0]?.translatedText;
    return { translation };
  } catch (error: any) {
    console.error("Translation error:", error);

    if (error.code === 7) {
      throw new HttpsError("permission-denied", "Access denied. Check service account permissions.");
    } else if (error.code === 3) {
      throw new HttpsError("unavailable", "Translation API service is temporarily unavailable.");
    }

    throw new HttpsError("internal", error.message || "Translation failed");
  }
});


const openai = new OpenAI({ apiKey: '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' });

export const summarize = onCall(async (request) => {
  const { text, targetLang, fromLang } = request.data;

  try {
    const chat = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: `You are a professional translator. Translate from ${fromLang} to ${targetLang}.`,
        },
        {
          role: "user",
          content: text,
        },
      ],
    });

    return { translation: chat.choices[0].message?.content };
  } catch (error) {
    if (error === 'insufficient_quota') {
      throw new HttpsError("resource-exhausted", "API quota exceeded. Please check your plan or billing.");
    }
    throw new HttpsError("internal", "An unexpected error occurred.");
  }
});

ffmpeg.setFfmpegPath(ffmpegInstaller.path);

export const convertMp4ToMp3 = functions.https.onRequest((req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  const busboy = Busboy({ headers: req.headers });
  const tmpdir = os.tmpdir();

  let uploadPath = "";
  let outputPath = "";
  let cleanupFiles: string[] = [];

  busboy.on("file", (fieldname, file, info) => {
    const { filename } = info;
    const ext = path.extname(filename);
    if (ext !== ".mp4") {
      res.status(400).send("Only .mp4 files are allowed.");
      file.resume(); // Discard the stream
      return;
    }

    uploadPath = path.join(tmpdir, filename);
    outputPath = uploadPath.replace(".mp4", ".mp3");
    cleanupFiles = [uploadPath, outputPath];

    const writeStream = fs.createWriteStream(uploadPath);

    writeStream.on("error", (err) => {
      console.error("File write error:", err);
      res.status(500).send("Failed to write file");
      cleanupFiles.forEach(file => {
        try { fs.unlinkSync(file); } catch (e) { console.error("Cleanup error:", e); }
      });
    });

    file.pipe(writeStream);

    writeStream.on("finish", () => {
      ffmpeg(uploadPath)
        .format("mp3")
        .output(outputPath)
        .on("end", () => {
          const outputFilename = path.basename(filename, ".mp4") + ".mp3";
          res.setHeader("Content-Type", "audio/mpeg");
          res.setHeader("Content-Disposition", `attachment; filename="${outputFilename}"`);
          
          const readStream = fs.createReadStream(outputPath);
          readStream.pipe(res);

          readStream.on("close", () => {
            cleanupFiles.forEach(file => {
              try { fs.unlinkSync(file); } catch (e) { console.error("Cleanup error:", e); }
            });
          });

          readStream.on("error", (err) => {
            console.error("File read error:", err);
            res.status(500).send("Failed to read converted file");
            cleanupFiles.forEach(file => {
              try { fs.unlinkSync(file); } catch (e) { console.error("Cleanup error:", e); }
            });
          });
        })
        .on("error", (err) => {
          console.error("FFmpeg error:", err);
          res.status(500).send("Conversion failed");
          cleanupFiles.forEach(file => {
            try { fs.unlinkSync(file); } catch (e) { console.error("Cleanup error:", e); }
          });
        })
        .run();
    });
  });

  busboy.on("error", (err) => {
    console.error("Busboy error:", err);
    res.status(500).send("File upload error");
    cleanupFiles.forEach(file => {
      try { fs.unlinkSync(file); } catch (e) { console.error("Cleanup error:", e); }
    });
  });

  req.pipe(busboy);
});