import { useState, useEffect, memo } from "react";

type Props = {};

function getRandomInt(min: number, max: number): number {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

const Timer: React.FC<Props> = () => {
  const [seconds, setSeconds] = useState<number>(getRandomInt(0, 60));
  const [minutes, setMinutes] = useState<number>(getRandomInt(0, 60));
  const [hours, setHours] = useState<number>(getRandomInt(21, 23));

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
