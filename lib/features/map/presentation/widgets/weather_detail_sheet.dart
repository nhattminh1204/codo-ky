import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/providers/weather_detail_provider.dart';
import 'package:codoky/core/widgets/weather/weather_icon_widget.dart';

/// Format giờ nhanh dạng HH:mm
String _fmtHHmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}


Color _rainColor(int prob) {
  if (prob <= 30) return const Color(0xFF10B981);
  if (prob <= 60) return const Color(0xFFF59E0B);
  return const Color(0xFF2563EB);
}


/// Dynamic Theme Palette tùy chỉnh màu gradient theo trạng thái thời tiết Huế.
class _WeatherThemeConfig {
  final Color bgStart;
  final Color bgEnd;
  final Color accentColor;
  final Color cardBg;

  const _WeatherThemeConfig({
    required this.bgStart,
    required this.bgEnd,
    required this.accentColor,
    required this.cardBg,
  });

  factory _WeatherThemeConfig.fromCode(int code, bool isDark) {
    if (isDark) {
      return const _WeatherThemeConfig(
        bgStart: Color(0xFF0F172A),
        bgEnd: Color(0xFF1E1B4B),
        accentColor: Color(0xFF38BDF8),
        cardBg: Color(0xFF1E293B),
      );
    }
    // Sunny
    if (code == 0 || code == 1) {
      return const _WeatherThemeConfig(
        bgStart: Color(0xFFFFFBEB),
        bgEnd: Color(0xFFEFF6FF),
        accentColor: Color(0xFFD97706),
        cardBg: Colors.white,
      );
    }
    // Rain / Storm
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 99)) {
      return const _WeatherThemeConfig(
        bgStart: Color(0xFFF0F9FF),
        bgEnd: Color(0xFFE0F2FE),
        accentColor: Color(0xFF2563EB),
        cardBg: Colors.white,
      );
    }
    // Cloudy / Fog / Fallback
    return const _WeatherThemeConfig(
      bgStart: Color(0xFFF8FAFC),
      bgEnd: Color(0xFFF1F5F9),
      accentColor: Color(0xFF0284C7),
      cardBg: Colors.white,
    );
  }
}

/// Full-feature Weather & Travel Companion Sheet.
/// DraggableScrollableSheet với 2 snap points: Basic Summary (38%) -> Advanced View (90%).
class WeatherDetailSheet extends ConsumerStatefulWidget {
  const WeatherDetailSheet({super.key});

  @override
  ConsumerState<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends ConsumerState<WeatherDetailSheet> {
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _refreshAllWeather(force: false);
    });
    // Cập nhật thời tiết liên tục mỗi 2 phút khi bảng thông tin thời tiết đang mở
    _periodicTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _refreshAllWeather(force: true);
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }

  void _refreshAllWeather({bool force = true}) {
    ref.read(weatherDetailProvider.notifier).loadDetail(forceRefresh: force);
    ref.read(currentWeatherProvider.notifier).refreshIfNeeded(
          const LatLng(16.4637, 107.5909),
          force: force,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.42,
      minChildSize: 0.42,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.42, 0.90],
      builder: (context, scrollController) {
        return _SheetBody(
          scrollController: scrollController,
          isDark: isDark,
          l10n: l10n,
        );
      },
    );
  }
}

