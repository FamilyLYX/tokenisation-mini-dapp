import { useUpProvider } from "@/components/up-provider";
import { toast } from "sonner";
import { FACTORY_ABI, FACTORY_ADDRESS } from "@/constants/factory";
import { NFT_ABI } from "@/constants/dpp";
import { createPublicClient, http } from "viem";
import { luksoTestnet } from "viem/chains";
import { Product } from "@/types";

const readClient = createPublicClient({
  chain: luksoTestnet,
  transport: http("https://rpc.testnet.lukso.network"),
});

export const useDPPNFTFactory = () => {
  const { client, accounts, walletConnected } = useUpProvider();

  const createNFT = async (formData: Product, plainUidCode: string) => {
    if (!client || !walletConnected || !accounts?.[0]) {
      toast.error("Please connect your Universal Profile wallet.");
      throw new Error("Wallet not connected or account not available.");
    }

    try {
      const { request, result: cloneAddress } =
        await readClient.simulateContract({
          abi: FACTORY_ABI,
          address: FACTORY_ADDRESS,
          functionName: "createNFT",
          account: accounts[0] as `0x${string}`,
          chain: client.chain,
          args: [
            formData.title,
            formData.title + "_" + plainUidCode,
            accounts[0],
          ],
        });
      if (!cloneAddress) {
        toast.error("Failed to simulate NFT creation.");
        return null;
      }
      const txHash = await client.writeContract(request);

      console.log("Expected NFT contract address:", cloneAddress);

      // const tx = await client.writeContract({
      //   abi: FACTORY_ABI,
      //   address: FACTORY_ADDRESS,
      //   functionName: "createNFT",
      //   account: accounts[0] as `0x${string}`,
      //   chain: client.chain,
      //   args: [
      //     formData.title, // name
      //     "DPP_" + plainUidCode, // symbol (or dynamic)
      //     accounts[0],
      //     plainUidCode,
      //     publicJsonMetadata,
      //     encryptedPrivateMetadata,
      //   ],
      // });
      const resultTx = await readClient.waitForTransactionReceipt({
        hash: txHash,
      });
      if (!resultTx || resultTx.status !== "success") {
        console.error("Transaction failed or not mined:", txHash);
        toast.error("NFT creation transaction failed.");
        throw new Error("Transaction failed or not mined: " + txHash);
      }
      toast.success("NFT creation transaction sent!");
      return {
        resultTx,
        hash: txHash,
        dppAddress: cloneAddress as `0x${string}`,
      };
    } catch (err) {
      console.error("Error creating NFT:", err);
      toast.error("Failed to create NFT.");
      throw new Error("Error creating NFT: " + err);
    }
  };

  const getDeployedDPPs = async (): Promise<string[]> => {
    if (!client) return [];
    try {
      const nfts = await readClient.readContract({
        abi: FACTORY_ABI,
        address: FACTORY_ADDRESS,
        functionName: "getDeployedDPPs",
      });
      return nfts as string[];
    } catch (err) {
      console.error("Error fetching deployed NFTs:", err);
      return [];
    }
  };

  const getNFTMetadata = async (
    nftAddress: `0x${string}`,
  ): Promise<Product | null> => {
    if (!client) return null;
    try {
      const publicMetadata = await readClient.readContract({
        abi: NFT_ABI,
        address: nftAddress,
        functionName: "getPublicMetadata",
      });

      return JSON.parse(publicMetadata as string);
    } catch (err) {
      console.error("Error reading NFT metadata:", err);
      return null;
    }
  };

  const isRegisteredNFT = async (
    nftAddress: `0x${string}`,
  ): Promise<boolean> => {
    if (!client) return false;
    try {
      const result = await readClient.readContract({
        abi: FACTORY_ABI,
        address: FACTORY_ADDRESS,
        functionName: "isRegisteredNFT",
        args: [nftAddress],
      });
      return result as boolean;
    } catch (err) {
      console.error("Error checking NFT registration:", err);
      return false;
    }
  };

  return {
    createNFT,
    getDeployedDPPs,
    getNFTMetadata,
    isRegisteredNFT,
    connectedWallet: accounts?.[0],
    walletConnected,
  };
};
