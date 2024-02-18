import { IonButton } from "@ionic/react";
import { memo, useEffect } from "react";
import { useAccount, useChainId, useConnect, useSwitchChain } from "wagmi";

import "./Wallet.scss";
import { useAppDispatch } from "$store/store";
import { setPlayerAddress } from "$store/playersState.slice";
import { fetchHistory } from "$store/histories.slice";
import { foundry, lightlinkPegasus } from "viem/chains";
type Props = {};

const Wallet: React.FC<Props> = ({}) => {
  const dispatch = useAppDispatch();
  const { isConnected, address } = useAccount();
  const { connectors, connect } = useConnect();

  const { switchChain } = useSwitchChain();

  function handleConnect() {
    connect({ connector: connectors[0] });
  }

  function shortenAddress(addr: any) {
    return addr.slice(0, 7) + "..." + addr.slice(-5);
  }

  useEffect(() => {
    if (address) {
      switchChain({ connector: connectors[0], chainId: foundry.id });
      dispatch(setPlayerAddress(address));
      dispatch(fetchHistory(address));
    }
  }, [address]);
  return (
    <>
      {isConnected ? (
        <IonButton className="account-button" fill="clear">
          {shortenAddress(address)}
        </IonButton>
      ) : (
        <IonButton
          className="connect-button"
          fill="clear"
          onClick={handleConnect}
        >
          Connect
        </IonButton>
      )}
    </>
  );
};

export default memo(Wallet);
