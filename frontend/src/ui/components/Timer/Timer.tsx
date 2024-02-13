import { useState, useEffect, memo, useMemo } from "react";

type Props = {
  endTime: number;
};

const Timer: React.FC<Props> = ({ endTime }) => {
  const time = useMemo(() => new Date(endTime * 1000 - Date.now()), [endTime]);
  const [seconds, setSeconds] = useState<number>(time.getUTCSeconds());
  const [minutes, setMinutes] = useState<number>(time.getUTCMinutes());
  const [hours, setHours] = useState<number>(
    (time.getUTCDate() - 1) * 24 + time.getUTCHours()
  );

  useEffect(() => {
    if (hours <= 0 && minutes <= 0 && seconds <= 0) return;

    const timerInterval = setInterval(() => {
      setSeconds((prevSeconds) => (prevSeconds === 0 ? 59 : prevSeconds - 1));

      if (seconds === 0) {
        setMinutes((prevMinutes) => (prevMinutes === 0 ? 59 : prevMinutes - 1));

        if (minutes === 0) {
          setHours((prevHours) => (prevHours === 0 ? 23 : prevHours - 1));
        }
      }
    }, 1000);

    // Clear the interval when the component is unmounted
    return () => clearInterval(timerInterval);
  }, [seconds, minutes, hours]);

  return (
    <div>{`${String(hours).padStart(2, "0")}:${String(minutes).padStart(
      2,
      "0"
    )}:${String(seconds).padStart(2, "0")}`}</div>
  );
};

export default memo(Timer);
