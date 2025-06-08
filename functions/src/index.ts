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


import ffmpeg from 'fluent-ffmpeg';
import ffmpegStatic from 'ffmpeg-static';
import * as os from 'os';
import * as path from 'path';
import * as fs from 'fs';
import FormData from 'form-data';
import axios from 'axios';
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import OpenAI from "openai";
import { TranslationServiceClient } from "@google-cloud/translate"; // Google Cloud Translation Client
import { onObjectFinalized } from 'firebase-functions/storage';
import mime from 'mime-types';
//import { PDFDocument, PDFFont } from 'pdf-lib';
//import fontkit from 'fontkit';

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

const db = admin.firestore();

// Set ffmpeg binary path
ffmpeg.setFfmpegPath(ffmpegStatic!);

export const convertMp4ToMp3 = onObjectFinalized({ region: 'us-west1' }, async (event) => {
  const object = event.data;

  const filePath = object.name;
  const contentType = object.contentType;
  if (!filePath || !filePath.endsWith('.mp4')) {
    console.log('Not an MP4 file. Skipping...');
    return;
  }

  // Log contentType to debug
  console.log('File contentType:', contentType);

  const fileName = path.basename(filePath);
  const fileDir = path.dirname(filePath);
  const baseName = path.basename(fileName, '.mp4');
  const tempInput = path.join(os.tmpdir(), fileName);
  const tempOutput = path.join(os.tmpdir(), `${baseName}.mp3`);
  const outputStoragePath = path.join(fileDir, `${baseName}.mp3`);

  // Get userId from filePath structure: 'uploads/{userId}/{fileName}.mp4'
  const userId = fileDir.split('/')[1];
  const progressRef = db.collection('users').doc(userId).collection('conversions').doc(fileName);

  try {
    const bucket = admin.storage().bucket(object.bucket);

    // Download the video file
    await progressRef.set({ status: 'downloading', progress: 10 });
    await bucket.file(filePath).download({ destination: tempInput });

    // Convert to MP3 with progress
    await new Promise<void>((resolve, reject) => {
      ffmpeg(tempInput)
        .output(tempOutput)
        .on('start', () => {
          console.log('FFmpeg started');
        })
        .on('progress', async (progress) => {
          const percent = Math.floor(progress.percent ?? 50);
          console.log(`Progress: ${percent}%`);
          await progressRef.update({ status: 'converting', progress: percent });
        })
        .on('end', async () => {
          console.log('FFmpeg finished');
          await progressRef.update({ status: 'uploading', progress: 95 });
          resolve();
        })
        .on('error', async (err) => {
          console.error('FFmpeg error:', err);
          await progressRef.update({ status: 'error', error: err.message });
          reject(err);
        })
        .run();
    });

    // Upload to Storage
    await bucket.upload(tempOutput, { destination: outputStoragePath });

    // Finish
    await progressRef.update({
      status: 'done',
      progress: 100,
      outputPath: outputStoragePath,
      finishedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    fs.unlinkSync(tempInput);
    fs.unlinkSync(tempOutput);
  } catch (err: any) {
    console.error('Error in process:', err);
    await progressRef.set({ status: 'error', error: err.message });
  }
});


export const transcribeWhisperOnUpload = onObjectFinalized(
  { region: 'us-west1' },
  async (event) => {
    const file = event.data;
    const filePath = file.name;
    if (!filePath || !filePath.endsWith('.mp3')) {
      console.log('Skipped non-MP3 file:', filePath);
      return;
    }

    const pathParts = filePath.split('/');
    const userId = pathParts[1]; // uploads/{userId}/{filename}.mp3
    const fileName = path.basename(filePath);

    const docRef = admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('transcriptions')
      .doc(fileName);

    const docSnap = await docRef.get();
    if (!docSnap.exists) {
      console.warn(`No Firestore doc found for: ${filePath}`);
      return;
    }

    const data = docSnap.data()!;
    const fromLanguage = data.fromLanguage || 'English';
    const toLanguage = data.toLanguage || 'English';
    const includeSummary = data.summary || false;

    await docRef.update({ status: 'processing', progress: 10 });

    const bucket = admin.storage().bucket(file.bucket);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    await bucket.file(filePath).download({ destination: tempFilePath });

    const fileStream = fs.createReadStream(tempFilePath);
    const formData = new FormData();
    formData.append('file', fileStream, {
      filename: fileName,
      contentType: mime.lookup(fileName) || 'audio/mpeg',
    });
    formData.append('model', 'whisper-1');
    if (fromLanguage) {
      formData.append('language', LANGUAGE_CODE_MAP[fromLanguage] || 'en');
    }

    try {
      const whisperResponse = await axios.post(
        'https://api.openai.com/v1/audio/transcriptions',
        formData,
        {
          headers: {
            ...formData.getHeaders(),
            Authorization: `Bearer ${openai.apiKey}`,
          },
        }
      );

      const transcript = whisperResponse.data.text;
      await docRef.update({ transcript, progress: 60 });
      let translatedText = transcript;
      if (fromLanguage !== toLanguage) {
        const [translation] = await new TranslationServiceClient().translateText({
          parent: `projects/${process.env.GCLOUD_PROJECT}/locations/global`,
          contents: [transcript],
          mimeType: 'text/plain',
          sourceLanguageCode: LANGUAGE_CODE_MAP[fromLanguage],
          targetLanguageCode: LANGUAGE_CODE_MAP[toLanguage],
        });

        translatedText = translation.translations?.[0]?.translatedText || transcript;
        await docRef.update({ translation: translatedText, progress: 80 });
      }

      if (includeSummary) {
        const summaryChat = await openai.chat.completions.create({
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system', content: `Summarize this ${toLanguage}.` },
            { role: 'user', content: translatedText },
          ],
        });

        const summary = summaryChat.choices[0].message?.content;
        await docRef.update({ summary, progress: 95 });
      }

      // Combine the content into plain text
      const content = [
        'Transcription:',
        transcript,
        '',
        'Translation:',
        translatedText,
        '',
        'Summary:',
         includeSummary ? data.summary : '',
      ].join('\n');

      // Save to a local .txt file
      const txtFileName = fileName.replace('.mp3', '.txt');
      const txtTempPath = path.join(os.tmpdir(), txtFileName);
      fs.writeFileSync(txtTempPath, content, 'utf8');

      // Upload to Cloud Storage
      const txtStoragePath = `texts/${userId}/${txtFileName}`;
      await bucket.upload(txtTempPath, {
        destination: txtStoragePath,
        metadata: {
          contentType: 'text/plain; charset=utf-8',
        },
      });

      // Update Firestore
      await docRef.update({
        txtPath: txtStoragePath,
        status: 'done',
        progress: 100,
        finishedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Cleanup
      fs.unlinkSync(txtTempPath);
      fs.unlinkSync(tempFilePath);
    } catch (err: any) {
      console.error('Transcription failed:', err.message);
      await docRef.update({ status: 'error', error: err.message });
    }
  }
);

