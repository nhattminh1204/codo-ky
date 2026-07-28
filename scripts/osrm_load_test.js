import http from 'http';

const ENDPOINT = 'http://localhost:5000/route/v1/driving/107.5909,16.4637;107.5800,16.4600?overview=full&geometries=geojson';
const TOTAL_REQUESTS = 30;

console.log(`🚀 Starting load test with ${TOTAL_REQUESTS} concurrent requests to self-hosted OSRM endpoint...`);

let successCount = 0;
let failCount = 0;
const startTime = Date.now();

const promises = Array.from({ length: TOTAL_REQUESTS }, (_, index) => {
  return new Promise((resolve) => {
    http.get(ENDPOINT, (res) => {
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(rawData);
          if (res.statusCode === 200 && parsed.code === 'Ok') {
            successCount++;
            console.log(`  [Req ${index + 1}/${TOTAL_REQUESTS}] ✅ 200 OK (${parsed.routes[0].distance}m, ${parsed.routes[0].duration}s)`);
          } else {
            failCount++;
            console.log(`  [Req ${index + 1}/${TOTAL_REQUESTS}] ❌ Status ${res.statusCode}: ${rawData}`);
          }
        } catch (e) {
          failCount++;
          console.log(`  [Req ${index + 1}/${TOTAL_REQUESTS}] ❌ Parse error: ${e.message}`);
        }
        resolve();
      });
    }).on('error', (err) => {
      failCount++;
      console.log(`  [Req ${index + 1}/${TOTAL_REQUESTS}] ❌ Network error: ${err.message}`);
      resolve();
    });
  });
});

Promise.all(promises).then(() => {
  const totalTime = Date.now() - startTime;
  console.log(`\n=== 📊 LOAD TEST RESULT ===`);
  console.log(`Total Requests: ${TOTAL_REQUESTS}`);
  console.log(`Success Count: ${successCount}`);
  console.log(`Fail Count: ${failCount}`);
  console.log(`Total Duration: ${totalTime} ms`);
  console.log(`Average Latency: ${(totalTime / TOTAL_REQUESTS).toFixed(1)} ms/req`);

  if (failCount === 0 && successCount === TOTAL_REQUESTS) {
    console.log(`🎉 100% SUCCESS! Self-hosted OSRM router handled all ${TOTAL_REQUESTS} concurrent requests smoothly without rate limiting.`);
    process.exit(0);
  } else {
    console.error(`⚠️ Load test failed with ${failCount} errors.`);
    process.exit(1);
  }
});
