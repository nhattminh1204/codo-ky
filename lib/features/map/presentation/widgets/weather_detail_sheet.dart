import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Format ngày dạng "T2, 5/8"
String _fmtShortDay(DateTime dt) {
  const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return '${days[dt.weekday % 7]}, ${dt.day}/${dt.month}';
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
/// DraggableScrollableSheet với 2 snap points: Basic View (45%) -> Advanced View (90%).
class WeatherDetailSheet extends ConsumerStatefulWidget {
  const WeatherDetailSheet({super.key});

  @override
  ConsumerState<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends ConsumerState<WeatherDetailSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(weatherDetailProvider.notifier).loadDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.46,
      minChildSize: 0.46,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.46, 0.90],
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

class _SheetBody extends ConsumerWidget {
  final ScrollController scrollController;
  final bool isDark;
  final AppLocalizations l10n;

  const _SheetBody({
    required this.scrollController,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(currentWeatherProvider);
    final detailState = ref.watch(weatherDetailProvider);

    final currentWeatherObj = currentState.currentWeather.valueOrNull;
    final weatherCode = currentWeatherObj?.weatherCode ?? 0;
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
              controller: scrollController,
              // Tăng bottom padding lên 120px để KHÔNG bị che lấp bởi Liquid Glass Navigation Capsule
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // 1. Header: Vị trí + Time
                _buildHeader(currentState, isDark),
                const SizedBox(height: 14),

                // 2. Hero: Nhiệt độ + Mô tả ngắn
                currentState.currentWeather.when(
                  data: (w) => _buildHero(w, detailState, isDark, themeConfig),
                  loading: () => _buildShimmer(height: 100, isDark: isDark),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // 3. 🤖 AI SMART TRAVEL ADVISOR CARD (Đặc quyền CodoKy)
                _buildSmartTravelAdvisor(
                  currentWeatherObj,
                  detailState.detail.valueOrNull,
                  isDark,
                  themeConfig,
                ),
                const SizedBox(height: 18),

                // 4. Stats Grid: 2x2 Glass Cards
                detailState.detail.when(
                  data: (d) => _buildStatsGrid(d, isDark, themeConfig.cardBg),
                  loading: () => _buildShimmer(height: 90, isDark: isDark),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // 5. Hourly Forecast (24h Slider)
                _buildSectionTitle(l10n.weatherHourlyForecast, isDark),
                const SizedBox(height: 10),
                detailState.detail.when(
                  data: (d) => _buildHourlyRow(d.hourly, isDark, themeConfig.cardBg),
                  loading: () => _buildShimmer(height: 118, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 24),

                // 6. Daily Forecast (7 Ngày tới)
                _buildSectionTitle(l10n.weatherDailyForecast, isDark),
                const SizedBox(height: 10),
                detailState.forecast.when(
                  data: (f) => _buildDailyList(f.days, isDark, themeConfig.cardBg),
                  loading: () => _buildShimmer(height: 260, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 24),

                // Nút đóng sheet
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                    label: Text(
                      l10n.weatherClose,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(CurrentWeatherState state, bool isDark) {
    final timeStr = state.lastFetchedAt != null
        ? _fmtHHmm(state.lastFetchedAt!)
        : '';
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);

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
        const Spacer(),
        if (timeStr.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.weatherUpdatedAt(timeStr),
              style: TextStyle(fontSize: 11.5, color: subtitleColor),
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
            color: Color(w.themeColor).withValues(alpha: isDark ? 0.25 : 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(w.themeColor).withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(w.themeColor).withValues(alpha: 0.2),
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

  // ── 3. 🤖 AI SMART TRAVEL ADVISOR CARD (Đặc quyền Du lịch Huế) ──────────────────
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

    final String adviceText;
    final List<String> badges = [];

    if (isRainy) {
      adviceText = l10n.travelAdvisorRainAdvice(rainProb > 0 ? rainProb : 60);
      badges.add('☔ ${l10n.travelAdvisorBringUmbrella}');
      badges.add('🏛️ ${l10n.travelAdvisorIndoorPriority}');
    } else if (isSunnyHot) {
      adviceText = l10n.travelAdvisorSunnyAdvice(uvIndex);
      badges.add('👒 ${l10n.travelAdvisorSunProtection}');
      badges.add('🥤 Giải nhiệt Chè Huế');
    } else if (isCool) {
      adviceText = l10n.travelAdvisorCoolAdvice;
      badges.add('🧥 Áo khoác mỏng');
      badges.add('☕ Trà sen Cố đô');
    } else {
      adviceText = l10n.travelAdvisorIdealAdvice;
      badges.add('🌿 ${l10n.travelAdvisorOutdoorIdeal}');
      badges.add('🐉 Thuyền Rồng Sông Hương');
    }

    final cardBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? themeConfig.accentColor.withValues(alpha: 0.4)
        : AppColors.primary.withValues(alpha: 0.3);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B1522), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.travelAdvisorTitle,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF8B1522),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

    // Helper for semantic color palette based on level (0 = Green, 1 = Amber, 2 = Red)
    Color getSemanticColor(int level) {
      if (isDark) {
        if (level == 0) return const Color(0xFF34D399); // Emerald
        if (level == 1) return const Color(0xFFFBBF24); // Amber
        return const Color(0xFFF87171); // Crimson
      } else {
        if (level == 0) return const Color(0xFF059669); // Emerald
        if (level == 1) return const Color(0xFFD97706); // Amber
        return const Color(0xFFDC2626); // Crimson
      }
    }

    Color getIconBgColor(int level) {
      if (isDark) {
        if (level == 0) return const Color(0xFF064E3B);
        if (level == 1) return const Color(0xFF451A03);
        return const Color(0xFF450A0A);
      } else {
        if (level == 0) return const Color(0xFFD1FAE5);
        if (level == 1) return const Color(0xFFFEF3C7);
        return const Color(0xFFFEE2E2);
      }
    }

    // 1. Độ ẩm (Humidity) - Thang 0-100% (Gradient 4 mốc: Đỏ 0-40% -> Xanh 40-70% -> Vàng 70-85% -> Đỏ 85-100%)
    final int humidityLevel = (humidity > 85 || humidity < 40)
        ? 2
        : (humidity > 70 ? 1 : 0);
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
    final int windLevel = windSpeed > 25.0 ? 2 : (windSpeed >= 12.0 ? 1 : 0);
    final String windStatus = windSpeed > 25.0
        ? l10n.statusWindHigh
        : (windSpeed >= 12.0 ? l10n.statusWindModerate : l10n.statusWindGood);
    final String windInsight = windSpeed > 25.0
        ? l10n.insightWindHigh
        : (windSpeed >= 12.0
            ? l10n.insightWindModerate
            : l10n.insightWindGood);

    // 3. Chỉ số UV - Reference Max: 11
    final int uvLevel = uvIndex >= 7.0 ? 2 : (uvIndex >= 3.0 ? 1 : 0);
    final String uvStatus = uvIndex >= 7.0
        ? l10n.statusUvHigh
        : (uvIndex >= 3.0 ? l10n.statusUvModerate : l10n.statusUvGood);
    final String uvInsight = uvIndex >= 7.0
        ? l10n.insightUvHigh
        : (uvIndex >= 3.0 ? l10n.insightUvModerate : l10n.insightUvGood);

    // 4. Chất lượng không khí (AQI) - Reference Max: 200
    final int aqiLevel = aqi > 100 ? 2 : (aqi > 50 ? 1 : 0);
    final String aqiStatus = aqi > 100
        ? l10n.statusAqiUnhealthy
        : (aqi > 50 ? l10n.statusAqiModerate : l10n.statusAqiGood);
    final String aqiInsight = aqi > 100
        ? l10n.insightAqiUnhealthy
        : (aqi > 50 ? l10n.insightAqiModerate : l10n.insightAqiGood);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.22,
      children: [
        // 1. Độ ẩm (Dải màu cầu vồng 4 mốc: Đỏ -> Xanh -> Vàng -> Đỏ)
        _bentoStatCard(
          icon: Icons.water_drop_rounded,
          accentColor: getSemanticColor(humidityLevel),
          iconBgColor: getIconBgColor(humidityLevel),
          label: l10n.weatherHumidity,
          value: '$humidity%',
          statusSubtitle: humidityStatus,
          insightText: humidityInsight,
          progressValue: (humidity / 100.0).clamp(0.0, 1.0),
          isDark: isDark,
          gradientColors: [redColor, greenColor, amberColor, redColor],
          gradientStops: const [0.0, 0.40, 0.70, 1.0],
        ),
        // 2. Tốc độ gió (Dải màu cầu vồng 3 mốc)
        _bentoStatCard(
          icon: Icons.air_rounded,
          accentColor: getSemanticColor(windLevel),
          iconBgColor: getIconBgColor(windLevel),
          label: l10n.weatherWind,
          value: l10n.weatherWindUnit(windSpeed),
          statusSubtitle: windStatus,
          insightText: windInsight,
          progressValue: (windSpeed / 40.0).clamp(0.0, 1.0),
          isDark: isDark,
          gradientColors: [greenColor, amberColor, redColor],
          gradientStops: const [0.0, 0.40, 1.0],
        ),
        // 3. Chỉ số UV — hiện badge ban đêm nếu đang là đêm (không có UV thật)
        isNighttime
            ? _bentoNightUvCard(isDark: isDark)
            : _bentoStatCard(
                icon: Icons.wb_sunny_rounded,
                accentColor: getSemanticColor(uvLevel),
                iconBgColor: getIconBgColor(uvLevel),
                label: l10n.weatherUvIndex,
                value: 'UV ${uvIndex.toStringAsFixed(1)}',
                statusSubtitle: uvStatus,
                insightText: uvInsight,
                progressValue: (uvIndex / 11.0).clamp(0.0, 1.0),
                isDark: isDark,
                gradientColors: [greenColor, amberColor, orangeColor, redColor],
                gradientStops: const [0.0, 0.30, 0.65, 1.0],
              ),
        // 4. Chất lượng không khí (Dải màu cầu vồng 3 mốc)
        _bentoStatCard(
          icon: Icons.eco_rounded,
          accentColor: getSemanticColor(aqiLevel),
          iconBgColor: getIconBgColor(aqiLevel),
          label: l10n.weatherAirQuality,
          value: 'AQI $aqi',
          statusSubtitle: aqiStatus,
          insightText: aqiInsight,
          progressValue: (aqi / 200.0).clamp(0.0, 1.0),
          isDark: isDark,
          gradientColors: [greenColor, amberColor, redColor],
          gradientStops: const [0.0, 0.35, 1.0],
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
    final nightBg = isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEDE9FE);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: nightAccent.withValues(alpha: 0.15), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: nightAccent.withValues(alpha: isDark ? 0.12 : 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        color: nightBg,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(Icons.nightlight_round, size: 15, color: nightAccent),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.weatherUvIndex,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Text('🌙', style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 2),
                      Text(
                        'Ban đêm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: nightAccent,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 11,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'UV không đo được ban đêm',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
    // Nền cơ bản + tint nhẹ theo màu accent (ngựy hiểm cao → màu đậu lạt)
    final baseBg = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final tintBg = accentColor.withValues(alpha: isDark ? 0.08 : 0.05);
    final borderColor = accentColor.withValues(alpha: isDark ? 0.28 : 0.20);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
            decoration: BoxDecoration(
              color: baseBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Tint nền nhẹ theo màu semantic
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: tintBg,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tầng 1: Icon + Label
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 16, color: accentColor),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white60 : const Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Tầng 2: Số liệu chính
                    Center(
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.8,
                          height: 1.0,
                        ),
                      ),
                    ),

                    // Tầng 3: Status pill chip màu semantic
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Tầng 4: Progress bar gradient
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final trackWidth = constraints.maxWidth;
                        final fillWidth = (trackWidth * progressValue).clamp(0.0, trackWidth);

                        return SizedBox(
                          height: 5,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: 5,
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
                                child: Container(
                                  width: fillWidth,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                      stops: gradientStops,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Tầng 5: Insight text (sạch hơn, không in nghiêng)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.tips_and_updates_rounded,
                            size: 10,
                            color: accentColor.withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            insightText,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
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
            itemBuilder: (_, i) {
              final h = filtered[i];
              final isNow = (h.time.difference(now).inMinutes).abs() <= 30;
              return _hourlyCard(h, isNow, isDark, cardColor);
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

  Widget _hourlyCard(
      HourlyWeather h, bool isNow, bool isDark, Color cardColor) {
    final timeLabel = isNow ? 'Now' : _fmtHHmm(h.time);
    final rainColor = isNow ? const Color(0xFF7DD3FC) : _rainColor(h.precipitationProbability);

    final bgDecoration = isNow
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
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

    return _PressableCard(
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
              fontWeight: isNow ? FontWeight.w800 : FontWeight.w600,
              color: isNow
                  ? Colors.white
                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
          WeatherIconWidget(
            weatherCode: h.weatherCode,
            size: 38,
            timestamp: h.time,
          ),
          Text(
            '${h.temperature.round()}°',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          // % mưa — to hơn, kèm biểu tượng mưa nếu > 20%
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
                  color: h.precipitationProbability > 0
                      ? rainColor
                      : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // ── 6. Daily 7-Day Forecast List ─────────────────────────────────────────────
  Widget _buildDailyList(
      List<DayWeatherForecast> days, bool isDark, Color cardColor) {
    final limit = math.min(days.length, 7);

    // Tìm index ngày mưa nhiều nhất trong 7 ngày → highlight
    int rainiestIdx = 0;
    int maxRain = 0;
    for (int i = 0; i < limit; i++) {
      if (days[i].rainProbability > maxRain) {
        maxRain = days[i].rainProbability;
        rainiestIdx = i;
      }
    }
    // Chỉ highlight nếu ngày mưa nhất có ít nhất 40% mưa
    final showRainiestBadge = maxRain >= 40;

    return Column(
      children: List.generate(limit, (i) {
        final d = days[i];
        final isToday = i == 0;
        final isTomorrow = i == 1;
        final dayLabel = isToday
            ? l10n.weatherToday
            : isTomorrow
                ? l10n.weatherTomorrow
                : _fmtShortDay(d.date);
        final isRainiest = showRainiestBadge && i == rainiestIdx;
        return _dailyRow(d, dayLabel, isDark, cardColor, isRainiest: isRainiest);
      }),
    );
  }

  Widget _dailyRow(
    DayWeatherForecast d,
    String dayLabel,
    bool isDark,
    Color cardColor, {
    bool isRainiest = false,
  }) {
    final rainProb = d.rainProbability;
    final barColor = _rainColor(rainProb);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    // Màu nổi bật cho ngày mưa nhiều nhất
    final rainiestBorderColor = const Color(0xFF2563EB).withValues(alpha: 0.50);
    final rainiestBg = isDark
        ? const Color(0xFF1E3A5F).withValues(alpha: 0.85)
        : const Color(0xFFEFF6FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isRainiest
            ? rainiestBg
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRainiest
              ? rainiestBorderColor
              : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          width: isRainiest ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isRainiest
                ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: isRainiest ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          WeatherIconWidget(
            weatherCode: d.weatherCode,
            size: 36,
            isNight: false,
          ),
          const SizedBox(width: 12),
          Text(
            '${d.tempMin.round()}°~${d.tempMax.round()}°',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const Spacer(),
          // Badge "☔ Mưa nhiều" nếu là ngày mưa nhất
          if (isRainiest) ...([
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.25 : 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: const Text(
                '☔ Nhiều nhất',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ]),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$rainProb%',
                style: TextStyle(
                  fontSize: isRainiest ? 13 : 11.5,
                  fontWeight: isRainiest ? FontWeight.w800 : FontWeight.w600,
                  color: rainProb > 40 ? barColor : subColor,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 60,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: rainProb / 100.0,
                    backgroundColor:
                        isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Color _rainColor(int prob) {
    if (prob <= 30) return const Color(0xFF10B981);
    if (prob <= 60) return const Color(0xFFF59E0B);
    return const Color(0xFF2563EB);
  }

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
