import { IonContent, IonLabel, IonPage, IonText } from "@ionic/react";
import { memo } from "react";

import "./History.scss";

const HistoryPage: React.FC = () => {
  return (
    <IonPage>
      <IonContent>
        <div className="history-main-container">
          <div className="section"></div>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(HistoryPage);
