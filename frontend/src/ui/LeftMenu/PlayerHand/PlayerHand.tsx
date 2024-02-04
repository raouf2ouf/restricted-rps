import { memo } from "react";

import "./PlayerHand.scss";
import SmallCard from "$ui/components/SmallCard/SmallCard";
import { Card } from "$models/Card";
import SmallStars from "$ui/components/SmallStars/SmallStars";
import Cash from "$ui/components/Cash/Cash";
import { useCurrentGameContext } from "$contexts/CurrentGameContext";
import { useAppSelector } from "$store/store";
import { selectPlayerStateById } from "$store/playersState.slice";
import { buildPlayerStateId } from "$models/PlayerState";
import { useAccount } from "wagmi";
import { IonBackdrop, IonSpinner } from "@ionic/react";
type Props = {
  gameAddress: string;
  playerAddress: string;
};

const PlayerHandContainer: React.FC = () => {
  const { currentGameAddress } = useCurrentGameContext();
  const { address } = useAccount();

  return (
    <>
      {currentGameAddress && address ? (
        <PlayerHand gameAddress={currentGameAddress} playerAddress={address} />
      ) : (
        <div className="player-hand-container off">
          <SmallCard nbr="?" card={Card.ROCK} bg />
          <SmallCard nbr="?" card={Card.PAPER} bg />
          <SmallCard nbr="?" card={Card.SCISSORS} bg />
          <SmallStars nbr={0} expanded={4} direction="column" />
          <Cash amount={0} />
        </div>
      )}
    </>
  );
};

const PlayerHand: React.FC<Props> = memo(({ gameAddress, playerAddress }) => {
  const playerState = useAppSelector((state) =>
    selectPlayerStateById(
      state,
      buildPlayerStateId(gameAddress as string, playerAddress)
    )
  );
  return (
    <div className="player-hand-container onn">
      {!playerState && (
        <div className="loading">
          <IonSpinner name="lines-sharp" color="primary"></IonSpinner>
          <IonBackdrop visible={true} tappable={false}></IonBackdrop>
        </div>
      )}
      <SmallCard
        nbr={
          playerState ? playerState.initialRock! - playerState.nbrRockUsed : 0
        }
        nbrLocked={playerState?.lockedRock}
        card={Card.ROCK}
        bg
      />
      <SmallCard
        nbr={
          playerState ? playerState.initialPaper! - playerState.nbrPaperUsed : 0
        }
        nbrLocked={playerState?.lockedPaper}
        card={Card.PAPER}
        bg
      />
      <SmallCard
        nbr={
          playerState
            ? playerState.initialScissors! - playerState.nbrScissorsUsed
            : 0
        }
        nbrLocked={playerState?.lockedScissors}
        card={Card.SCISSORS}
        bg
      />
      <SmallStars
        nbr={playerState?.nbrStars || 0}
        nbrLocked={playerState?.nbrStarsLocked}
        expanded={4}
        direction="column"
      />
      <Cash amount={0} />
    </div>
  );
});

export default memo(PlayerHandContainer);
