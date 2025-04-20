"use client";

import { useEffect, useState } from "react";
import { Button } from "@/components/ui/button";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { Product } from "@/types";

export default function ProductPreview() {
  const { push } = useRouter();
  const [product, setProduct] = useState<Product | null>(null);
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const storedProduct = localStorage.getItem("product");
    if (storedProduct) {
      setProduct(JSON.parse(storedProduct));
    } else {
      toast.error("Please fill the form first, redirecting to form...");
      push("/form");
    }
  }, []);

  const handleNext = () => {
    if (product) {
      setIndex((index + 1) % product.images.length);
    }
  };

  const handlePrev = () => {
    if (product) {
      setIndex((index - 1 + product.images.length) % product.images.length);
    }
  };

  if (!product) return <div className="text-center p-10">Loading...</div>;

  return (
    <div className="min-h-screen flex flex-col justify-between px-6 py-6">
      <h2 className="text-xl font-[cursive] italic text-center mb-4">family</h2>

      {/* Image Carousel */}
      <div className="relative rounded-2xl overflow-hidden">
        <button
          onClick={handlePrev}
          className="absolute left-2 top-1/2 transform -translate-y-1/2 bg-white/80 p-1 rounded-full"
        >
          <ArrowLeft size={16} />
        </button>
        <button
          onClick={handleNext}
          className="absolute right-2 top-1/2 transform -translate-y-1/2 bg-white/80 p-1 rounded-full"
        >
          <ArrowRight size={16} />
        </button>
      </div>

      <div className="mt-6 text-center">
        <h1 className="text-2xl font-display font-bold">{product.title}</h1>
        <p className="text-sm mt-2 px-2 text-gray-600 font-mono leading-relaxed">
          {product.description}
        </p>
      </div>

      {/* Tokenise Button */}
      <div className="mt-8">
        <Button className="w-full rounded-full py-6 font-mono">Tokenise</Button>
      </div>
    </div>
  );
}
