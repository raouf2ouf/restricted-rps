import { createConfig, http } from "wagmi";
import { foundry, lightlinkPegasus, lightlinkPhoenix } from "wagmi/chains";
import { injected } from "wagmi/connectors";

const wagmiConfig = createConfig({
  chains: [foundry, lightlinkPegasus],
  connectors: [injected()],
  transports: {
    [foundry.id]: http(),
    [lightlinkPegasus.id]: http(),
  },
});

export default wagmiConfig;
