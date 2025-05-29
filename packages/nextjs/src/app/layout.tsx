import type React from "react";
import type { Metadata } from "next";
import "./globals.css";
// import { Space_Grotesk } from "next/font/google";
// import localFont from "next/font/local";
import { TokenizationAppWithProviders } from "@/components/template-provider";

export const metadata: Metadata = {
  title: "FamilyLYX: Tokenize your products",
  description:
    "Discover the power of tokenization with FamilyLYX. Transform your products into unique digital assets, enhancing ownership and value.",
};

// const Tusker_Grotesk = localFont({
//   src: [
//     {
//       path: "../../public/fonts/TuskerGrotesk-3600Semibold.ttf",
//       weight: "400",
//       style: "normal",
//     },
//   ],
//   variable: "--font-tusker",
//   display: "swap",
// });

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <TokenizationAppWithProviders>{children}</TokenizationAppWithProviders>
      </body>
    </html>
  );
}
