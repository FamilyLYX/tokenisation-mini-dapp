import { adminDb } from "./firebase-admin";

export interface SaltData {
  tokenId: string;
  contractAddress: string;
  salt: string;
  uidHash: string;
  productCode: string;
}

export async function storeSalt(data: SaltData) {
  // Use Firestore via API
  try {
    const salt = await adminDb.collection("salts").add(data);
    return salt;
  } catch (error) {
    console.error("Error storing salt in Firestore:", error);
    throw error;
  }
}

export async function getSalt(tokenId: string, contractAddress: string) {
  // Use Firestore via API
  try {
    const response = await fetch(
      `/api/salt?tokenId=${encodeURIComponent(
        tokenId
      )}&contractAddress=${encodeURIComponent(contractAddress)}`
    );

    if (!response.ok) {
      if (response.status === 404) {
        return null;
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error("Error fetching salt from Firestore:", error);
    throw error;
  }
}
