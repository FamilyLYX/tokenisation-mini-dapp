"use client";
import BlackButton from "@/components/black-button";

export default function Individual() {
  return (
    <div className="min-h-screen w-full flex flex-col items-center justify-between px-6 py-8 bg-white text-center">
      {/* Replace with logo*/}
      <h2 className="text-xl font-[cursive] italic text-black mt-2">family</h2>
      {/* Card */}
      <div className="border border-gray-200 rounded-xl p-6 w-full max-w-sm text-center shadow-sm">
        <h1 className="text-3xl font-display font-bold mb-4">Individual</h1>

        {/* Placeholder Image */}
        <div className="flex justify-center mb-6">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="w-24 h-24 text-black"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <path d="M3 3h7v11H3V3zm11 0h7v5h-7V3zm0 7h7v11h-7V10zM3 15h7v5H3v-5z" />
          </svg>
        </div>

        {/* Description */}
        <p className="text-sm font-mono text-black">
          Easily tokenise your physical <br /> product
        </p>
      </div>
      {/* Button */}
      <BlackButton
        onClick={() => {
          // Navigate to next step
        }}
        className="w-full max-w-sm mt-8 text-base py-2 rounded-full"
        withArrow
      >
        Next
      </BlackButton>
    </div>
  );
}
