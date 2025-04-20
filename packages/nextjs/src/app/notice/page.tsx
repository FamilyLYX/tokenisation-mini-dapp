"use client";

import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";

export default function ImportantNotice() {
  return (
    <div className="min-h-screen px-6 py-8 flex flex-col justify-between">
      <div className="flex flex-col gap-4">
        <h2 className="text-xl font-[cursive] italic text-center">family</h2>
        <h1 className="text-3xl text-[#FF0000] text-center font-bold">
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
