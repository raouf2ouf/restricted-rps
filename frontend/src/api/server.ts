import { History } from "$models/History";
import Axios from "axios";

// const API_SERVER = process.env.VITE_API || "http://localhost:3000/api/";
const API_SERVER = "/api/";
const axios = Axios.create({
  baseURL: `${API_SERVER}`,
  headers: { "Content-Type": "application/json" },
});

export async function getHistory(address: string): Promise<History[]> {
  const res = await axios.get<History[]>(`history/${address}`);
  return res.data;
}

export async function autoCloseMatch(
  address: string,
  card: number,
  matchId: number,
  secret: string
): Promise<boolean> {
  const res = await axios.post<boolean>(`matches/autoClose`, {
    address,
    matchId,
    card,
    secret,
  });
  return res.data;
}
