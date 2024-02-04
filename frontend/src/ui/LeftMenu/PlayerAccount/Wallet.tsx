import { IonButton } from "@ionic/react";
import { memo, useEffect } from "react";
import { useAccount, useConnect } from "wagmi";

import "./Wallet.scss";
import { useAppDispatch } from "$store/store";
import { setPlayerAddress } from "$store/playersState.slice";
type Props = {};

const Wallet: React.FC<Props> = ({}) => {
  const dispatch = useAppDispatch();
  const { isConnected, address } = useAccount();
  const { connectors, connect } = useConnect();

  function handleConnect() {
    connect({ connector: connectors[0] });
  }

  function shortenAddress(addr: any) {
    return addr.slice(0, 7) + "..." + addr.slice(-5);
  }

  useEffect(() => {
    if (address) {
      dispatch(setPlayerAddress(address));
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
