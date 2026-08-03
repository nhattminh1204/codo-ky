import { setGlobalOptions } from "firebase-functions";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { checkAndIncrementQuota } from "./quota";
import { tryGetWeatherForecast, buildWeatherPromptSection } from "./weather";

admin.initializeApp();

// Authentication middleware helper
async function verifyAuth(request: any): Promise<admin.auth.DecodedIdToken | null> {
  const authHeader = request.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  const token = authHeader.split("Bearer ")[1];
  try {
    return await admin.auth().verifyIdToken(token);
  } catch (error) {
    logger.error("Token verification failed", error);
    return null;
  }
}

setGlobalOptions({ maxInstances: 10, region: "asia-southeast1" });

// Simple in-memory rate limiter per IP / userId
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function checkRateLimit(key: string, limit = 10, windowMs = 60000): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(key);

  if (!entry || now > entry.resetTime) {
    rateLimitMap.set(key, { count: 1, resetTime: now + windowMs });
    return true;
  }

  if (entry.count >= limit) {
    return false;
  }

  entry.count += 1;
  return true;
}

export const generateItinerary = onRequest(
  { cors: true },
  async (request, response) => {
    const startTime = Date.now();
    const clientIp = request.ip || request.headers["x-forwarded-for"] || "anonymous";
    logger.info("generateItinerary request received", { clientIp, method: request.method });

    if (request.method !== "POST") {
      response.status(405).json({ error: "Method not allowed. Use POST." });
      return;
    }

    // 0. Auth check
    const decodedToken = await verifyAuth(request);
    if (!decodedToken) {
      response.status(401).json({ error: "Unauthorized. Vui lòng đăng nhập." });
      return;
    }
    const userId = decodedToken.uid;

    // 1. Rate limiting check per user or IP
    if (!checkRateLimit(String(userId), 10, 60000)) {
      logger.warn("Rate limit exceeded", { userId });
      response.status(429).json({
        error: "Bạn đã đạt giới hạn gửi yêu cầu tạo lộ trình. Vui lòng thử lại sau 1 phút.",
      });
      return;
    }

    try {
      const {
        durationDays = 2,
        budget = 1500000,
        interests = ["di sản", "ẩm thực"],
        places = [],
        currentLocation,
      } = request.body || {};

      // Toạ độ người dùng: FE gửi { lat, lng } hoặc dùng mặc định trung tâm Huế
      const userLat: number =
        typeof currentLocation?.lat === "number" ? currentLocation.lat : 16.4637;
      const userLng: number =
        typeof currentLocation?.lng === "number" ? currentLocation.lng : 107.5909;

      // Lấy dự báo thời tiết — graceful degradation: lỗi → null → bỏ qua
      const weatherForecast = await tryGetWeatherForecast(userLat, userLng, durationDays);
      const weatherPromptSection = buildWeatherPromptSection(weatherForecast);

      const apiKey = process.env.GEMINI_API_KEY || "AIzaSyDipy8Mfljw8yn-l5ftOQQscugUIGsv7X0";
      if (!apiKey) {
        logger.error("Missing GEMINI_API_KEY environment variable");
        response.status(500).json({ error: "Hệ thống AI chưa được cấu hình API key." });
        return;
      }

      // 2. Track daily quota in Firestore BEFORE calling Gemini API
      let currentQuota = 0;
      let quotaExceeded = false;
      try {
        const result = await checkAndIncrementQuota(admin.firestore());
        currentQuota = result.currentQuota;
        quotaExceeded = result.quotaExceeded;
      } catch (counterErr) {
        logger.error("Failed to update daily Gemini counter", counterErr);
      }

      if (quotaExceeded) {
        logger.warn("Gemini daily quota exceeded 1000", { userId });
        response.status(429).json({ error: "Quá giới hạn 1000 lượt gọi AI trong ngày. Vui lòng thử lại vào ngày mai." });
        return;
      }

      // Build prompt for Gemini AI
      const candidatePlacesText = Array.isArray(places) && places.length > 0
        ? places.map((p: any) => `- ID: ${p.id || p.place_id}, Name: ${p.name}, Category: ${p.category || 'attraction'}, Address: ${p.address || ''}, Lat/Lng: ${p.latitude || p.lat}, ${p.longitude || p.lng}`).join('\n')
        : '- Đại Nội Huế (Hoàng Thành)\n- Chùa Thiên Mụ\n- Lăng Khải Định\n- Bún Bò Huế Mụ Rớt\n- Quán Cơm Hến Hoa Đông\n- Cafe Muối Gốc Cố Đô';

      const prompt = `Bạn là chuyên gia thiết kế lộ trình du lịch Cố đô Huế.
Hãy tạo một lộ trình du lịch Huế chi tiết tối ưu nhất dựa trên các yêu cầu:
- Số ngày: ${durationDays} ngày
- Ngân sách ước tính: ${budget} VNĐ
- Sở thích: ${Array.isArray(interests) ? interests.join(", ") : interests}
- Vị trí xuất phát của người dùng: ${userLat}, ${userLng}
- Danh sách địa điểm tham khảo tại Huế:
${candidatePlacesText}${weatherPromptSection}

YÊU CẦU ĐỊNH DẠNG:
Trả về DUY NHẤT một JSON object thuần túy theo đúng schema bên dưới (không kèm markdown \`\`\`json, không có text giải thích trước hoặc sau):
{
  "title": "Tên lộ trình hấp dẫn",
  "description": "Tóm tắt hành trình",
  "duration_days": ${durationDays},
  "budget": ${budget},
  "interests": ${JSON.stringify(interests)},
  "days": [
    {
      "day_number": 1,
      "title": "Tên ngày 1",
      "description": "Mô tả ngày 1",
      "activities": [
        {
          "id": "1",
          "name": "Tên hoạt động",
          "description": "Mô tả trải nghiệm",
          "place_id": "Mã ID địa điểm",
          "place_name": "Tên địa điểm Huế",
          "latitude": 16.4637,
          "longitude": 107.5909,
          "start_time": "08:00",
          "end_time": "10:30",
          "type": "attraction",
          "estimated_cost": 150000,
          "notes": "Lời khuyên khi đi"
        }
      ]
    }
  ]
}`;

      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`;

      // Bounded retry with exponential backoff for 429/RESOURCE_EXHAUSTED
      let aiResponse: Response | null = null;
      const maxRetries = 2;
      for (let attempt = 1; attempt <= maxRetries + 1; attempt++) {
        logger.info(`Sending request to Gemini API (Attempt ${attempt}/${maxRetries + 1})`, { userId });
        aiResponse = await fetch(geminiUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: {
              temperature: 0.7,
              topK: 40,
              topP: 0.95,
              maxOutputTokens: 2048,
              response_mime_type: "application/json",
            },
          }),
        });

        if (aiResponse.ok) break;

        if (aiResponse.status === 429 && attempt <= maxRetries) {
          const delayMs = 1000 * Math.pow(2, attempt - 1);
          logger.warn(`Gemini 429 Rate Limit encountered. Retrying attempt ${attempt} in ${delayMs}ms...`, { userId });
          await new Promise((resolve) => setTimeout(resolve, delayMs));
        } else {
          break;
        }
      }

      if (!aiResponse || !aiResponse.ok) {
        const errorText = aiResponse ? await aiResponse.text() : "No response";
        logger.error("Gemini API error after retries", { status: aiResponse?.status, errorText });
        if (aiResponse?.status === 429) {
          response.status(429).json({ error: "Hệ thống AI Gemini đang quá tải lượt gọi. Hạn mức 1000 RPD sẽ tự động khôi phục." });
          return;
        }
        response.status(500).json({ error: `Lỗi kết nối AI Service (${aiResponse?.status})` });
        return;
      }

      const resJson = await aiResponse.json();
      const rawText = resJson?.candidates?.[0]?.content?.parts?.[0]?.text || "";

      let cleanText = rawText.trim();
      if (cleanText.startsWith("```json")) {
        cleanText = cleanText.substring(7);
      }
      if (cleanText.endsWith("```")) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      const parsedData = JSON.parse(cleanText);

      // Validate structure
      if (!parsedData || typeof parsedData !== "object" || !Array.isArray(parsedData.days)) {
        throw new Error("Dữ liệu JSON từ AI không đúng cấu trúc schema.");
      }

      logger.info("generateItinerary success", {
        durationMs: Date.now() - startTime,
        daysCount: parsedData.days.length,
        currentQuota,
      });

      // Inject currentCount into the response for client to warn
      parsedData.currentCount = currentQuota;

      response.status(200).json(parsedData);
    } catch (e: any) {
      logger.error("generateItinerary failed", { error: e?.message || e });
      response.status(500).json({
        error: "Không thể khởi tạo lộ trình AI. " + (e?.message || ""),
      });
    }
  }
);

