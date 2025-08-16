// utils/storeSalt.ts
import { storeSalt as storeSaltUtil } from "./database";

export async function storeSalt(
  tokenId: string,
  contractAddress: string,
  salt: string,
  uidHash: string,
  productCode: string
) {
  await storeSaltUtil({
    tokenId,
    contractAddress,
    salt,
    uidHash,
    productCode,
  });
}
