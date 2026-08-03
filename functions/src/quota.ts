
export async function checkAndIncrementQuota(
  adminFirestore: any,
  simulateTimeOffsetMs: number = 0
): Promise<{ currentQuota: number; quotaExceeded: boolean }> {
  let currentQuota = 0;
  let quotaExceeded = false;
  
  const counterRef = adminFirestore.doc("usage/gemini_daily_counter");
  
  await adminFirestore.runTransaction(async (t: any) => {
    const doc = await t.get(counterRef);
    const docData = doc.data() || {};
    let count = docData.count || 0;
    
    // Lấy giờ UTC+7 (Asia/Ho_Chi_Minh) để reset quota đồng bộ với cảm nhận người dùng VN
    const now = new Date(Date.now() + simulateTimeOffsetMs);
    const utc7Time = new Date(now.getTime() + 7 * 60 * 60 * 1000);
    const today = utc7Time.toISOString().split("T")[0]; // YYYY-MM-DD
    
    if (docData.lastResetDate !== today) {
      count = 0;
    }
    
    if (count >= 1000) {
      quotaExceeded = true;
      currentQuota = count;
      return; // Dừng transaction, không update db
    }
    
    currentQuota = count + 1;
    t.set(counterRef, { count: currentQuota, lastResetDate: today }, { merge: true });
  });

  return { currentQuota, quotaExceeded };
}
