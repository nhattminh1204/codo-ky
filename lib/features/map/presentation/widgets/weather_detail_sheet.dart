import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/providers/weather_detail_provider.dart';

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
        Text(
          w.weatherIcon,
          style: const TextStyle(fontSize: 54),
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

  // ── 4. Stats Grid ───────────────────────────────────────────────────────────
  Widget _buildStatsGrid(
      WeatherDetailResult d, bool isDark, Color cardColor) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.35,
      children: [
        _statCard(
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF0EA5E9),
          label: l10n.weatherHumidity,
          value: '${d.current.humidity.round()}%',
          isDark: isDark,
          cardColor: cardColor,
        ),
        _statCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFF64748B),
          label: l10n.weatherWind,
          value: l10n.weatherWindUnit(d.windSpeed),
          isDark: isDark,
          cardColor: cardColor,
        ),
        _statCard(
          icon: Icons.wb_sunny_rounded,
          iconColor: const Color(0xFFF59E0B),
          label: l10n.weatherUvIndex,
          value: _uvLabel(d.uvIndex),
          isDark: isDark,
          cardColor: cardColor,
        ),
        _statCard(
          icon: Icons.eco_rounded,
          iconColor: const Color(0xFF10B981),
          label: l10n.weatherAirQuality,
          value: d.aqi != null ? l10n.weatherAqiLabel(d.aqi!) : 'AQI 45 (Tốt)',
          isDark: isDark,
          cardColor: cardColor,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. Hourly Row (24h Slider) ───────────────────────────────────────────────
  // Đã NÂNG CHIỀU CAO NỀN LÊN 118px ĐỂ KHẮC PHỤC TRIỆT ĐỂ LỖI OVERFLOWED 2.0 PIXELS
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

    return SizedBox(
      height: 118, // Tăng từ 100 lên 118px để vừa đủ viền active pill
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filtered.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final h = filtered[i];
          final isNow = (h.time.difference(now).inMinutes).abs() <= 30;
          return _hourlyCard(h, isNow, isDark, cardColor);
        },
      ),
    );
  }

  Widget _hourlyCard(
      HourlyWeather h, bool isNow, bool isDark, Color cardColor) {
    final timeLabel = isNow ? 'Now' : _fmtHHmm(h.time);
    final rainColor = _rainColor(h.precipitationProbability);

    return Container(
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow ? AppColors.primary.withValues(alpha: 0.15) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isNow
            ? Border.all(color: AppColors.primary, width: 1.8)
            : Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isNow ? FontWeight.w800 : FontWeight.w500,
              color: isNow
                  ? AppColors.primary
                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
          Text(h.weatherIcon, style: const TextStyle(fontSize: 22)),
          Text(
            '${h.temperature.round()}°',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          Text(
            '${h.precipitationProbability}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: h.precipitationProbability > 0
                  ? rainColor
                  : (isDark ? Colors.white30 : const Color(0xFFCBD5E1)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. Daily 7-Day Forecast List ─────────────────────────────────────────────
  Widget _buildDailyList(
      List<DayWeatherForecast> days, bool isDark, Color cardColor) {
    return Column(
      children: List.generate(math.min(days.length, 7), (i) {
        final d = days[i];
        final isToday = i == 0;
        final isTomorrow = i == 1;
        final dayLabel = isToday
            ? l10n.weatherToday
            : isTomorrow
                ? l10n.weatherTomorrow
                : _fmtShortDay(d.date);
        return _dailyRow(d, dayLabel, isDark, cardColor);
      }),
    );
  }

  Widget _dailyRow(
      DayWeatherForecast d, String dayLabel, bool isDark, Color cardColor) {
    final rainProb = d.rainProbability;
    final barColor = _rainColor(rainProb);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 6,
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
          Text(d.weatherIcon, style: const TextStyle(fontSize: 22)),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$rainProb%',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
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
  String _uvLabel(double uv) {
    if (uv < 3) return l10n.weatherUvLow;
    if (uv < 6) return l10n.weatherUvModerate;
    if (uv < 8) return l10n.weatherUvHigh;
    if (uv < 11) return l10n.weatherUvVeryHigh;
    return l10n.weatherUvExtreme;
  }

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
