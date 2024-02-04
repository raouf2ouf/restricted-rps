import { IonContent, IonPage } from "@ionic/react";
import { memo } from "react";

import "./Home.scss";

const HomePage: React.FC = () => {
  return (
    <IonPage>
      <IonContent>
        <div className="home-main-container">
          <div>Hello</div>
        </div>
      </IonContent>
    </IonPage>
  );
};

export default memo(HomePage);
