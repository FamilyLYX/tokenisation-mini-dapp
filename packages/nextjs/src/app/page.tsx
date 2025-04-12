"use client";
import BlackButton from "@/components/black-button";

export default function Home() {
  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-center px-4 text-center bg-white">
      <div className="mb-4">
        <h2 className="text-xl font-[cursive] italic text-black mb-2">
          family
        </h2>
      </div>

      {/* Headline */}
      <div className="mb-4 text-[64px]  leading-tight">
        <h1 className="font-extrabold">
          <span className="text-[#FF0000]">Tokenise</span>{" "}
          <span className="text-[#D2D2D2]">Your</span>
        </h1>
        <h1 className="font-extrabold font-display">Products</h1>
      </div>

      {/* Button */}
      <BlackButton
        onClick={() => {
          window.open("https://app.familylyx.com", "_blank");
        }}
        className="mt-6 w-60 text-base py-2 rounded-full"
      >
        Enter
      </BlackButton>
    </div>
  );
}
