"use client";
import BlackButton from "@/components/black-button";
import { useRouter } from "next/navigation";
import Image from "next/image";
import tokenise from "../../../public/tokenise.svg";
export default function Individual() {
  const { push } = useRouter();
  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-between px-6 py-8 bg-white text-center">
      <h2 className="text-xl font-[cursive] italic text-black mt-2">family</h2>
      <div className="border border-gray-200 rounded-xl p-6 w-full max-w-sm text-center shadow-sm">
        <h1 className="text-3xl font-display font-bold mb-4">Individual</h1>

        <div className="flex justify-center mb-6">
          <Image
            src={tokenise}
            alt="Individual"
            width={100}
            height={100}
            className="w-24 h-24"
          />
        </div>

        <p className="text-sm font-mono text-black">
          Easily tokenise your physical <br /> product
        </p>
      </div>
      <BlackButton
        onClick={() => {
          push("/form");
        }}
        className="w-full max-w-sm mt-8 text-base py-2 rounded-full"
        withArrow
      >
        Next
      </BlackButton>
    </div>
  );
}
