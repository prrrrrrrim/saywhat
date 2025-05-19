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

