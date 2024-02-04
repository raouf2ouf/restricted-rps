const ETHER = BigInt("1000000000000000000");
export function weiToEther(valueInWei: bigint): number {
  if (valueInWei < ETHER) {
    return Number(Number(valueInWei) / 1e18);
  }
  return Number(valueInWei / ETHER);
}

export function wTe(valueInWei: bigint): number {
  const valueInEther = weiToEther(valueInWei);
  return parseFloat(valueInEther.toFixed(6));
}
