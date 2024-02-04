import { useGame, useOpenGames } from "$hooks/useGames";
import { fetchMatchesForGame } from "$store/matches.slice";
import { upsertOpenGame } from "$store/openGames.slice";
import { useAppDispatch } from "$store/store";
import { memo, useEffect } from "react";
import { useAccount, useConfig } from "wagmi";

type MatchesProps = {
  gameAddress: "0x${string}";
};
const MatchesFetcher: React.FC<MatchesProps> = memo(({ gameAddress }) => {
  const dispatch = useAppDispatch();
  const config = useConfig();
  useEffect(() => {
    dispatch(fetchMatchesForGame({ config, gameAddress }));
  }, []);

  return <></>;
});

type Props = {
  gameAddress: string;
};
const DataFetcher: React.FC<Props> = memo(({ gameAddress }) => {
  const dispatch = useAppDispatch();
  const { address } = useAccount();
  const info = useGame(gameAddress as "0x${string}");
  useEffect(() => {
    if (info) {
      dispatch(upsertOpenGame(info));
    }
  }, [info]);
  return (
    <>
      {address &&
        info &&
        info.players.filter(
          (p) => p.toLowerCase() == address.toLowerCase()
        ) && <MatchesFetcher gameAddress={gameAddress as "0x${string}"} />}
    </>
  );
});

const DataFetchers: React.FC = () => {
  const games = useOpenGames();
  return (
    <>{games && games.map((g) => <DataFetcher gameAddress={g} key={g} />)}</>
  );
};

export default memo(DataFetchers);
