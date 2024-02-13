import { History } from "$models/History";
import Axios from "axios";

const API_SERVER = "http://localhost:3000/api/";
const axios = Axios.create({
  baseURL: `${API_SERVER}`,
  headers: { "Content-Type": "application/json" },
});

export async function getHistory(address: string): Promise<History[]> {
  const res = await axios.get<History[]>(`history/${address}`);
  return res.data;
}
