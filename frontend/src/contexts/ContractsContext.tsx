import { ReactNode, createContext, useContext, useState } from "react";

type ContractsContextProps = {
  chain: string;
  factoryAddress: "0x${string}";
  collateralUnit: string;
};

const DEFAULT_CHAIN = "FOUNDRY";
const DEFAULT_FACTORY_ADDRESS = import.meta.env[`VITE_FOUNDRY_FACTORY_ADDRESS`];
const DEFAULT_COLLATERAL_UNIT = "ETH";

const ContractsContext = createContext<ContractsContextProps>({
  chain: DEFAULT_CHAIN,
  factoryAddress: DEFAULT_FACTORY_ADDRESS,
  collateralUnit: DEFAULT_COLLATERAL_UNIT,
});

type Props = {
  children: ReactNode;
};

export const ContractsProvider: React.FC<Props> = ({ children }) => {
  const [chain, setChain] = useState<string>(DEFAULT_CHAIN);
  const [collateralUnit, setCollateralUnit] = useState<string>(
    DEFAULT_COLLATERAL_UNIT
  );
  const [factoryAddress, setFactoryAddress] = useState<"0x${string}">(
    DEFAULT_FACTORY_ADDRESS
  );

  return (
    <ContractsContext.Provider
      value={{ chain, factoryAddress, collateralUnit }}
    >
      {children}
    </ContractsContext.Provider>
  );
};

export function useContractsContext() {
  return useContext(ContractsContext);
}
