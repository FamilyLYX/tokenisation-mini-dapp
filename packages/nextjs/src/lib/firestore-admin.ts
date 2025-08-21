import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  updateDoc,
  where,
  Timestamp,
  DocumentData,
  QueryDocumentSnapshot,
  getFirestore,
} from "firebase/firestore";

import { getApp } from "firebase/app";

// Types for our data models
export interface SaltData {
  id?: string;
  tokenId: string;
  contractAddress: string;
  salt: string;
  uidHash: string;
  uidCode: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface VaultData {
  id?: string;
  address: string;
  data: string;
  createdAt?: Date;
  updatedAt?: Date;
}

// Helper function to convert Firestore timestamp to Date
const convertTimestamp = (timestamp: any): Date => {
  if (timestamp instanceof Timestamp) {
    return timestamp.toDate();
  }
  return timestamp;
};

// Helper function to convert document data to our interface
const convertSaltDoc = (doc: QueryDocumentSnapshot<DocumentData>): SaltData => {
  const data = doc.data();
  return {
    id: doc.id,
    tokenId: data.tokenId,
    contractAddress: data.contractAddress,
    salt: data.salt,
    uidHash: data.uidHash,
    uidCode: data.uidCode,
    createdAt: convertTimestamp(data.createdAt),
    updatedAt: convertTimestamp(data.updatedAt),
  };
};

const convertVaultDoc = (
  doc: QueryDocumentSnapshot<DocumentData>
): VaultData => {
  const data = doc.data();
  return {
    id: doc.id,
    address: data.address,
    data: data.data,
    createdAt: convertTimestamp(data.createdAt),
    updatedAt: convertTimestamp(data.updatedAt),
  };
};

// Salt operations
export const saltServiceAdmin = {
  // Create a new salt record
  async create(
    data: Omit<SaltData, "id" | "createdAt" | "updatedAt">
  ): Promise<SaltData> {
    const now = new Date();
    const saltData = {
      ...data,
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await addDoc(
      collection(getFirestore(getApp()), "salts"),
      saltData
    );
    return {
      id: docRef.id,
      ...saltData,
    };
  },

  // Get salt by tokenId and contractAddress
  async getByTokenAndContract(
    tokenId: string,
    contractAddress: string
  ): Promise<SaltData | null> {
    const q = query(
      collection(getFirestore(getApp()), "salts"),
      where("tokenId", "==", tokenId),
      where("contractAddress", "==", contractAddress)
    );

    const querySnapshot = await getDocs(q);
    if (querySnapshot.empty) {
      return null;
    }

    return convertSaltDoc(querySnapshot.docs[0]);
  },

  // Get all salts
  async getAll(): Promise<SaltData[]> {
    const q = query(
      collection(getFirestore(getApp()), "salts"),
      orderBy("createdAt", "desc")
    );
    const querySnapshot = await getDocs(q);

    return querySnapshot.docs.map(convertSaltDoc);
  },

  // Update a salt record
  async update(
    id: string,
    data: Partial<Omit<SaltData, "id" | "createdAt">>
  ): Promise<void> {
    const docRef = doc(getFirestore(getApp()), "salts", id);
    await updateDoc(docRef, {
      ...data,
      updatedAt: new Date(),
    });
  },

  // Delete a salt record
  async delete(id: string): Promise<void> {
    const docRef = doc(getFirestore(getApp()), "salts", id);
    await deleteDoc(docRef);
  },
};

// Vault operations
export const vaultServiceAdmin = {
  // Create a new vault record
  async create(
    data: Omit<VaultData, "id" | "createdAt" | "updatedAt">
  ): Promise<VaultData> {
    const now = new Date();
    const vaultData = {
      ...data,
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await addDoc(
      collection(getFirestore(getApp()), "vaults"),
      vaultData
    );
    return {
      id: docRef.id,
      ...vaultData,
    };
  },

  // Get vault by address
  async getByAddress(address: string): Promise<VaultData | null> {
    const q = query(
      collection(getFirestore(getApp()), "vaults"),
      where("address", "==", address)
    );
    const querySnapshot = await getDocs(q);

    if (querySnapshot.empty) {
      return null;
    }

    return convertVaultDoc(querySnapshot.docs[0]);
  },

  // Get vault by ID
  async getById(id: string): Promise<VaultData | null> {
    const docRef = doc(getFirestore(getApp()), "vaults", id);
    const docSnap = await getDoc(docRef);

    if (!docSnap.exists()) {
      return null;
    }

    return convertVaultDoc(docSnap as QueryDocumentSnapshot<DocumentData>);
  },

  // Get all vaults
  async getAll(): Promise<VaultData[]> {
    const q = query(
      collection(getFirestore(getApp()), "vaults"),
      orderBy("createdAt", "desc")
    );
    const querySnapshot = await getDocs(q);

    return querySnapshot.docs.map(convertVaultDoc);
  },

  // Update a vault record
  async update(
    id: string,
    data: Partial<Omit<VaultData, "id" | "createdAt">>
  ): Promise<void> {
    const docRef = doc(getFirestore(getApp()), "vaults", id);
    await updateDoc(docRef, {
      ...data,
      updatedAt: new Date(),
    });
  },

  // Delete a vault record
  async delete(id: string): Promise<void> {
    const docRef = doc(getFirestore(getApp()), "vaults", id);
    await deleteDoc(docRef);
  },
};
