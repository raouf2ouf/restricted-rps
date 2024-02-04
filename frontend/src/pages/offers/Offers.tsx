import { IonContent, IonPage } from "@ionic/react";
import { memo } from "react";

import "./Offers.scss";

const OffersPage: React.FC = () => {
  return (
    <IonPage>
      <IonContent>
        <div className="offers-main-container">
          <div>Hello</div>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(OffersPage);
