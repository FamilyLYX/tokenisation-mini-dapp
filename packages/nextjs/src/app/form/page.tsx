"use client";

import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import BlackButton from "@/components/black-button";
import { Plus } from "lucide-react";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Product } from "@/types";
export default function FormPage() {
  const { push } = useRouter();
  const [formData, setFormData] = useState<Product | null>(() => {
    const savedData = localStorage.getItem("product");
    return savedData
      ? JSON.parse(savedData)
      : {
          title: "",
          description: "",
          category: "",
          brand: "",
          images: ["/img1.jpg", "/img2.jpg"],
        };
  });

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>,
  ) => {
    const { name, value } = e.target;
    const updatedData = { ...formData, [name]: value };
    setFormData(updatedData as Product);
    localStorage.setItem("product", JSON.stringify(updatedData));
  };

  const handleImageUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const url = URL.createObjectURL(file);
      const updatedData = { ...formData, images: [...formData?.images, url] };
      setFormData(updatedData as Product);
      localStorage.setItem("product", JSON.stringify(updatedData));
    }
  };

  return (
    <div className="min-h-screen w-full px-6 py-8 flex flex-col justify-between">
      <h2 className="text-xl font-[cursive] italic text-center mb-6">family</h2>

      <div className="space-y-4">
        <div>
          <Label className="text-sm font-mono">Product Name</Label>
          <Input
            name="title"
            placeholder="Name"
            className="mt-1"
            value={formData?.title}
            onChange={handleInputChange}
          />
        </div>

        <div>
          <Label className="text-sm font-mono">Description</Label>
          <Textarea
            name="description"
            placeholder="Description"
            className="mt-1"
            rows={3}
            value={formData?.description}
            onChange={handleInputChange}
          />
        </div>

        <div>
          <Label className="text-sm font-mono">Category</Label>
          <Input
            name="category"
            placeholder="Fashion/Consumer"
            className="mt-1"
            value={formData?.category}
            onChange={handleInputChange}
          />
        </div>

        <div>
          <Label className="text-sm font-mono">Brand/Manufacturer</Label>
          <Input
            name="brand"
            placeholder="Adidas"
            className="mt-1"
            value={formData?.brand}
            onChange={handleInputChange}
          />
        </div>

        <div>
          <Label className="text-sm font-mono mb-2 block">Insert Photos</Label>
          <div className="flex items-center gap-2">
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

      <div className="mt-8">
        <BlackButton
          withArrow
          className="w-full rounded-full py-2 text-base"
          onClick={() => {
            push("/notice");
          }}
        >
          Next
        </BlackButton>
      </div>
    </div>
  );
}
