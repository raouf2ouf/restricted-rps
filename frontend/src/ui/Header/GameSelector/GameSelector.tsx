import { IonLabel, IonSelect, IonSelectOption } from "@ionic/react";
import { memo } from "react";

import "./GameSelector.scss";
import { useAppSelector } from "$store/store";
import { selectAllPlayerGames } from "$store/openGames.slice";
import { useAccount } from "wagmi";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";

type Props = {};

const GameSelector: React.FC<Props> = ({}) => {
  const { currentGameAddress, setCurrentGameAddressAndPlayerId } =
    useCurrentGameContext();
  const { address } = useAccount();
  const games = useAppSelector((state) => selectAllPlayerGames(state, address));

  function select({ detail }: any) {
    const gameAddress = detail.value;
    const game = games.find((g) => g.address == gameAddress);
    const playerId = game?.players.findIndex(
      (p) => p.toLowerCase() == address?.toLowerCase()
    );
    setCurrentGameAddressAndPlayerId(gameAddress, playerId!);
  }

  return (
    <div className="game-selector-container">
      <IonLabel>Game ID: </IonLabel>
      <IonSelect
        value={currentGameAddress}
        color="primary"
        onIonChange={select}
      >
        {games &&
          games.map((g) => {
            return (
              <IonSelectOption value={g.address} key={g.id}>
                {g.id}
              </IonSelectOption>
            );
          })}
      </IonSelect>
    </div>
  );
};

export default memo(GameSelector);
