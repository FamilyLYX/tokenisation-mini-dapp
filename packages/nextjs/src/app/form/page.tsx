"use client";

import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import BlackButton from "@/components/black-button";
import { Plus } from "lucide-react";
import { useState } from "react";

export default function FormPage() {
  const [, setImages] = useState<string[]>(["/img1.jpg", "/img2.jpg"]);

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      setImages((prev) => [...prev, url]);
    }
  };

  return (
    <div className="min-h-screen w-full px-6 py-8 flex flex-col justify-between">
      {/* Header */}
      <h2 className="text-xl font-[cursive] italic text-center mb-6">family</h2>

      {/* Form */}
      <div className="space-y-4">
        <div>
          <Label className="text-sm font-mono">Product Name</Label>
          <Input placeholder="Name" className="mt-1" />
        </div>

        <div>
          <Label className="text-sm font-mono">Description</Label>
          <Textarea placeholder="Description" className="mt-1" rows={3} />
        </div>

        <div>
          <Label className="text-sm font-mono">Category</Label>
          <Input placeholder="Fashion/Consumer" className="mt-1" />
        </div>

        <div>
          <Label className="text-sm font-mono">Brand/Manufacturer</Label>
          <Input placeholder="Adidas" className="mt-1" />
        </div>

        <div>
          <Label className="text-sm font-mono mb-2 block">Insert Photos</Label>
          <div className="flex items-center gap-2">
            {/* Upload Button */}
            <label
              htmlFor="upload"
              className="w-10 h-10 border rounded-full flex items-center justify-center cursor-pointer"
            >
              <Plus className="w-5 h-5" />
              <input
                id="upload"
                type="file"
                accept="image/*"
                className="hidden"
                onChange={handleImageUpload}
              />
            </label>
          </div>
        </div>
      </div>

      {/* Button */}
      <div className="mt-8">
        <BlackButton withArrow className="w-full rounded-full py-2 text-base">
          Next
        </BlackButton>
      </div>
    </div>
  );
}
