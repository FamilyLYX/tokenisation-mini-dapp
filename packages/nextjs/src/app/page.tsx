"use client";
import BlackButton from "@/components/black-button";
import { getAllNFTMetadata } from "@/lib/owner";
import { useQuery } from "@tanstack/react-query";
import { useRouter } from "next/navigation";

export default function Home() {
  const { push } = useRouter();
  const { data: countOfContracts } = useQuery({
    queryKey: ["nftMetadata"],
    queryFn: getAllNFTMetadata,
  });
  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-center px-4 text-center bg-white">
      <div className="mb-4">
        <h2 className="text-xl font-[cursive] italic text-black mb-2">
          family
        </h2>
      </div>

      <span className="mb-4 inline-block bg-gray-200 text-gray-800 text-xs font-medium px-2 py-1 rounded-full">
        Tokenised {countOfContracts ?? 0} products and counting
      </span>
      <div className="mb-4 text-[64px]  leading-tight">
        <h1 className="font-extrabold">
          <span className="text-[#FF0000]">Tokenise</span>{" "}
          <span className="text-[#D2D2D2]">Your</span>
        </h1>
        <h1 className="font-extrabold font-display">Products</h1>
      </div>

      <BlackButton
        onClick={() => {
          push("/individual");
        }}
        className="mt-6 w-60 text-base py-2 rounded-full"
      >
        Enter
      </BlackButton>
    </div>
  );
}
