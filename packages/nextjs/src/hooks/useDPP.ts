import { useUpProvider } from "@/components/up-provider";
import { NFT_ABI } from "@/constants/dpp";
import { readClient } from "@/lib/appConfig";

export const useDPP = () => {
  const { client, accounts, walletConnected } = useUpProvider();

  const mintDPP = async ({
    dppAddress,
    publicJsonMetadata,
    uidHash,
  }: {
    dppAddress: `0x${string}`;
    publicJsonMetadata: string;
    uidHash: `0x${string}`; // must be 32 bytes (0x-prefixed)
  }) => {
    if (!client || !walletConnected || !accounts?.[0]) {
      console.error("Wallet not connected or account not available.");
      throw new Error("Wallet not connected or account not available.");
    }

    try {
      // Simulate the call and get a prepared request
      const { request } = await readClient.simulateContract({
        abi: NFT_ABI,
        address: dppAddress,
        functionName: "mintDPP",
        account: accounts[0],
        args: [accounts[0], publicJsonMetadata, uidHash],
        chain: client.chain,
      });

      // Send the actual transaction using the simulated request
      const txHash = await client.writeContract(request);

      // Wait for transaction to be mined
      const resultTx = await readClient.waitForTransactionReceipt({
        hash: txHash,
      });

      if (!resultTx || resultTx.status !== "success") {
        console.error("Transaction failed or not mined:", txHash);
        return null;
      }

      return { resultTx };
    } catch (err) {
      console.error("Error minting DPP:", err);
      throw new Error("Error minting DPP: " + err);
    }
  };

  return { mintDPP };
};
