// utils/storeSalt.ts
import { appConfig } from "./appConfig";
import { supabase } from "./initSupabase";

const SALT_DB = appConfig.salt_db; // Use the configured salt database

export async function storeSalt(
  tokenId: string,
  contractAddress: string,
  salt: string,
  uidHash: string,
  productCode: string,
) {
  const { error } = await supabase.from(SALT_DB).insert([
    {
      token_id: tokenId,
      salt,
      contract_address: contractAddress,
      uid_code: productCode,
      hash: uidHash,
    },
  ]);

  if (error) {
    console.error("Error storing salt:", error.message);
    throw error;
  }
}
