import { ReactNode, createContext, useContext, useState } from "react";

type GamesContextProps = {
  currentGameAddress?: string;
  currentPlayerId?: number;
  setCurrentGameAddressAndPlayerId: (address: string, playerId: number) => void;
};

const CurrentGameContext = createContext<GamesContextProps>({
  setCurrentGameAddressAndPlayerId: () => {},
});

type Props = {
  children: ReactNode;
};

export const CurrentGameProvider: React.FC<Props> = ({ children }) => {
  const [currentGameAddress, setCurrentGameAddress] = useState<string>();
  const [currentPlayerId, setCurrentPlayerId] = useState<number>();

  function setCurrentGameAddressAndPlayerId(address: string, playerId: number) {
    setCurrentGameAddress(address);
    setCurrentPlayerId(playerId);
  }
  return (
    <CurrentGameContext.Provider
      value={{
        currentGameAddress,
        currentPlayerId,
        setCurrentGameAddressAndPlayerId,
      }}
    >
      {children}
    </CurrentGameContext.Provider>
  );
};

export function useCurrentGameContext() {
  return useContext(CurrentGameContext);
}
