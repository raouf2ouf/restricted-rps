import { ReactNode, memo } from "react";

import "./List.scss";
type Props = {
  children: ReactNode;
};

const List: React.FC<Props> = ({ children }) => {
  return (
    <div className="list-container">
      <div>{children}</div>
    </div>
  );
};

export default memo(List);
