import type React from "react";
import type { Metadata } from "next";
import "./globals.css";
import { Space_Grotesk } from "next/font/google";
import { TokenizationAppWithProviders } from "@/components/template-provider";

const inter = Space_Grotesk({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "FamilyLYX: Tokenize your products",
  description:
    "Discover the power of tokenization with FamilyLYX. Transform your products into unique digital assets, enhancing ownership and value.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <TokenizationAppWithProviders>{children}</TokenizationAppWithProviders>
      </body>
    </html>
  );
}
