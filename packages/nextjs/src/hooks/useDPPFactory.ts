import { toast } from "sonner";
import {
  FACTORY_ABI,
  FACTORY_ABI_OLD,
  useFactoryAddress,
} from "@/constants/factory";
import { NFT_ABI } from "@/constants/dpp";
import { Product } from "@/types";
import { useAccount, useWalletClient } from "wagmi";
import { useReadClient } from "@/lib/appConfig";
import { luksoTestnet } from "viem/chains";

export const useDPPNFTFactory = () => {
  const { data: client } = useWalletClient();
  const readClient = useReadClient();
  const { address: account, chain } = useAccount();

  const factoryAddress = useFactoryAddress();

  const createNFT = async (formData: Product, plainUidCode: string) => {
    if (!client || !account) {
      toast.error("Please connect your Universal Profile wallet.");
      throw new Error("Wallet not connected or account not available.");
    }

    try {
      const { request, result: cloneAddress } =
        await readClient.simulateContract({
          abi: chain?.id === luksoTestnet.id ? FACTORY_ABI_OLD : FACTORY_ABI,
          address: factoryAddress,
          functionName: "createNFT",
          account: account as `0x${string}`,
          chain: client.chain,
          args:
            chain?.id === luksoTestnet.id
              ? [formData.title, formData.title + "_" + plainUidCode, account]
              : [
                  formData.title,
                  formData.title + "_" + plainUidCode,
                  account,
                  "",
                ],
        });
      if (!cloneAddress) {
        toast.error("Failed to simulate NFT creation.");
        return null;
      }

      console.log("clone address", cloneAddress);
      const txHash = await client.writeContract(request);

      // const txHash = await client.writeContract({
      //   abi: FACTORY_ABI,
      //   address: factoryAddress,
      //   functionName: "createNFT",
      //   account: account as `0x${string}`,
      //   chain: client.chain,
      //   args: [
      //     formData.title, // name
      //     "DPP_" + plainUidCode, // symbol (or dynamic)
      //     account,
      //     "",
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
        address: factoryAddress,
        functionName: "getDeployedDPPs",
      });
      return nfts as string[];
    } catch (err) {
      console.error("Error fetching deployed NFTs:", err);
      return [];
    }
  };

  const getNFTMetadata = async (
    nftAddress: `0x${string}`
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
    nftAddress: `0x${string}`
  ): Promise<boolean> => {
    if (!client) return false;
    try {
      const result = await readClient.readContract({
        abi: FACTORY_ABI,
        address: factoryAddress,
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
    connectedWallet: account,
    walletConnected: Boolean(account),
  };
};