class _SheetBody extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final bool isDark;
  final AppLocalizations l10n;

  const _SheetBody({
    required this.scrollController,
    required this.isDark,
    required this.l10n,
  });

  @override
  ConsumerState<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends ConsumerState<_SheetBody> {
  HourlyWeather? _selectedHour;

  AppLocalizations get l10n => widget.l10n;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final l10n = widget.l10n;
    final currentState = ref.watch(currentWeatherProvider);
    final detailState = ref.watch(weatherDetailProvider);

    final currentWeatherObj = currentState.currentWeather.valueOrNull;
    final weatherCode = _selectedHour?.weatherCode ?? currentWeatherObj?.weatherCode ?? 0;
    final themeConfig = _WeatherThemeConfig.fromCode(weatherCode, isDark);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [themeConfig.bgStart, themeConfig.bgEnd],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Drag Handle ---
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          // --- Scrollable Content ---
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // 1. Header: Vị trí
                _buildHeader(isDark),
                const SizedBox(height: 10),

                // 2. Hero: Nhiệt độ + Mô tả ngắn
                currentState.currentWeather.when(
                  data: (w) => _buildHero(
                    w,
                    detailState,
                    isDark,
                    themeConfig,
                  ),
                  loading: () => _buildShimmer(height: 90, isDark: isDark),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),

                // 3. Gợi ý trải nghiệm Huế
                _buildSmartTravelAdvisor(
                  currentWeatherObj,
                  detailState.detail.valueOrNull,
                  isDark,
                  themeConfig,
                ),
                const SizedBox(height: 36),

                // 4. Hourly Forecast (Dự báo hôm nay 24h)
                _buildSectionTitle(l10n.weatherHourlyForecast, isDark),
                const SizedBox(height: 10),
                detailState.detail.when(
                  data: (d) => _buildHourlyRow(
                    d.hourly,
                    isDark,
                    themeConfig.cardBg,
                  ),
                  loading: () => _buildShimmer(height: 118, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 16),

                // 5. Thông số nâng cao (Stats Grid: Độ ẩm, Tốc độ gió, UV, AQI)
                _buildSectionTitle(l10n.weatherAdvancedMetrics, isDark),
                const SizedBox(height: 8),
                detailState.detail.when(
                  data: (d) => _buildStatsGrid(d, isDark, themeConfig.cardBg),
                  loading: () => _buildShimmer(height: 180, isDark: isDark),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 10),

                // 6. Daily Forecast (7 Ngày tới)
                _buildSectionTitle(l10n.weatherDailyForecast, isDark),
                const SizedBox(height: 6),
                detailState.forecast.when(
                  data: (f) => _buildDailyList(f.days, isDark, themeConfig.cardBg),
                  loading: () => _buildShimmer(height: 260, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.weatherLocationHue,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ── 2. Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHero(
    CurrentWeatherResult w,
    WeatherDetailState detailState,
    bool isDark,
    _WeatherThemeConfig themeConfig,
  ) {
    final displayThemeColor = WmoCodeMapper.toThemeColor(w.weatherCode);
    final feelsLike = detailState.detail.valueOrNull?.feelsLike;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WeatherIconWidget(
          weatherCode: w.weatherCode,
          size: 76,
          timestamp: DateTime.now(),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${w.temperature.round()}',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    height: 1.0,
                  ),
                ),
                Text(
                  '°C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            if (feelsLike != null)
              Text(
                l10n.weatherFeelsLike(feelsLike.round()),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : const Color(0xFF64748B),
                ),
              ),
          ],
        ),
        const Spacer(),
        // Label trạng thái thời tiết
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color(displayThemeColor).withValues(alpha: isDark ? 0.25 : 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(displayThemeColor).withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(displayThemeColor).withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            w.weatherLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. 🌿 GỢI Ý TRẢI NGHIỆM HUẾ ──────────────────────────────────────────
  Widget _buildSmartTravelAdvisor(
    CurrentWeatherResult? current,
    WeatherDetailResult? detail,
    bool isDark,
    _WeatherThemeConfig themeConfig,
  ) {
    final rainProb = detail?.hourly.isNotEmpty == true
        ? detail!.hourly
            .take(4)
            .map((h) => h.precipitationProbability)
            .reduce(math.max)
        : 0;
    final uvIndex = detail?.uvIndex ?? 2.0;
    final temp = current?.temperature ?? 28.0;

    // Phân tích điều kiện du lịch
    final isRainy = rainProb >= 45 || (current != null && current.weatherCode >= 51);
    final isSunnyHot = temp >= 32.0 || uvIndex >= 6.0;
    final isCool = temp <= 22.0;

    final varIndex = (DateTime.now().hour + (current?.weatherCode ?? 0));
    final String adviceText;
    final List<String> badges = [];

    if (isRainy) {
      adviceText = l10n.travelAdvisorRainAdviceVar(varIndex);
      final rIdx = varIndex % 4;
      if (rIdx == 0) {
        badges.add('☕ Cà phê Muối Cố đô');
        badges.add('🎵 Ca Huế sông Hương');
      } else if (rIdx == 1) {
        badges.add('🏛️ ${l10n.travelAdvisorIndoorPriority}');
        badges.add('🍜 Bún bò Huế nóng');
      } else if (rIdx == 2) {
        badges.add('⛪ Nhà thờ Phủ Cam');
        badges.add('🥟 Bánh lọc nóng');
      } else {
        badges.add('🛕 Chùa Từ Hiếu');
        badges.add('🔔 Tiếng chuông tĩnh tâm');
      }
    } else if (isSunnyHot) {
      adviceText = l10n.travelAdvisorSunnyAdviceVar(varIndex);
      final sIdx = varIndex % 3;
      if (sIdx == 0) {
        badges.add('🌅 Bình minh Đại Nội');
        badges.add('🌇 Hoàng hôn Đồi Vọng Cảnh');
      } else if (sIdx == 1) {
        badges.add('📸 Lăng Khải Định');
        badges.add(l10n.travelAdvisorCoolChe);
      } else {
        badges.add('🏡 Vỹ Dạ Xưa Cafe');
        badges.add('🕶️ ${l10n.travelAdvisorSunProtection}');
      }
    } else if (isCool) {
      adviceText = l10n.travelAdvisorCoolAdviceVar(varIndex);
      final cIdx = varIndex % 2;
      if (cIdx == 0) {
        badges.add('🥖 Bánh mì Tràng Tiền');
        badges.add(l10n.travelAdvisorThinJacket);
      } else {
        badges.add('🍁 Lăng Tự Đức');
        badges.add(l10n.travelAdvisorLotusTea);
      }
    } else {
      adviceText = l10n.travelAdvisorIdealAdviceVar(varIndex);
      final iIdx = varIndex % 2;
      if (iIdx == 0) {
        badges.add('👘 Áo dài Cố đô');
        badges.add(l10n.travelAdvisorDragonBoat);
      } else {
        badges.add('🚣 Đầm Chuồn Tam Giang');
        badges.add('🌲 Rừng đước Rú Cha');
      }
    }

    // Dynamic accent color for the tip card icon frame based on weather condition
    final Color tipIconAccent;
    if (isRainy) {
      tipIconAccent = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7); // Sky Blue (Rainy)
    } else if (isSunnyHot) {
      tipIconAccent = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706); // Golden Amber (Sunny)
    } else if (isCool) {
      tipIconAccent = isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // Emerald Green (Cool)
    } else {
      tipIconAccent = AppColors.primary; // Royal Blue (Ideal)
    }

    final cardBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? themeConfig.accentColor.withValues(alpha: 0.3)
        : AppColors.primary.withValues(alpha: 0.2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột trái: Icon Container nổi bật (Đổi màu động theo thời tiết)
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tipIconAccent.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: tipIconAccent.withValues(alpha: 0.30),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: tipIconAccent.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              size: 28,
              color: tipIconAccent,
            ),
          ),
          const SizedBox(width: 12),

          // Cột phải: Content (Tiêu đề + Nội dung khuyên + Badges)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.travelAdvisorTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  adviceText,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: badges.map((b) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? themeConfig.accentColor.withValues(alpha: 0.15)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? themeConfig.accentColor.withValues(alpha: 0.3)
                              : const Color(0xFFBFDBFE),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        b,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? themeConfig.accentColor
                              : const Color(0xFF1D4ED8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Stats Grid (3-Tier Bento Glass Style) ──────────────────────────────
  Widget _buildStatsGrid(
      WeatherDetailResult d, bool isDark, Color cardColor) {
    final humidity = d.current.humidity.round();
    final windSpeed = d.windSpeed;
    final uvIndex = d.uvIndex;
    final aqi = d.aqi ?? 65;

    // Xác định giờ hiện tại: ban đêm 20h–05h → UV = 0 là bình thường, ẩn card thật
    final nowHour = DateTime.now().hour;
    final isNighttime = nowHour >= 20 || nowHour < 6;

    // Multi-stop rainbow spectrum gradient color definitions
    final greenColor = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
    final amberColor = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
    final orangeColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
    final redColor = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

    // 1. Độ ẩm (Humidity) - Thang 0-100%
    final String humidityStatus = humidity > 85
        ? l10n.statusHumidityHigh
        : (humidity < 40
            ? l10n.statusHumidityLow
            : (humidity > 70 ? l10n.statusHumidityModerate : l10n.statusHumidityGood));
    final String humidityInsight = humidity > 85
        ? l10n.insightHumidityHigh
        : (humidity < 40
            ? l10n.insightHumidityLow
            : (humidity > 70
                ? l10n.insightHumidityModerate
                : l10n.insightHumidityGood));

    // 2. Tốc độ gió (Wind) - Reference Max: 40 km/h
    final String windStatus = windSpeed > 25.0
        ? l10n.statusWindHigh
        : (windSpeed >= 12.0 ? l10n.statusWindModerate : l10n.statusWindGood);
    final String windInsight = windSpeed > 25.0
        ? l10n.insightWindHigh
        : (windSpeed >= 12.0
            ? l10n.insightWindModerate
            : l10n.insightWindGood);

    // 3. Chỉ số UV - Reference Max: 11
    final String uvStatus = uvIndex >= 7.0
        ? l10n.statusUvHigh
        : (uvIndex >= 3.0 ? l10n.statusUvModerate : l10n.statusUvGood);
    final String uvInsight = uvIndex >= 7.0
        ? l10n.insightUvHigh
        : (uvIndex >= 3.0 ? l10n.insightUvModerate : l10n.insightUvGood);

    // 4. Chất lượng không khí (AQI) - Reference Max: 200
    final String aqiStatus = aqi > 100
        ? l10n.statusAqiUnhealthy
        : (aqi > 50 ? l10n.statusAqiModerate : l10n.statusAqiGood);
    final String aqiInsight = aqi > 100
        ? l10n.insightAqiUnhealthy
        : (aqi > 50 ? l10n.insightAqiModerate : l10n.insightAqiGood);

    // Màu sắc cố định đặc trưng theo đối tượng (Fixed Brand Signature Colors)
    // 1. Độ ẩm (Humidity) 💧: Ocean Sky Blue
    final humidityAccent = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final humidityBg = isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE);

    // 2. Tốc độ gió (Wind) 💨: Warm Sunset Orange
    final windAccent = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
    final windBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFFEDD5);

    // 3. Chỉ số UV (UV Index) ☀️: Golden Sun Amber
    final uvAccent = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    final uvBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);

    // 4. Chất lượng không khí (AQI) 🍃: Fresh Emerald Green
    final aqiAccent = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final aqiBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);

    // 5. Purple color definition for extreme AQI & UV
    final purpleColor = isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA);

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _bentoStatCard(
                  icon: Icons.water_drop_rounded,
                  accentColor: humidityAccent,
                  iconBgColor: humidityBg,
                  label: l10n.weatherHumidity,
                  value: '$humidity%',
                  statusSubtitle: humidityStatus,
                  insightText: humidityInsight,
                  progressValue: (humidity / 100.0).clamp(0.0, 1.0),
                  isDark: isDark,
                  gradientColors: [amberColor, greenColor, amberColor, redColor],
                  gradientStops: const [0.0, 0.45, 0.75, 1.0],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _bentoStatCard(
                  icon: Icons.air_rounded,
                  accentColor: windAccent,
                  iconBgColor: windBg,
                  label: l10n.weatherWind,
                  value: l10n.weatherWindUnit(windSpeed),
                  statusSubtitle: windStatus,
                  insightText: windInsight,
                  progressValue: (windSpeed / 60.0).clamp(0.0, 1.0),
                  isDark: isDark,
                  gradientColors: [greenColor, amberColor, orangeColor, redColor],
                  gradientStops: const [0.0, 0.25, 0.50, 1.0],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: isNighttime
                    ? _bentoNightUvCard(isDark: isDark)
                    : _bentoStatCard(
                        icon: Icons.wb_sunny_rounded,
                        accentColor: uvAccent,
                        iconBgColor: uvBg,
                        label: l10n.weatherUvIndex,
                        value: 'UV ${uvIndex.toStringAsFixed(1)}',
                        statusSubtitle: uvStatus,
                        insightText: uvInsight,
                        progressValue: (uvIndex / 12.0).clamp(0.0, 1.0),
                        isDark: isDark,
                        gradientColors: [greenColor, amberColor, orangeColor, redColor, purpleColor],
                        gradientStops: const [0.0, 0.25, 0.50, 0.67, 1.0],
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _bentoStatCard(
                  icon: Icons.eco_rounded,
                  accentColor: aqiAccent,
                  iconBgColor: aqiBg,
                  label: l10n.weatherAirQuality,
                  value: 'AQI $aqi',
                  statusSubtitle: aqiStatus,
                  insightText: aqiInsight,
                  progressValue: (aqi / 300.0).clamp(0.0, 1.0),
                  isDark: isDark,
                  gradientColors: [greenColor, amberColor, orangeColor, redColor, purpleColor],
                  gradientStops: const [0.0, 0.17, 0.33, 0.50, 1.0],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card placeholder UV ban đêm — thay "UV 0.0" bằng thông báo thân thiện
  Widget _bentoNightUvCard({required bool isDark}) {
    final bgColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.90);
    final nightAccent = isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: nightAccent.withValues(alpha: 0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: nightAccent.withValues(alpha: isDark ? 0.12 : 0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        size: 15,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.weatherUvIndex,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌙', style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: nightAccent.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.weatherNighttime,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: nightAccent,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 5,
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: nightAccent.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 28,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 11,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          l10n.weatherNightUvInsight,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bentoStatCard({
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required String statusSubtitle,
    required String insightText,
    required double progressValue,
    required bool isDark,
    required List<Color> gradientColors,
    required List<double> gradientStops,
  }) {
    final baseBg = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final borderColor = accentColor.withValues(alpha: isDark ? 0.25 : 0.18);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
            decoration: BoxDecoration(
              color: baseBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.14 : 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tầng 1: Icon + Label
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, size: 15, color: accentColor),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tầng 2: Số liệu chính & Subhead Chip
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.8,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Tầng 3: Progress bar gradient (Uncompressed Full-Width Spectrum Clipping)
                SizedBox(
                  height: 5,
                  width: double.infinity,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final filledWidth = totalWidth * progressValue.clamp(0.0, 1.0);

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 5,
                            width: totalWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                colors: gradientColors.map((c) => c.withValues(alpha: 0.20)).toList(),
                                stops: gradientStops,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                              height: 5,
                              width: filledWidth,
                              child: OverflowBox(
                                alignment: Alignment.centerLeft,
                                minWidth: totalWidth,
                                maxWidth: totalWidth,
                                child: Container(
                                  height: 5,
                                  width: totalWidth,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      stops: gradientStops,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Tầng 4: Insight text với chiều cao cố định 28px
                SizedBox(
                  height: 28,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.tips_and_updates_rounded,
                          size: 11,
                          color: accentColor.withValues(alpha: 0.70),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          insightText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ── 5. Hourly Row (24h Slider) ───────────────────────────────────────────────
  Widget _buildHourlyRow(
      List<HourlyWeather> hourly, bool isDark, Color cardColor) {
    final now = DateTime.now();
    final filtered = hourly
        .where((h) {
          final diff = h.time.difference(now).inMinutes;
          return diff >= -30 && diff <= 24 * 60;
        })
        .toList();

    if (filtered.isEmpty) return _buildErrorChip(isDark);

    // Bọc trong Stack để thêm fade-out gradient gợi ý scroll bên phải
    return SizedBox(
      height: 128,
      child: Stack(
        children: [
          ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filtered.length,
            separatorBuilder: (context, i) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final h = filtered[i];
              final isNow = (h.time.difference(now).inMinutes).abs() <= 30;
              final isSelected = _selectedHour != null
                  ? (_selectedHour!.time == h.time)
                  : isNow;

              return _HourlyCardWidget(
                hourly: h,
                isNow: isNow,
                isSelected: isSelected,
                isDark: isDark,
                cardColor: cardColor,
                onTap: () {
                  setState(() {
                    if (_selectedHour?.time == h.time) {
                      _selectedHour = null;
                    } else {
                      _selectedHour = h;
                    }
                  });
                },
              );
            },
          ),
          // Fade gradient bên phải → hint scroll
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 40,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
                          .withValues(alpha: 0.0),
                      (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC))
                          .withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Daily 7-Day Forecast List ─────────────────────────────────────────────
  Widget _buildDailyList(
      List<DayWeatherForecast> days, bool isDark, Color cardColor) {
    final limit = math.min(days.length, 7);
    if (limit == 0) return _buildErrorChip(isDark);

    // Tính min và max nhiệt độ của cả 7 ngày để scale thanh range bar chuẩn tuyệt đối
    double globalMin = days[0].tempMin;
    double globalMax = days[0].tempMax;
    for (int i = 0; i < limit; i++) {
      if (days[i].tempMin < globalMin) globalMin = days[i].tempMin;
      if (days[i].tempMax > globalMax) globalMax = days[i].tempMax;
    }
    final totalSpan = (globalMax - globalMin).clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(limit, (i) {
          final d = days[i];
          final dayLabel = _fmtDailyLabel(i, d.date);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Cột 1: Tên ngày (vd: Hôm nay, Thứ Hai...)
                SizedBox(
                  width: 82,
                  child: Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),

                // Cột 2: Icon thời tiết + % Khả năng mưa
                SizedBox(
                  width: 62,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WeatherIconWidget(
                        weatherCode: d.weatherCode,
                        size: 20,
                        isNight: false,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${d.rainProbability}%',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Cột 3: Nhiệt độ thấp nhất
                SizedBox(
                  width: 32,
                  child: Text(
                    '${d.tempMin.round()}°',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Cột 4: Thanh Range Bar dải nhiệt độ (Gradient Xanh -> Cam)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final trackWidth = constraints.maxWidth;
                      final minRatio = ((d.tempMin - globalMin) / totalSpan).clamp(0.0, 1.0);
                      final maxRatio = ((d.tempMax - globalMin) / totalSpan).clamp(0.0, 1.0);

                      final leftPos = trackWidth * minRatio;
                      final barWidth = ((maxRatio - minRatio) * trackWidth).clamp(8.0, trackWidth);

                      return SizedBox(
                        height: 4.5,
                        child: Stack(
                          children: [
                            // Track nền xám nhạt
                            Container(
                              width: double.infinity,
                              height: 4.5,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(2.25),
                              ),
                            ),
                            // Đoạn nhiệt độ của ngày (Gradient Xanh -> Cam)
                            Positioned(
                              left: leftPos,
                              width: barWidth,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2.25),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFFF59E0B)],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Cột 5: Nhiệt độ cao nhất
                SizedBox(
                  width: 32,
                  child: Text(
                    '${d.tempMax.round()}°',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _fmtDailyLabel(int index, DateTime date) {
    if (index == 0) return l10n.weatherToday;
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildShimmer({required double height, required bool isDark}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildErrorChip(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFFEF4444)),
          SizedBox(width: 8),
          Text(
            'Không thể tải dữ liệu thời tiết',
            style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }
}

class _HourlyCardWidget extends StatefulWidget {
  final HourlyWeather hourly;
  final bool isNow;
  final bool isSelected;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;

  const _HourlyCardWidget({
    required this.hourly,
    required this.isNow,
    required this.isSelected,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
  });

  @override
  State<_HourlyCardWidget> createState() => _HourlyCardWidgetState();
}

class _HourlyCardWidgetState extends State<_HourlyCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hourly;
    final isDark = widget.isDark;
    final timeLabel = widget.isNow ? 'Now' : _fmtHHmm(h.time);

    final isSelected = widget.isSelected;
    final isHovered = _isHovered && !isSelected;

    final rainColor = isSelected
        ? const Color(0xFF7DD3FC)
        : _rainColor(h.precipitationProbability);

    final BoxDecoration bgDecoration;
    if (isSelected) {
      bgDecoration = BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isHovered) {
      bgDecoration = BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } else {
      bgDecoration = BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    final timeColor = isSelected
        ? Colors.white
        : (isHovered
            ? const Color(0xFF2563EB)
            : (isDark ? Colors.white60 : const Color(0xFF64748B)));

    final tempColor = isSelected
        ? Colors.white
        : (isHovered
            ? (isDark ? Colors.white : const Color(0xFF2563EB))
            : (isDark ? Colors.white : const Color(0xFF0F172A)));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: bgDecoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : (isHovered ? FontWeight.w700 : FontWeight.w600),
                  color: timeColor,
                ),
              ),
              WeatherIconWidget(
                weatherCode: h.weatherCode,
                size: 38,
                timestamp: h.time,
              ),
              // Temperature: WHITE when selected, vibrant when hovered
              Text(
                '${h.temperature.round()}°',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: tempColor,
                ),
              ),
              // Rain probability
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (h.precipitationProbability > 20)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 9,
                        color: rainColor,
                      ),
                    ),
                  Text(
                    '${h.precipitationProbability}%',
                    style: TextStyle(
                      fontSize: h.precipitationProbability > 40 ? 12 : 10.5,
                      fontWeight: h.precipitationProbability > 40
                          ? FontWeight.w800
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (h.precipitationProbability > 0
                              ? rainColor
                              : (isDark ? Colors.white30 : const Color(0xFFCBD5E1))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget bọc hiệu ứng phản hồi chạm Micro-interaction nảy (pressScale = 0.96, 150ms)
class _PressableCard extends StatefulWidget {
  final Widget child;

  const _PressableCard({required this.child});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? AppMotion.pressScale : 1.0,
        duration: AppMotion.micro,
        curve: AppMotion.standardCurve,
        child: widget.child,
      ),
    );
  }
}
