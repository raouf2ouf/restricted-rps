import { ReactNode } from "react";
import { MenuProvider } from "./MenuContext";
import { ContractsProvider } from "./ContractsContext";
import { CurrentGameProvider } from "./CurrentGameContext";

export function Providers(props: { children: ReactNode }) {
  return (
    <MenuProvider>
      <ContractsProvider>
        <CurrentGameProvider>{props.children}</CurrentGameProvider>
      </ContractsProvider>{" "}
    </MenuProvider>
  );
}
