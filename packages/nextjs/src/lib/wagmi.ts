import { createConfig, http } from "wagmi";
import { luksoTestnet, xdcTestnet } from "wagmi/chains";

export const config = createConfig({
  chains: [luksoTestnet, xdcTestnet],
  transports: {
    [luksoTestnet.id]: http(),
    [xdcTestnet.id]: http(),
  },
});

declare module "wagmi" {
  interface Register {
    config: typeof config;
  }
}
