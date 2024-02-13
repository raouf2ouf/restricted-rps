import { IonContent, IonLabel, IonPage, IonText } from "@ionic/react";
import { memo } from "react";

import "./Home.scss";

const HomePage: React.FC = () => {
  return (
    <IonPage>
      <IonContent>
        <div className="home-main-container">
          <div className="section">
            <IonLabel className="title">
              Ethpoir (Restricted Random RPS)
            </IonLabel>
            <IonLabel className="subtitle">
              A <em>Prouvably fair</em> multiplayer <em>Card Game</em> on{" "}
              <em>LightLink</em>
            </IonLabel>
            <div className="content tldr">
              <p>
                <strong>TLDR;</strong> A multiplayer Card Game based on Rock
                Paper Scissors. Players join by providing a collateral and
                recieve <em>6 random (hidden) cards</em> (a collection of Rock,
                Paper, Scissors cards), <em>3 stars</em> and a certain amount of{" "}
                <em>in-game cash</em>. Players play matches by chosing a card
                and betting a number of stars. They can also buy and sell cards.
                At the end of the game, if a player has no more cards, he can
                redeem his stars for collateral. The fairness of the game is
                proven by the blockchain and any cheating can be automatically
                detected.
              </p>
            </div>
            <IonLabel className="subsection-title">Introduction</IonLabel>
            <div className="content">
              <p>
                <a href="https://en.wikipedia.org/wiki/Rock_paper_scissors">
                  Rock, Paper, Scissors [RPS]
                </a>{" "}
                is one the most iconic and played games all over the world
                (there is even an{" "}
                <a href="https://wrpsa.com/rock-paper-scissors-tournaments/">
                  RPS World Championship
                </a>
                ). However, there was always a debate on wether it is a game of{" "}
                <em>chance</em> or a game of <em>skill</em> ?
              </p>
              <p>
                <em>Restricted Random RPS</em> [RRPS] is a variant that adds
                complexity and amplifies the role of chance and skill. It is
                inspired by the famous{" "}
                <a href="https://kaiji.fandom.com/wiki/Restricted_Rock_Paper_Scissors">
                  Resctricted RPS
                </a>{" "}
                from the manga{" "}
                <a href="https://kaiji.fandom.com/wiki/Kaiji_Wiki">Kaiji</a>.
                The name Ethpoir is a bad joke mixing{" "}
                <a href="https://kaiji.fandom.com/wiki/Espoir">Espoir</a> (the
                name of the ship where the game was played) and ETH (it is also
                how my little niece pronounces Espoir).
              </p>
            </div>

            <IonLabel className="subsection-title">How to play</IonLabel>
            <div className="content">
              <p>
                You need some <strong>Lightlink</strong> test ETH to play. A
                game starts when a game master provides a hidden shuffled Deck
                of <em>36 cards</em> (12 Rock, 12 Paper, 12 Scissors) [the
                fairness of this deck (and of the game master) will be checked
                by the blockchain at the end of game]. You start by joining a
                game and providing a <em>collateral</em> for which you will
                recieve:
              </p>
              <ol>
                <li>
                  <em>6 cards: </em> a collection of Rock, Paper, Scissors cards
                  that are only known to you!
                </li>
                <li>
                  <em>3 stars: </em> used to bet when you play a card. They are
                  redeemable for collateral at the end of the game.
                </li>
                <li>
                  <em>In-game Cash: </em> used to buy and sell cards. You can
                  only redeem stars if you have no cards in you hand!
                </li>
              </ol>
              <p>
                After which you can <em>offer</em> or <em>answer</em> a match: a
                match is offered by placing a hidden card and a bet (number of
                stars). Other players can answer your match by placing a card
                and bet at least equal to the minimum you indicated.
              </p>
            </div>

            <IonLabel className="subsection-title">
              How to win [or lose]
            </IonLabel>
            <div className="content">
              <ul>
                <li>
                  You <em>win a game</em> when you have{" "}
                  <em>at least 3 stars </em>
                  and <em>no cards</em> at the end of the game. For each star
                  above 3 you will recieve additional collateral.
                </li>
                <li>
                  You <em>lose a game </em>
                  when you have <em>less than 3 stars</em> at the end of the
                  game (you will still recieve part of your collateral for each
                  star you have).
                </li>
                <li>
                  You <em>draw a game</em> when you have more than 3 stars and
                  at <em>least 1 card</em>. You will only recieve the collateral
                  you used.
                </li>
              </ul>
            </div>
            <IonLabel className="subsection-title">
              Strategies and How to understand the UI
            </IonLabel>
            <div className="content">
              <p>
                Counter-intuitively, your aim should be to get rid of your cards
                as fast as possible once you have at least 3 stars. In order to
                do so, you can offer or answer matches (or pay others to take
                your cards by setting a negative number when you offer your
                cards). Before answering a match, you should have a look at the
                right section of the UI, you will see how many cards the player
                already played, sometimes you can even predict the card played
                by your opponent.
              </p>
              <p>
                You can see your hand for this game on the left menu along with
                a graph of you winnings (or losses).
              </p>
            </div>
            <IonLabel className="subsection-title">
              Cheat Detection and Fairness
            </IonLabel>
            <div className="content">
              <p></p>
            </div>
          </div>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(HomePage);