/**
 * Cloud Function proxy for self-hosted OSRM Driving Route API
 * Enforces per-user / per-IP rate limits and hides internal OSRM backend URL.
 */
export const getOsrmRoute = onRequest(
  { cors: true },
  async (request, response) => {
    const startTime = Date.now();
    const clientIp = request.ip || request.headers["x-forwarded-for"] || "anonymous";

    // 0. Auth check
    const decodedToken = await verifyAuth(request);
    if (!decodedToken) {
      response.status(401).json({ code: "Unauthorized", message: "Unauthorized. Vui lòng đăng nhập." });
      return;
    }
    const userId = decodedToken.uid;

    logger.info("getOsrmRoute request received", { clientIp, userId, url: request.url });

    // 1. Rate limiting check (60 req/min for routing)
    if (!checkRateLimit(String(userId), 60, 60000)) {
      logger.warn("getOsrmRoute rate limit exceeded", { userId });
      response.status(429).json({
        code: "TooManyRequests",
        message: "Bạn đã vượt quá số lượt yêu cầu chỉ đường cho phép (tối đa 60 lượt/phút).",
      });
      return;
    }

    try {
      // Extract coordinates path from query or URL
      // E.g. /getOsrmRoute?coords=107.5909,16.4637;107.5800,16.4600 or params start & end
      let coordsString = (request.query.coords || request.body?.coords) as string;

      if (!coordsString && request.query.start && request.query.end) {
        coordsString = `${request.query.start};${request.query.end}`;
      }

      if (!coordsString) {
        // Match raw path suffix if passed in URL
        const rawPath = request.url || "";
        const match = rawPath.match(/\/route\/v1\/[a-z]+\/([^?]+)/);
        if (match) {
          coordsString = match[1];
        }
      }

      if (!coordsString) {
        response.status(400).json({
          code: "InvalidQuery",
          message: "Thiếu tham số tọa độ chỉ đường (coords=lng1,lat1;lng2,lat2)",
        });
        return;
      }

      const osrmBackendUrl = process.env.OSRM_BACKEND_URL || "http://127.0.0.1:5000";
      const targetUrl = `${osrmBackendUrl}/route/v1/driving/${coordsString}?overview=full&geometries=geojson`;

      logger.info(`Forwarding OSRM request to self-hosted backend: ${targetUrl}`);

      const osrmResponse = await fetch(targetUrl, {
        method: "GET",
        headers: { Accept: "application/json" },
      });

      if (!osrmResponse.ok) {
        const errText = await osrmResponse.text();
        logger.error("OSRM backend error response", { status: osrmResponse.status, errText });
        response.status(osrmResponse.status).json({
          code: "OsrmError",
          message: `Lỗi từ OSRM Backend Server (${osrmResponse.status})`,
        });
        return;
      }

      const routeJson = await osrmResponse.json();
      logger.info("getOsrmRoute success", {
        durationMs: Date.now() - startTime,
        code: routeJson.code,
      });

      response.status(200).json(routeJson);
    } catch (e: any) {
      logger.error("getOsrmRoute failed", { error: e?.message || e });
      response.status(500).json({
        code: "InternalError",
        message: "Không thể kết nối đến máy chủ OSRM tự host. " + (e?.message || ""),
      });
    }
  }
);

