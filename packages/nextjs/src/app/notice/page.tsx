"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Plus } from "lucide-react";
import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
} from "@/components/ui/dialog";
import { useRouter } from "next/navigation";

export default function ImportantNotice() {
  const { push } = useRouter();
  const [code, setCode] = useState("");
  const [open, setOpen] = useState(false);

  const generateCode = () => {
    const newCode = Math.random().toString(36).substring(2, 8).toUpperCase();
    setCode(newCode);
    localStorage.setItem("product-code", newCode);
    setOpen(true);
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(code);
    push("/product-preview");
  };

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
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild>
            <Button
              onClick={generateCode}
              variant="outline"
              className="w-full rounded-full border-black text-black text-base py-6 font-mono"
            >
              <Plus className="w-4 h-4 mr-2" /> Generate
            </Button>
          </DialogTrigger>

          <DialogContent className="max-w-xs bg-white rounded-2xl p-6 text-center">
            <DialogHeader>
              <h2 className="text-2xl font-bold mb-4">6-Digit Code</h2>
            </DialogHeader>
            <div className="flex justify-center gap-3 text-2xl font-mono mb-6">
              {code.split("").map((digit, index) => (
                <span
                  key={index}
                  className="border border-gray-300 p-2 rounded"
                >
                  {digit}
                </span>
              ))}
            </div>
            <Button
              onClick={copyToClipboard}
              className="w-full bg-black text-white rounded-full"
            >
              Proceed
            </Button>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
