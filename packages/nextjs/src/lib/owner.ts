import { createWalletClient, http, createPublicClient } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { FACTORY_ABI, FACTORY_ADDRESS } from "@/constants/factory";
import { luksoTestnet } from "viem/chains";
import { Product } from "@/types";
import { NFT_ABI } from "@/constants/dpp";
import { fromHex } from "viem/utils";
type createNFTResponse = { hash: string };

if (!process.env.NEXT_PUBLIC_PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY environment variable is not set.");
}

const account = privateKeyToAccount(
  process.env.NEXT_PUBLIC_PRIVATE_KEY as `0x${string}`,
);

// Create the public client for reading from contracts
const readClient = createPublicClient({
  chain: luksoTestnet,
  transport: http(), // Using the same transport for reading
});

const walletClient = createWalletClient({
  account,
  chain: luksoTestnet,
  transport: http(), // Make sure the transport is properly configured for the testnet
});

export async function testCreateNFT(
  formData: Product,
  plainUidCode: string,
): Promise<createNFTResponse> {
  try {
    const publicJsonMetadata = JSON.stringify(formData);
    const encryptedPrivateMetadata = "0x"; // Placeholder for encrypted metadata

    // Make the contract call
    const tx = await walletClient.writeContract({
      abi: FACTORY_ABI,
      address: FACTORY_ADDRESS,
      functionName: "createNFT", // Replace with the correct function name in the factory contract
      args: [
        formData.title, // Name for the NFT
        "DPP" + Date.now().toString(), // Dynamic symbol (if required)
        account.address, // The account address (wallet address)
        plainUidCode, // UID code for the NFT
        publicJsonMetadata, // Public metadata
        encryptedPrivateMetadata, // Encrypted private metadata (if available)
      ],
    });

    // Return the transaction hash
    return { hash: tx }; // tx.hash will give the transaction hash
  } catch (error) {
    console.error("Error resolving createNFT:", error);
    throw error;
  }
}

// Function to fetch metadata of all deployed NFTs
export async function getAllNFTMetadata(): Promise<number> {
  try {
    // 1. Fetch deployed NFTs from the factory contract
    const deployedNFTs = (await readClient.readContract({
      abi: FACTORY_ABI,
      address: FACTORY_ADDRESS,
      functionName: "getDeployedNFTs",
    })) as string[];
    for (const nftAddress of deployedNFTs) {
      // 2. Fetch metadata for each NFT
      const metadata = await readClient.readContract({
        abi: NFT_ABI,
        address: nftAddress as `0x${string}`,
        functionName: "getPublicMetadata",
      });
      const decodedMetadata = JSON.parse(
        fromHex(metadata as `0x${string}`, "string"),
      );
      const owner = await readClient.readContract({
        abi: NFT_ABI,
        address: nftAddress as `0x${string}`,
        functionName: "owner",
      });
      console.log(
        "👤 Owner:",
        owner,
        " of metadata: ",
        decodedMetadata + " uidHash: ",
      );
    }
    return deployedNFTs.length;
  } catch (error) {
    console.error("Error fetching NFT metadata:", error);
    throw error;
  }
}
