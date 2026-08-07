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

Color _getTempColor(double t) {
  if (t <= 20) return const Color(0xFF0EA5E9); // Sky blue (<20°)
  if (t <= 24) return const Color(0xFF38BDF8); // Light sky blue (21-24°)
  if (t <= 27) return const Color(0xFF10B981); // Emerald Green (25-27°)
  if (t <= 29) return const Color(0xFF84CC16); // Lime Green / Olive (28-29°)
  if (t <= 32) return const Color(0xFFF59E0B); // Amber / Gold (30-32°)
  if (t <= 34) return const Color(0xFFF97316); // Orange (33-34°)
  return const Color(0xFFEF4444); // Red / Crimson (>35°)
}

List<Color> _generateRangeGradientColors(double minTemp, double maxTemp) {
  final span = maxTemp - minTemp;
  final colors = <Color>[];
  final step = math.max(1.0, (span / 4).roundToDouble());
  for (double t = minTemp; t <= maxTemp; t += step) {
    colors.add(_getTempColor(t));
  }
  if (colors.isEmpty || colors.last != _getTempColor(maxTemp)) {
    colors.add(_getTempColor(maxTemp));
  }
  if (colors.length == 1) {
    colors.add(colors.first);
  }
  return colors;
}

Widget _buildLegendDot(String label, Color color, bool isDark) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 3),
      Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF475569),
        ),
      ),
    ],
  );
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
                // 1. Header: Vị trí & Trạng thái nạp ngầm SWR
                _buildHeader(
                  isDark,
                  isRefreshing: detailState.isRefreshing,
                  isOffline: detailState.isOffline,
                ),
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
  Widget _buildHeader(
    bool isDark, {
    bool isRefreshing = false,
    bool isOffline = false,
  }) {
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
        if (isRefreshing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Cập nhật...',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )
        else if (isOffline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF78350F).withValues(alpha: 0.3)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                width: 0.8,
              ),
            ),
            child: Text(
              'Ngoại tuyến',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cột trái: Emoji 💡 to, nổi bật, thả tự do không viền/nền, căn giữa hoàn hảo
          SizedBox(
            width: 44,
            child: Text(
              '💡',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 34,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 10),

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

  // ── 4. Stats Grid (Optimized Travel Weather Metrics & Simulation) ─────────
  // ── 4. Stats Grid (Optimized Travel Weather Metrics) ───────────────────────
  Widget _buildStatsGrid(
      WeatherDetailResult d, bool isDark, Color cardColor) {
    final humidity = d.current.humidity.round();
    final windSpeed = d.windSpeed;
    final uvIndex = d.uvIndex;
    final aqi = d.aqi ?? 72;

    final nowHour = DateTime.now().hour;
    final isNighttime = nowHour >= 20 || nowHour < 6;

    // 1. Humidity Calculations
    final String humidityStatus = humidity > 85
        ? l10n.statusHumidityHigh
        : (humidity < 40
            ? l10n.statusHumidityLow
            : (humidity > 75 ? l10n.statusHumidityModerate : l10n.statusHumidityGood));
    final String humidityInsight = humidity > 85
        ? l10n.insightHumidityHigh
        : (humidity < 40
            ? l10n.insightHumidityLow
            : (humidity > 75
                ? l10n.insightHumidityModerate
                : l10n.insightHumidityGood));

    final humidityStatusBg = humidity > 85
        ? (isDark ? const Color(0xFF1E1B4B) : const Color(0xFFE0E7FF))
        : (humidity < 40
            ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
            : (humidity > 75
                ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE))
                : (isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE))));
    final humidityStatusText = humidity > 85
        ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5))
        : (humidity < 40
            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
            : (humidity > 75
                ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB))
                : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))));

    // 2. Wind Calculations
    final String windStatus = windSpeed > 25.0
        ? l10n.statusWindHigh
        : (windSpeed >= 11.0 ? l10n.statusWindModerate : l10n.statusWindGood);
    final String windInsight = windSpeed > 25.0
        ? l10n.insightWindHigh
        : (windSpeed >= 11.0
            ? l10n.insightWindModerate
            : l10n.insightWindGood);

    final windStatusBg = windSpeed > 25.0
        ? (isDark ? const Color(0xFF4C1D95) : const Color(0xFFFFE4E6))
        : (windSpeed >= 11.0
            ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
            : (isDark ? const Color(0xFF451A03) : const Color(0xFFFFEDD5)));
    final windStatusText = windSpeed > 25.0
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFE11D48))
        : (windSpeed >= 11.0
            ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
            : (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C)));

    // 3. UV Calculations
    final String uvStatus = uvIndex > 8.0
        ? l10n.statusUvExtreme
        : (uvIndex >= 6.0
            ? l10n.statusUvHigh
            : (uvIndex >= 3.0 ? l10n.statusUvModerate : l10n.statusUvGood));
    final String uvInsight = uvIndex > 8.0
        ? l10n.insightUvExtreme
        : (uvIndex >= 6.0
            ? l10n.insightUvHigh
            : (uvIndex >= 3.0 ? l10n.insightUvModerate : l10n.insightUvGood));

    final uvStatusBg = uvIndex > 8.0
        ? (isDark ? const Color(0xFF4C1D95) : const Color(0xFFF3E8FF))
        : (uvIndex >= 6.0
            ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFFEDD5))
            : (uvIndex >= 3.0
                ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))));
    final uvStatusText = uvIndex > 8.0
        ? (isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA))
        : (uvIndex >= 6.0
            ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
            : (uvIndex >= 3.0
                ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))));

    // 4. AQI Calculations
    final String aqiStatus = aqi > 150
        ? l10n.statusAqiHazardous
        : (aqi > 100
            ? l10n.statusAqiUnhealthy
            : (aqi > 50 ? l10n.statusAqiModerate : l10n.statusAqiGood));
    final String aqiInsight = aqi > 150
        ? l10n.insightAqiHazardous
        : (aqi > 100
            ? l10n.insightAqiUnhealthy
            : (aqi > 50 ? l10n.insightAqiModerate : l10n.insightAqiGood));

    final aqiStatusBg = aqi > 150
        ? (isDark ? const Color(0xFF4C1D95) : const Color(0xFFFFE4E6))
        : (aqi > 100
            ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFFEDD5))
            : (aqi > 50
                ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))));
    final aqiStatusText = aqi > 150
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFE11D48))
        : (aqi > 100
            ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
            : (aqi > 50
                ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706))
                : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))));

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildOptimizedMetricCard(
                  icon: Icons.water_drop_rounded,
                  accentColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                  iconBgColor: isDark ? const Color(0xFF0C4A6E) : const Color(0xFFF0F9FF),
                  label: l10n.weatherHumidity,
                  subLabel: l10n.weatherHumiditySub,
                  valueStr: '$humidity',
                  unitStr: '%',
                  statusText: humidityStatus,
                  statusBgColor: humidityStatusBg,
                  statusTextColor: humidityStatusText,
                  gaugeSteps: [
                    l10n.gaugeHumidityStep1,
                    l10n.gaugeHumidityStep2,
                    l10n.gaugeHumidityStep3,
                    l10n.gaugeHumidityStep4,
                    l10n.gaugeHumidityStep5,
                  ],
                  progressValue: (humidity / 100.0).clamp(0.0, 1.0),
                  spectrumGradientColors: const [
                    Color(0xFFFBBF24),
                    Color(0xFF38BDF8),
                    Color(0xFF2563EB),
                  ],
                  spectrumGradientStops: const [0.0, 0.5, 1.0],
                  tipIcon: Icons.lightbulb_rounded,
                  tipText: humidityInsight,
                  isDark: isDark,
                  topGlowGradientColors: const [
                    Color(0xFF38BDF8),
                    Color(0xFF2563EB),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildOptimizedMetricCard(
                  icon: Icons.air_rounded,
                  accentColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
                  iconBgColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFFF7ED),
                  label: l10n.weatherWind,
                  subLabel: l10n.weatherWindSub,
                  valueStr: '${windSpeed.round()}',
                  unitStr: 'km/h',
                  statusText: windStatus,
                  statusBgColor: windStatusBg,
                  statusTextColor: windStatusText,
                  gaugeSteps: [
                    l10n.gaugeWindStep1,
                    l10n.gaugeWindStep2,
                    l10n.gaugeWindStep3,
                    l10n.gaugeWindStep4,
                    l10n.gaugeWindStep5,
                  ],
                  progressValue: (windSpeed / 50.0).clamp(0.0, 1.0),
                  spectrumGradientColors: const [
                    Color(0xFF34D399),
                    Color(0xFFFBBF24),
                    Color(0xFFF87171),
                  ],
                  spectrumGradientStops: const [0.0, 0.5, 1.0],
                  tipIcon: Icons.directions_boat_rounded,
                  tipText: windInsight,
                  isDark: isDark,
                  topGlowGradientColors: const [
                    Color(0xFFF97316),
                    Color(0xFFF59E0B),
                  ],
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
                    : _buildOptimizedMetricCard(
                        icon: Icons.wb_sunny_rounded,
                        accentColor: isDark ? const Color(0xFFFACC15) : const Color(0xFFD97706),
                        iconBgColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFEFCE8),
                        label: l10n.weatherUvIndex,
                        subLabel: l10n.weatherUvSub,
                        valueStr: uvIndex.toStringAsFixed(1),
                        unitStr: 'UV',
                        statusText: uvStatus,
                        statusBgColor: uvStatusBg,
                        statusTextColor: uvStatusText,
                        gaugeSteps: [
                          l10n.gaugeUvStep1,
                          l10n.gaugeUvStep2,
                          l10n.gaugeUvStep3,
                          l10n.gaugeUvStep4,
                        ],
                        progressValue: (uvIndex / 12.0).clamp(0.0, 1.0),
                        spectrumGradientColors: const [
                          Color(0xFF34D399),
                          Color(0xFFFACC15),
                          Color(0xFFF97316),
                          Color(0xFFA855F7),
                        ],
                        spectrumGradientStops: const [0.0, 0.33, 0.66, 1.0],
                        tipIcon: Icons.photo_camera_rounded,
                        tipText: uvInsight,
                        isDark: isDark,
                        topGlowGradientColors: const [
                          Color(0xFFFACC15),
                          Color(0xFFF97316),
                          Color(0xFFA855F7),
                        ],
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildOptimizedMetricCard(
                  icon: Icons.eco_rounded,
                  accentColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                  iconBgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                  label: l10n.weatherAirQuality,
                  subLabel: l10n.weatherAirQualitySub,
                  valueStr: '$aqi',
                  unitStr: 'AQI',
                  statusText: aqiStatus,
                  statusBgColor: aqiStatusBg,
                  statusTextColor: aqiStatusText,
                  gaugeSteps: [
                    l10n.gaugeAqiStep1,
                    l10n.gaugeAqiStep2,
                    l10n.gaugeAqiStep3,
                    l10n.gaugeAqiStep4,
                  ],
                  progressValue: (aqi / 300.0).clamp(0.0, 1.0),
                  spectrumGradientColors: const [
                    Color(0xFF34D399),
                    Color(0xFFFBBF24),
                    Color(0xFFF97316),
                    Color(0xFFF87171),
                  ],
                  spectrumGradientStops: const [0.0, 0.33, 0.66, 1.0],
                  tipIcon: Icons.directions_walk_rounded,
                  tipText: aqiInsight,
                  isDark: isDark,
                  topGlowGradientColors: const [
                    Color(0xFF34D399),
                    Color(0xFF0D9488),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bentoNightUvCard({required bool isDark}) {
    final bgColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final nightAccent = isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: nightAccent.withValues(alpha: 0.22), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: nightAccent.withValues(alpha: isDark ? 0.14 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 3.5,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: nightAccent.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.nights_stay_rounded,
                            size: 16,
                            color: nightAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.weatherUvIndex,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                l10n.weatherUvSub,
                                style: TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: nightAccent.withValues(alpha: isDark ? 0.20 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: nightAccent.withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        l10n.weatherNighttime,
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w700,
                          color: nightAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '0.0',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.8,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'UV',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: nightAccent.withValues(alpha: isDark ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: nightAccent.withValues(alpha: isDark ? 0.22 : 0.14),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1.5),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: nightAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.dark_mode_rounded,
                                size: 11,
                                color: nightAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.insightUvNight,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155),
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedMetricCard({
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
    required String label,
    required String subLabel,
    required String valueStr,
    required String unitStr,
    required String statusText,
    required Color statusBgColor,
    required Color statusTextColor,
    required List<String> gaugeSteps,
    required double progressValue,
    required List<Color> spectrumGradientColors,
    required List<double> spectrumGradientStops,
    required IconData tipIcon,
    required String tipText,
    required bool isDark,
    required List<Color> topGlowGradientColors,
  }) {
    final baseBg = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;
    final borderColor = accentColor.withValues(alpha: isDark ? 0.25 : 0.18);

    return _PressableCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: baseBg,
            borderRadius: BorderRadius.circular(20),
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
              Container(
                height: 3.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: topGlowGradientColors,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(icon, size: 16, color: accentColor),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                subLabel,
                                style: TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusTextColor.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: statusTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          valueStr,
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.8,
                            height: 1.0,
                          ),
                        ),
                        if (unitStr.isNotEmpty) ...[
                          const SizedBox(width: 3),
                          Text(
                            unitStr,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: gaugeSteps.map((step) {
                            return Text(
                              step,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 12,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final totalWidth = constraints.maxWidth;
                              final clampedProgress = progressValue.clamp(0.0, 1.0);
                              final thumbLeft = (totalWidth - 11) * clampedProgress;

                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    height: 7,
                                    width: totalWidth,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.5),
                                      gradient: LinearGradient(
                                        colors: spectrumGradientColors,
                                        stops: spectrumGradientStops,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: thumbLeft,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: accentColor,
                                          width: 2.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: 0.4),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: isDark ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.14),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1.5),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                tipIcon,
                                size: 11,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tipText,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155),
                                height: 1.35,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

    final currentTempObj = ref.watch(currentWeatherProvider).currentWeather.valueOrNull;
    final currentTemp = currentTempObj?.temperature;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Widget: '7 ngày tới' + 'Thang nhiệt chuẩn iOS (°C)'
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.weatherDailyForecast,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'Thang nhiệt chuẩn iOS (°C)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withValues(alpha: 0.50) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          const SizedBox(height: 6),

          // 7-day forecast rows
          ...List.generate(limit, (i) {
            final d = days[i];
            final dayLabel = _fmtDailyLabel(i, d.date);
            final isToday = i == 0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.5),
              child: Row(
                children: [
                  // Cột 1: Tên ngày (vd: Hôm nay, Thứ Hai...)
                  SizedBox(
                    width: 82,
                    child: Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
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
                            color: Color(0xFF0EA5E9),
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

                  // Cột 4: Thanh Range Bar dải nhiệt độ (Continuous Multi-stop Gradient chuẩn iOS)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final trackWidth = constraints.maxWidth;
                        final minRatio = ((d.tempMin - globalMin) / totalSpan).clamp(0.0, 1.0);
                        final maxRatio = ((d.tempMax - globalMin) / totalSpan).clamp(0.0, 1.0);

                        final leftPos = trackWidth * minRatio;
                        final barWidth = ((maxRatio - minRatio) * trackWidth).clamp(12.0, trackWidth);

                        final gradientColors = _generateRangeGradientColors(d.tempMin, d.tempMax);

                        // Con trỏ nốt tròn nhiệt độ hiện tại (temp-dot)
                        final currentVal = (isToday && currentTemp != null) ? currentTemp : d.tempMin;
                        final dotRatioInBar = ((currentVal - d.tempMin) / (d.tempMax - d.tempMin).clamp(1.0, 100.0)).clamp(0.0, 1.0);
                        final dotLeftPos = leftPos + (barWidth * dotRatioInBar) - 5.5;

                        return SizedBox(
                          height: 11.0,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              // Track nền xám nhạt (Light Grey Track)
                              Container(
                                width: double.infinity,
                                height: 5.5,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              // Đoạn nhiệt độ của ngày (Active Dynamic Range Gradient Bar)
                              Positioned(
                                left: leftPos,
                                width: barWidth,
                                top: 2.75,
                                height: 5.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3.0),
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                    ),
                                  ),
                                ),
                              ),
                              // Con trỏ temp-dot nhiệt độ hiện tại (cho Hôm nay)
                              if (isToday)
                                Positioned(
                                  left: dotLeftPos.clamp(0.0, trackWidth - 11.0),
                                  top: 0,
                                  child: Container(
                                    width: 11.0,
                                    height: 11.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0EA5E9),
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                        ),
                                      ],
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

          const SizedBox(height: 8),
          Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          const SizedBox(height: 10),

          // Bottom Bar Info & Legend Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 4),
                  Text(
                    'Dải màu phản ánh chuẩn nhiệt độ toàn tuần',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot('Mát (<25°)', const Color(0xFF0EA5E9), isDark),
                  const SizedBox(width: 6),
                  _buildLegendDot('Ấm (25-28°)', const Color(0xFF10B981), isDark),
                  const SizedBox(width: 6),
                  _buildLegendDot('Nắng (29-32°)', const Color(0xFFF59E0B), isDark),
                  const SizedBox(width: 6),
                  _buildLegendDot('Nóng (>33°)', const Color(0xFFEF4444), isDark),
                ],
              ),
            ],
          ),
        ],
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
    final timeLabel = widget.isNow ? context.l10n.weatherNow : _fmtHHmm(h.time);

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
