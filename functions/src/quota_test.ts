import * as assert from 'assert';
import { checkAndIncrementQuota } from './quota';

// Mocking the Firestore Transaction logic
const mockDb = {
  data: {
    count: 0,
    lastResetDate: ''
  },
  exists: false,
};

let transactionCount = 0;

const mockTransaction = {
  get: async (ref: any) => {
    return {
      exists: mockDb.exists,
      data: () => mockDb.exists ? { ...mockDb.data } : undefined,
    };
  },
  set: (ref: any, data: any, options: any) => {
    mockDb.data = { ...mockDb.data, ...data };
    mockDb.exists = true;
  },
  update: (ref: any, data: any) => {
    mockDb.data = { ...mockDb.data, ...data };
  }
};

const mockFirestore = {
  doc: (path: string) => path,
  runTransaction: async (callback: (t: any) => Promise<void>) => {
    transactionCount++;
    await callback(mockTransaction);
  }
};

async function runTests() {
  console.log("Running quota tests...");
  
  // Test A: Request khi count = 1000 phải bị chặn
  const now = new Date();
  const utc7Time = new Date(now.getTime() + 7 * 60 * 60 * 1000);
  const today = utc7Time.toISOString().split("T")[0];
  
  mockDb.exists = true;
  mockDb.data = {
    count: 1000,
    lastResetDate: today
  };
  
  const res1 = await checkAndIncrementQuota(mockFirestore as any);
  assert.strictEqual(res1.quotaExceeded, true, "Should block when count >= 1000");
  assert.strictEqual(res1.currentQuota, 1000, "Current quota should be 1000");
  assert.strictEqual(mockDb.data.count, 1000, "DB count should not increment");
  console.log("✅ Test (a) passed: Request bị chặn ngay khi count = 1000 trước khi gọi Gemini");

  // Test B: Reset vào thời điểm chuyển ngày và 2 request đến liên tiếp
  const yesterdayTime = new Date(now.getTime() - 24 * 60 * 60 * 1000 + 7 * 60 * 60 * 1000);
  const yesterday = yesterdayTime.toISOString().split("T")[0];
  
  mockDb.exists = true;
  mockDb.data = {
    count: 999,
    lastResetDate: yesterday
  };
  
  // Request 1: Ngay sau khi qua ngày mới (sẽ reset về 0 rồi +1 = 1)
  const res2 = await checkAndIncrementQuota(mockFirestore as any);
  assert.strictEqual(res2.quotaExceeded, false, "Should allow request on new day");
  assert.strictEqual(res2.currentQuota, 1, "Quota should reset to 1");
  assert.strictEqual(mockDb.data.count, 1, "DB count should be 1");
  assert.strictEqual(mockDb.data.lastResetDate, today, "Reset date should be today");
  
  // Request 2: Đồng thời / ngay sau đó (sẽ tiếp tục +1 = 2)
  const res3 = await checkAndIncrementQuota(mockFirestore as any);
  assert.strictEqual(res3.quotaExceeded, false, "Should allow second request");
  assert.strictEqual(res3.currentQuota, 2, "Quota should be 2");
  assert.strictEqual(mockDb.data.count, 2, "DB count should be 2");
  
  console.log("✅ Test (b) passed: Bộ đếm reset chuẩn xác khi qua ngày mới và cộng dồn đúng cho request tiếp theo");
  
  console.log("All tests passed!");
}

runTests().catch(console.error);
