import { useUpProvider } from "@/components/up-provider";
import { NFT_ABI } from "@/constants/dpp";

export const useDPP = () => {
  const { client, accounts, walletConnected } = useUpProvider();

  const mintDPP = async ({
    dppAddress,
    plainUidCode,
    publicJsonMetadata,
    encryptedPrivateMetadata,
  }: {
    dppAddress: `0x${string}`;
    plainUidCode: string;
    publicJsonMetadata: string;
    encryptedPrivateMetadata: `0x${string}`;
  }) => {
    if (!client || !walletConnected || !accounts?.[0]) {
      console.error("Wallet not connected or account not available.");
      return null;
    }
    try {
      const txHash = await client.writeContract({
        abi: NFT_ABI,
        address: dppAddress,
        functionName: "mintDPP",
        account: accounts[0],
        args: [accounts[0], plainUidCode, publicJsonMetadata, encryptedPrivateMetadata],
        chain: client.chain,
      });

      return { txHash };
    } catch (err) {
      console.error("Error minting DPP:", err);
      return null;
    }
  };
  return {
    mintDPP,
  };
};
