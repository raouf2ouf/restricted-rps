import { memo, useEffect, useState } from "react";

import "./MatchHistory.scss";
import { IonIcon, IonLabel } from "@ionic/react";
import { Match, MatchState } from "$models/Match";
import SmallCard from "../SmallCard/SmallCard";
import SmallStars from "../SmallStars/SmallStars";

type Props = {
  playerId: number;
  match: Match;
};

const MatcheHistory: React.FC<Props> = ({ match, playerId }) => {
  const isPlayer1 = match.player1 == playerId;
  function shortenAddress(addr: any) {
    return addr.slice(0, 7) + "..." + addr.slice(-5);
  }
  return (
    <div className="match-history-container">
      <div className="game-info">
        <div className="game-offer">
          <IonLabel className="label">Game: </IonLabel>
          <IonLabel>{shortenAddress(match.gameAddress)}</IonLabel>
        </div>
        <div className="game-id-container">
          <IonLabel className="label">Match Id: </IonLabel>
          <IonLabel className="game-id">{match.matchId}</IonLabel>
        </div>
      </div>
      <div className="game-details">
        <div className="cards">
          <SmallCard simple card={match.player1Card} />
          <IonLabel>X</IonLabel>
          <SmallCard simple card={match.player2Card} />
          <IonLabel>=</IonLabel>
        </div>
        <div className="game-status">
          {isPlayer1 && match.result == MatchState.WIN1 && (
            <>
              <IonLabel className="won">You Won</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player2Bet}
                expanded={match.player2Bet}
              />
            </>
          )}
          {isPlayer1 && match.result == MatchState.WIN2 && (
            <>
              <IonLabel className="lost">You Lost</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player1Bet}
                expanded={match.player1Bet}
              />
            </>
          )}
          {!isPlayer1 && match.result == MatchState.WIN2 && (
            <>
              <IonLabel className="won">You Won</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player1Bet}
                expanded={match.player1Bet}
              />
            </>
          )}
          {!isPlayer1 && match.result == MatchState.WIN1 && (
            <>
              <IonLabel className="lost">You Lost</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player2Bet}
                expanded={match.player2Bet}
              />
            </>
          )}
          {isPlayer1 && match.result == MatchState.DRAW && (
            <>
              <IonLabel className="draw">Draw</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player1Bet}
                expanded={match.player1Bet}
              />
            </>
          )}
          {!isPlayer1 && match.result == MatchState.DRAW && (
            <>
              <IonLabel className="draw">Draw</IonLabel>
              <SmallStars
                direction="row"
                nbr={match.player2Bet}
                expanded={match.player2Bet}
              />
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default memo(MatcheHistory);
