import { useUpProvider } from "@/components/up-provider";
import { NFT_ABI } from "@/constants/dpp";
import { createPublicClient, http } from "viem";
import { luksoTestnet } from "viem/chains";
const readClient = createPublicClient({
  chain: luksoTestnet,
  transport: http("https://rpc.testnet.lukso.network"),
});
export const useDPP = () => {
  const { client, accounts, walletConnected } = useUpProvider();

  const mintDPP = async ({
    dppAddress,
    plainUidCode,
    publicJsonMetadata,
    salt,
  }: {
    dppAddress: `0x${string}`;
    plainUidCode: string;
    publicJsonMetadata: string;
    salt: string;
  }) => {
    if (!client || !walletConnected || !accounts?.[0]) {
      console.error("Wallet not connected or account not available.");
      return null;
    }
    try {
      // Simulate the mintDPP call
      const result = await readClient.simulateContract({
        abi: NFT_ABI,
        address: dppAddress,
        functionName: "mintDPP",
        account: accounts[0],
        args: [accounts[0], plainUidCode, publicJsonMetadata, salt],
        chain: client.chain,
      });
      console.log("Simulation result:", result);
      if (!result) {
        console.error("Simulation failed, no result returned.");
        return null;
      }

      // If simulation passes, send the actual transaction
      const txHash = await client.writeContract({
        abi: NFT_ABI,
        address: dppAddress,
        functionName: "mintDPP",
        account: accounts[0],
        args: [accounts[0], plainUidCode, publicJsonMetadata,salt],
        chain: client.chain,
      });

      const resultTx = await readClient.waitForTransactionReceipt({
        hash: txHash,
      });
      if (!resultTx || resultTx.status !== "success") {
        console.error("Transaction receipt not found.", txHash);
        return null;
      }
      console.log("Transaction successful:", resultTx);
      return { resultTx };
    } catch (err) {
      console.error("Error minting DPP:", err);
      return null;
    }
  };

  return { mintDPP };
};
