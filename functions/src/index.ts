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

admin.initializeApp();

const openai = new OpenAI({ apiKey: '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' });

export const translateText = onCall(async (request) => {
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
