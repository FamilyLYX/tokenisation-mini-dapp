"use client";

import { Button } from "@/components/ui/button";
import { ArrowLeft, Plus } from "lucide-react";
import { useRouter } from "next/navigation";

export default function ImportantNotice() {
  const router = useRouter();

  return (
    <div className="min-h-screen px-6 py-8 flex flex-col justify-between">
      {/* Header */}
      <div className="flex flex-col gap-4">
        <div className="flex items-center gap-2">
          <button
            onClick={() => router.back()}
            className="w-8 h-8 border rounded-full flex items-center justify-center"
          >
            <ArrowLeft className="w-4 h-4" />
          </button>
        </div>

        <h2 className="text-xl font-[cursive] italic text-center">family</h2>

        <h1 className="text-3xl text-tokenRed text-center font-bold">
          Important Notice
        </h1>

        <div className="bg-white rounded-xl border px-4 py-4 text-sm font-mono leading-relaxed text-gray-700">
          <p>
            To tokenise your physical product, it must have a{" "}
            <strong>Unique Identifier (UID)</strong> embedded on it
          </p>
          <br />
          <ul className="list-disc pl-4">
            <li>
              Embed the 6-digit code we will generate for you on the physical
              product. This should be legible and must permanently stay on the
              physical product
            </li>
          </ul>
        </div>
      </div>

      {/* Generate Button */}
      <div className="mt-8">
        <Button
          variant="outline"
          className="w-full rounded-full border-black text-black text-base py-6 font-mono"
        >
          <Plus className="w-4 h-4 mr-2" /> Generate
        </Button>
      </div>
    </div>
  );
}
