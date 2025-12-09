import crypto from "crypto";

export type Block = {
  index: number;
  timestamp: string;
  transactions: any[];
  previous_hash: string;
  current_hash: string;
};

// ✍️ TODO: Viết hàm tại đây
export function isValidBlock(block: Block): boolean {
  const dataToHash =
    block.index +
    block.timestamp +
    JSON.stringify(block.transactions) + // Chuyển mảng giao dịch thành chuỗi JSON
    block.previous_hash;

  const calculatedHash = crypto
    .createHash("sha256")
    .update(dataToHash)
    .digest("hex");

  if (calculatedHash === block.current_hash) {
    return true;
  } else {
    return false;
  }
}
