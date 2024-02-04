import {
  Dispatch,
  ReactNode,
  SetStateAction,
  createContext,
  useContext,
  useEffect,
  useState,
} from "react";

type MenuContextProps = {
  leftMenuOpen: boolean;
  rightMenuOpen: boolean;
  toggleLeftSide: (open?: boolean) => void;
  toggleRightSide: (open?: boolean) => void;
};

const MIN_WIDTH_TO_CLOSE = 1115;
const MIN_WIDTH_TO_OPEN_BOTH = 1400;

const MenuContext = createContext<MenuContextProps>({
  leftMenuOpen: true,
  rightMenuOpen: true,
  toggleLeftSide: () => {},
  toggleRightSide: () => {},
});

type Props = {
  children: ReactNode;
};

export const MenuProvider: React.FC<Props> = ({ children }) => {
  const [leftMenuOpen, setLeftMenuOpen] = useState<boolean>(true);
  const [rightMenuOpen, setRightMenuOpen] = useState<boolean>(true);

  useEffect(() => {
    function onWindowResize() {
      checkMenusState();
    }
    window.addEventListener("resize", onWindowResize);
    onWindowResize();
    return () => window.removeEventListener("resize", onWindowResize);
  }, []);

  function toggleLeftSide(open?: boolean) {
    let openLeft = false;
    if (open === undefined) {
      openLeft = !leftMenuOpen;
    } else {
      openLeft = open;
    }
    if (openLeft && rightMenuOpen && window.innerWidth < MIN_WIDTH_TO_CLOSE) {
      // both menus will be open
      setRightMenuOpen(false);
    }
    setLeftMenuOpen(openLeft);
  }

  function toggleRightSide(open?: boolean) {
    let openRight = false;
    if (open === undefined) {
      openRight = !rightMenuOpen;
    } else {
      openRight = open;
    }
    if (openRight && leftMenuOpen && window.innerWidth < MIN_WIDTH_TO_CLOSE) {
      // both menus will be open
      setLeftMenuOpen(false);
    }
    setRightMenuOpen(openRight);
  }

  function checkMenusState() {
    let openRight;
    let openLeft;
    if (window.innerWidth < MIN_WIDTH_TO_CLOSE) {
      openRight = false;
      openLeft = false;
    } else if (window.innerWidth > MIN_WIDTH_TO_OPEN_BOTH) {
      openRight = true;
      openLeft = true;
    } else {
      openRight = false;
      openLeft = true;
    }
    setLeftMenuOpen(openLeft);
    setRightMenuOpen(openRight);
  }

  return (
    <MenuContext.Provider
      value={{ leftMenuOpen, rightMenuOpen, toggleLeftSide, toggleRightSide }}
    >
      {children}
    </MenuContext.Provider>
  );
};

export function useMenuContext() {
  return useContext(MenuContext);
}
