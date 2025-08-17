// Database utility that can switch between Supabase and Prisma
import { supabase } from "./initSupabase";
import { prisma } from "./prisma";
import { appConfig } from "./appConfig";

// Configuration to switch between databases
// const USE_SUPABASE =
//   process.env.NEXT_PUBLIC_USE_SUPABASE === "true" || !process.env.DATABASE_URL;
// const SALT_DB = appConfig.salt_db;

const USE_SUPABASE = false;

const SALT_DB = appConfig.salt_db;

export interface SaltData {
  tokenId: string;
  contractAddress: string;
  salt: string;
  uidHash: string;
  productCode: string;
}

export async function storeSalt(data: SaltData) {
  if (USE_SUPABASE) {
    // Use Supabase
    const { error } = await supabase.from(SALT_DB).insert([
      {
        token_id: data.tokenId,
        salt: data.salt,
        contract_address: data.contractAddress,
        uid_code: data.productCode,
        hash: data.uidHash,
      },
    ]);

    if (error) {
      console.error("Error storing salt in Supabase:", error.message);
      throw error;
    }
  } else {
    // Use Prisma
    try {
      await prisma.salt.create({
        data: {
          tokenId: data.tokenId,
          contractAddress: data.contractAddress,
          salt: data.salt,
          uidHash: data.uidHash,
          uidCode: data.productCode,
        },
      });
    } catch (error) {
      console.error("Error storing salt in Prisma:", error);
      throw error;
    }
  }
}

export async function getSalt(tokenId: string, contractAddress: string) {
  if (USE_SUPABASE) {
    // Use Supabase
    const { data, error } = await supabase
      .from(SALT_DB)
      .select("*")
      .eq("token_id", tokenId)
      .eq("contract_address", contractAddress)
      .single();

    if (error) {
      console.error("Error fetching salt from Supabase:", error.message);
      throw error;
    }

    return data;
  } else {
    // Use Prisma
    try {
      return await prisma.salt.findFirst({
        where: {
          tokenId,
          contractAddress,
        },
      });
    } catch (error) {
      console.error("Error fetching salt from Prisma:", error);
      throw error;
    }
  }
}

// Export current database type for debugging
export const currentDatabase = USE_SUPABASE
  ? "Supabase"
  : "PostgreSQL (Prisma)";
