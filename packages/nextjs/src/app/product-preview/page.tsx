"use client";

import { useEffect, useRef, useState } from "react";
import { Button } from "@/components/ui/button";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { Product } from "@/types";
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from "@/components/ui/carousel";
import { useDPPNFTFactory } from "@/hooks/useDPPFactory";
import { useMutation } from "@tanstack/react-query";
export default function ProductPreview() {
  const { push } = useRouter();
  const { createNFT } = useDPPNFTFactory();
  const [product, setProduct] = useState<Product | null>(null);
  const prevRef = useRef<HTMLButtonElement>(null);
  const nextRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const storedProduct = localStorage.getItem("product");
    if (storedProduct) {
      console.log("Stored product:", JSON.parse(storedProduct));
      setProduct(JSON.parse(storedProduct));
    } else {
      toast.error("Please fill the form first, redirecting to form...");
      push("/form");
    }
  }, []);

  const { mutate: tokenise, isPending } = useMutation({
    mutationFn: async () => {
      const productCode = localStorage.getItem("product-code");
      if (!productCode) {
        throw new Error("Product code not found");
      }
      if (!product) {
        throw new Error("Product data missing");
      }
      return createNFT(product, productCode);
    },
    onSuccess: (tx) => {
      console.log("Transaction hash:", tx);
      localStorage.removeItem("product");
      localStorage.removeItem("product-code");
      toast.success("NFT created successfully!");
      push("/");
    },
    onError: (error) => {
      toast.error(error.message ?? "Error tokenising NFT");
    },
  });

  if (!product) return <div className="text-center p-10">Loading...</div>;
  return (
    <div className="min-h-screen flex flex-col justify-between px-6 py-6">
      <h2 className="text-xl font-[cursive] italic text-center mb-4">family</h2>

      <Carousel
        className="mx-auto mb-16 w-4/5"
        opts={{
          align: "start",
          loop: true,
        }}
      >
        <CarouselContent>
          {product.images.map((product, index) => (
            <CarouselItem key={index} className="md:basis-1/2 lg:basis-1/1">
              {/* eslint-disable @next/next/no-img-element */}
              <img
                src={product}
                alt={`Product image ${index + 1}`}
                className="w-full object-fit max-h-[400px] rounded-lg shadow-lg"
              />
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious ref={prevRef} />
        <CarouselNext ref={nextRef} />
      </Carousel>

      <div className="mt-6 text-center">
        <p className="text-sm mt-2 px-2 text-gray-500 font-mono leading-relaxed">
          {product.category} Product
        </p>
        <h1 className="text-3xl font-display font-bold text-gray-800 mb-2">
          {product.title}
        </h1>
        <p className="text-sm mt-2 px-2 text-gray-600 font-mono leading-relaxed">
          {product.description}
        </p>
        <p className="text-sm mt-2 px-2 text-gray-600 font-mono leading-relaxed">
          <span className="font-semibold">Brand:</span> {product.brand}
        </p>
      </div>

      <div className="mt-8">
        <Button
          className="w-full rounded-full py-6 font-mono"
          onClick={() => tokenise()}
          disabled={isPending}
        >
          {isPending ? "Tokenising..." : "Tokenise"}
        </Button>
      </div>
    </div>
  );
}
