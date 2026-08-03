import * as logger from "firebase-functions/logger";

// WMO Weather Interpretation Codes -> human-readable label
function wmoCodeToLabel(code: number): string {
  if (code === 0) return "Trời quang";
  if (code <= 3) return "Ít mây";
  if (code <= 48) return "Sương mù";
  if (code <= 57) return "Mưa phùn";
  if (code <= 67) return "Mưa";
  if (code <= 77) return "Tuyết";
  if (code <= 82) return "Mưa rào";
  if (code <= 86) return "Mưa tuyết";
  if (code <= 99) return "Giông bão";
  return "Không xác định";
}

export interface DailyWeather {
  date: string;
  weatherLabel: string;
  tempMax: number;
  tempMin: number;
  precipitationProbability: number;
}

export interface WeatherForecast {
  days: DailyWeather[];
}

/**
 * Fetch N-day weather forecast from Open-Meteo (no API key required).
 * Throws on network error or invalid response so caller can gracefully degrade.
 */
export async function getWeatherForecast(
  lat: number,
  lng: number,
  days: number
): Promise<WeatherForecast> {
  const url = new URL("https://api.open-meteo.com/v1/forecast");
  url.searchParams.set("latitude", String(lat));
  url.searchParams.set("longitude", String(lng));
  url.searchParams.set(
    "daily",
    "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"
  );
  url.searchParams.set("forecast_days", String(Math.min(days, 16)));
  url.searchParams.set("timezone", "auto");

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 5000);

  let resJson: any;
  try {
    const res = await fetch(url.toString(), {
      method: "GET",
      headers: { Accept: "application/json" },
      signal: controller.signal,
    });
    clearTimeout(timeoutId);

    if (!res.ok) {
      throw new Error(`Open-Meteo HTTP ${res.status}`);
    }
    resJson = await res.json();
  } finally {
    clearTimeout(timeoutId);
  }

  const daily = resJson?.daily;
  if (
    !daily ||
    !Array.isArray(daily.time) ||
    !Array.isArray(daily.weather_code) ||
    !Array.isArray(daily.temperature_2m_max) ||
    !Array.isArray(daily.temperature_2m_min) ||
    !Array.isArray(daily.precipitation_probability_max)
  ) {
    throw new Error("Open-Meteo response schema invalid");
  }

  const result: DailyWeather[] = daily.time.slice(0, days).map(
    (date: string, i: number) => ({
      date,
      weatherLabel: wmoCodeToLabel(daily.weather_code[i] ?? 0),
      tempMax: Math.round(daily.temperature_2m_max[i] ?? 0),
      tempMin: Math.round(daily.temperature_2m_min[i] ?? 0),
      precipitationProbability: Math.round(
        daily.precipitation_probability_max[i] ?? 0
      ),
    })
  );

  return { days: result };
}

/**
 * Build a compact weather summary string to inject into the Gemini prompt.
 * Returns empty string if forecast is null (graceful degradation path).
 */
export function buildWeatherPromptSection(
  forecast: WeatherForecast | null
): string {
  if (!forecast || forecast.days.length === 0) return "";

  const lines = forecast.days.map((d, i) => {
    const rainHint =
      d.precipitationProbability >= 60
        ? "→ ưu tiên địa điểm trong nhà (bảo tàng, nhà hàng, cafe)"
        : d.precipitationProbability >= 30
        ? "→ linh hoạt, chuẩn bị áo mưa"
        : "→ ưu tiên địa điểm ngoài trời, tham quan di tích";

    return (
      `  Ngày ${i + 1} (${d.date}): ${d.weatherLabel}, ` +
      `${d.tempMin}°C – ${d.tempMax}°C, ` +
      `mưa ${d.precipitationProbability}% ${rainHint}`
    );
  });

  return (
    `\n- Dự báo thời tiết Huế trong ${forecast.days.length} ngày tới:\n` +
    lines.join("\n") +
    "\n- Lưu ý lập lịch: xếp tham quan ngoài trời vào ngày ít mưa, " +
    "chuyển sang địa điểm trong nhà (bảo tàng, ẩm thực, spa) vào ngày mưa nhiều.\n"
  );
}

/**
 * Safe wrapper: tries getWeatherForecast, returns null on any error.
 * Logs warning but never throws — caller continues normally (graceful degradation).
 */
export async function tryGetWeatherForecast(
  lat: number,
  lng: number,
  days: number
): Promise<WeatherForecast | null> {
  try {
    const forecast = await getWeatherForecast(lat, lng, days);
    logger.info("Weather forecast fetched", {
      lat,
      lng,
      days: forecast.days.length,
    });
    return forecast;
  } catch (err: any) {
    logger.warn("Weather forecast unavailable (graceful degradation)", {
      error: err?.message || String(err),
    });
    return null;
  }
}
