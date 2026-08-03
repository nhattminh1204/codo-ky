/**
 * weather_test.ts — Test các hàm thật từ weather.ts.
 *
 * Chạy: npx tsx src/weather_test.ts
 */
import * as assert from "assert";
import {
  tryGetWeatherForecast,
  buildWeatherPromptSection,
  DailyWeather,
  WeatherForecast,
} from "./weather";

// ─── Test Suite ───────────────────────────────────────────────────────────────

async function runTests() {
  console.log("\n🧪 Running weather tests (calling real functions from weather.ts)...\n");

  // ── Test 1: tryGetWeatherForecast thật → trả null khi fetch fail, KHÔNG throw ─
  // Mock globalThis.fetch để buộc network reject ngay lập tức
  {
    const originalFetch = globalThis.fetch;
    globalThis.fetch = async () => {
      throw new Error("Mocked network failure — simulating Open-Meteo unreachable");
    };

    let result: WeatherForecast | null;
    let threw = false;
    try {
      // Gọi hàm THẬT tryGetWeatherForecast — không phải bản sao
      result = await tryGetWeatherForecast(16.4637, 107.5909, 3);
    } catch {
      threw = true;
      result = null;
    } finally {
      globalThis.fetch = originalFetch; // Restore ngay sau khi test xong
    }

    assert.strictEqual(
      threw,
      false,
      "FAIL: tryGetWeatherForecast KHÔNG được throw ra ngoài khi fetch fail"
    );
    assert.strictEqual(
      result,
      null,
      "FAIL: tryGetWeatherForecast phải trả về null khi fetch fail (graceful degradation)"
    );

    console.log(
      "✅ Test 1 PASS: tryGetWeatherForecast thật → trả null khi fetch lỗi, không crash caller"
    );
  }

  // ── Test 2: tryGetWeatherForecast thật gọi Open-Meteo thật → trả WeatherForecast ─
  // Open-Meteo không cần API key, endpoint public, gọi thật rẻ và nhanh (~200ms)
  {
    const result = await tryGetWeatherForecast(16.4637, 107.5909, 3);

    // Nếu đang offline/Open-Meteo down → graceful degradation trả null → skip assertion
    if (result === null) {
      console.log(
        "⚠️  Test 2 SKIP: tryGetWeatherForecast trả null (có thể offline hoặc Open-Meteo tạm thời lỗi) — graceful degradation hoạt động đúng"
      );
    } else {
      assert.ok(
        result && Array.isArray(result.days),
        "FAIL: WeatherForecast phải có mảng days"
      );
      assert.ok(
        result.days.length > 0,
        "FAIL: days không được rỗng"
      );
      assert.ok(
        result.days.length <= 3,
        "FAIL: Chỉ yêu cầu 3 ngày"
      );
      const day0 = result.days[0];
      assert.ok(
        typeof day0.date === "string" && day0.date.length > 0,
        "FAIL: date phải là string"
      );
      assert.ok(
        typeof day0.tempMax === "number",
        "FAIL: tempMax phải là number"
      );
      assert.ok(
        typeof day0.tempMin === "number",
        "FAIL: tempMin phải là number"
      );
      assert.ok(
        typeof day0.precipitationProbability === "number",
        "FAIL: precipitationProbability phải là number"
      );
      assert.ok(
        typeof day0.weatherLabel === "string",
        "FAIL: weatherLabel phải là string"
      );

      console.log(
        `✅ Test 2 PASS: tryGetWeatherForecast thật → WeatherForecast hợp lệ (${result.days.length} ngày, ngày đầu: ${day0.date}, ${day0.tempMin}°C–${day0.tempMax}°C, mưa ${day0.precipitationProbability}%)`
      );
    }
  }

  // ── Test 3: buildWeatherPromptSection(null) → chuỗi rỗng ───────────────────
  {
    const section = buildWeatherPromptSection(null);
    assert.strictEqual(
      section,
      "",
      "FAIL: buildWeatherPromptSection(null) phải trả về chuỗi rỗng"
    );
    console.log(
      "✅ Test 3 PASS: buildWeatherPromptSection(null) → chuỗi rỗng (graceful degradation)"
    );
  }

  // ── Test 4: buildWeatherPromptSection → ngày mưa 90% có chỉ dẫn trong nhà ──
  {
    const rainyForecast: WeatherForecast = {
      days: [
        {
          date: "2026-08-04",
          weatherLabel: "Giông bão",
          tempMax: 30,
          tempMin: 24,
          precipitationProbability: 90,
        } as DailyWeather,
      ],
    };
    const section = buildWeatherPromptSection(rainyForecast);
    assert.ok(
      section.includes("trong nhà"),
      "FAIL: Ngày mưa 90% phải có chỉ dẫn địa điểm trong nhà"
    );
    assert.ok(
      section.includes("90%"),
      "FAIL: Phần trăm mưa phải xuất hiện trong prompt"
    );
    console.log(
      "✅ Test 4 PASS: buildWeatherPromptSection ngày mưa 90% → chỉ dẫn ưu tiên địa điểm trong nhà"
    );
  }

  // ── Test 5: buildWeatherPromptSection → ngày nắng 5% có chỉ dẫn ngoài trời ─
  {
    const sunnyForecast: WeatherForecast = {
      days: [
        {
          date: "2026-08-05",
          weatherLabel: "Trời quang",
          tempMax: 36,
          tempMin: 28,
          precipitationProbability: 5,
        } as DailyWeather,
      ],
    };
    const section = buildWeatherPromptSection(sunnyForecast);
    assert.ok(
      section.includes("ngoài trời"),
      "FAIL: Ngày nắng 5% mưa phải có chỉ dẫn địa điểm ngoài trời"
    );
    console.log(
      "✅ Test 5 PASS: buildWeatherPromptSection ngày nắng → chỉ dẫn ưu tiên địa điểm ngoài trời"
    );
  }

  // ── Test 6: buildWeatherPromptSection → ngày mưa vừa 40% → chỉ dẫn linh hoạt
  {
    const mixedForecast: WeatherForecast = {
      days: [
        {
          date: "2026-08-06",
          weatherLabel: "Mưa phùn",
          tempMax: 33,
          tempMin: 26,
          precipitationProbability: 40,
        } as DailyWeather,
      ],
    };
    const section = buildWeatherPromptSection(mixedForecast);
    assert.ok(
      section.includes("linh hoạt"),
      "FAIL: Ngày mưa 40% phải có chỉ dẫn linh hoạt / chuẩn bị áo mưa"
    );
    console.log(
      "✅ Test 6 PASS: buildWeatherPromptSection ngày mưa 40% → chỉ dẫn linh hoạt"
    );
  }

  console.log("\n🎉 All tests passed!\n");
}

runTests().catch((err) => {
  console.error("❌ Test failed:", err);
  process.exit(1);
});
