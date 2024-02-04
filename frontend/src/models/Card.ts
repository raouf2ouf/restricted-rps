export enum Card {
  ROCK,
  PAPER,
  SCISSORS,
}

export const cardToType = (card: Card) => {
  if (card == Card.ROCK) return "rock";
  if (card == Card.PAPER) return "paper";
  return "scissors";
};
