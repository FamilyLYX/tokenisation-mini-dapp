"use client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiProvider } from "wagmi";
import { ThemeProvider } from "next-themes";
import { Toaster } from "./ui/sonner";
import { config } from "../lib/wagmi";
import { usePathname, useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { RainbowKitProvider } from "@rainbow-me/rainbowkit";

const TokenisationApp = ({ children }: { children: React.ReactNode }) => {
  const router = useRouter();
  const path = usePathname();

  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem={false}>
      {/* <UpProvider> */}
      <RainbowKitProvider>
        {path !== "/" && (
          <div className="absolute top-4 left-4">
            <button onClick={() => router.back()} className="flex items-center">
              <ArrowLeft className="mr-2" />
              Back
            </button>
          </div>
        )}
        {children}
      </RainbowKitProvider>
      {/* </UpProvider> */}
      <Toaster />
    </ThemeProvider>
  );
};

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
    },
  },
});

export const TokenizationAppWithProviders = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <TokenisationApp>{children}</TokenisationApp>
      </QueryClientProvider>
    </WagmiProvider>
  );
};
