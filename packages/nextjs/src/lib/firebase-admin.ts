import { cert, getApps, initializeApp, getApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Initialize Firebase Admin SDK
const apps = getApps();
console.log(
  process.env.FIREBASE_PRIVATE_KEY,
  "process.env.FIREBASE_PRIVATE_KEY",
  process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n")
);
if (!apps.length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY,
    }),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

// Initialize Firestore
export const adminDb = getFirestore(getApp());

export default apps[0];
