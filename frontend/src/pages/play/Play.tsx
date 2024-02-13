import { IonButton, IonContent, IonLabel, IonPage } from "@ionic/react";
import { memo } from "react";

import "./Play.scss";
import Tooltip from "$ui/components/Tooltip/Tooltip";
import GameDisplay from "./GameDisplay";
import {
  selectAllOtherGames,
  selectAllPlayerGames,
} from "$store/openGames.slice";
import { useAppSelector } from "$store/store";
import { useAccount } from "wagmi";

const PlayPage: React.FC = () => {
  const { address } = useAccount();
  const playerGames = useAppSelector((state) =>
    selectAllPlayerGames(state, address)
  );
  const otherGames = useAppSelector((state) =>
    selectAllOtherGames(state, address)
  );
  return (
    <IonPage>
      <IonContent>
        <div className="play-main-container">
          {!address ? (
            <div className="section">
              <IonLabel>
                <div>Please connect your wallet to see games.</div>
              </IonLabel>
            </div>
          ) : (
            <>
              <div className="section player-games">
                <IonLabel>
                  <div>Your Current Open Games</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {playerGames.map((g) => (
                  <GameDisplay
                    id={g.id}
                    key={g.id}
                    isPlayer
                    playerId={g.players.findIndex(
                      (ad) => ad.toLowerCase() == address?.toLowerCase()
                    )}
                  />
                ))}
              </div>
              <div className="section select-game">
                <IonLabel>
                  <div>Select or Start a Game to Play</div>
                  <Tooltip text=""></Tooltip>
                </IonLabel>
                {otherGames.map((g) => (
                  <GameDisplay id={g.id} key={g.id} />
                ))}

                {/* <IonButton className="rectangle-button" fill="clear">
              <IonLabel>Create Game</IonLabel>
            </IonButton> */}
              </div>
            </>
          )}
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(PlayPage);
