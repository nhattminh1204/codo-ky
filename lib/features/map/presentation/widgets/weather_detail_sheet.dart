import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/providers/weather_detail_provider.dart';

/// Format giờ nhanh mà không cần package intl.
String _fmtHHmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Format ngày dạng "T2, 5/8".
String _fmtShortDay(DateTime dt) {
  const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  return '${days[dt.weekday % 7]}, ${dt.day}/${dt.month}';
}

/// Full-feature Weather Detail Sheet — mở khi user tap badge thời tiết trong Search Bar.
/// DraggableScrollableSheet với 2 snap: Basic (42%) → Advanced (88%).
class WeatherDetailSheet extends ConsumerStatefulWidget {
  const WeatherDetailSheet({super.key});

  @override
  ConsumerState<WeatherDetailSheet> createState() => _WeatherDetailSheetState();
}

class _WeatherDetailSheetState extends ConsumerState<WeatherDetailSheet> {
  @override
  void initState() {
    super.initState();
    // Lazy load ngay khi sheet mở
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
      initialChildSize: 0.42,
      minChildSize: 0.42,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const [0.42, 0.88],
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

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // --- Scrollable Content ---
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Header
                _buildHeader(currentState, isDark),
                const SizedBox(height: 16),

                // Hero: Nhiệt độ + mô tả
                currentState.currentWeather.when(
                  data: (w) => _buildHero(w, detailState, isDark),
                  loading: () => _buildShimmer(height: 100, isDark: isDark),
                  error: (e, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Stats Grid: Độ ẩm / Gió / UV / AQI
                detailState.detail.when(
                  data: (d) => _buildStatsGrid(d, isDark, cardColor),
                  loading: () => _buildShimmer(height: 90, isDark: isDark),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // --- ADVANCED: Dự báo theo giờ ---
                _buildSectionTitle(l10n.weatherHourlyForecast, isDark),
                const SizedBox(height: 10),
                detailState.detail.when(
                  data: (d) => _buildHourlyRow(d.hourly, isDark, cardColor),
                  loading: () => _buildShimmer(height: 96, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 24),

                // --- ADVANCED: Dự báo 7 ngày ---
                _buildSectionTitle(l10n.weatherDailyForecast, isDark),
                const SizedBox(height: 10),
                detailState.forecast.when(
                  data: (f) => _buildDailyList(f.days, isDark, cardColor),
                  loading: () => _buildShimmer(height: 260, isDark: isDark),
                  error: (e, st) => _buildErrorChip(isDark),
                ),
                const SizedBox(height: 24),

                // Close button
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                    label: Text(
                      l10n.weatherClose,
                      style: TextStyle(
                        fontSize: 13,
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(CurrentWeatherState state, bool isDark) {
    final timeStr = state.lastFetchedAt != null
        ? _fmtHHmm(state.lastFetchedAt!)
        : '';
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.location_on_rounded,
            size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          l10n.weatherLocationHue,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const Spacer(),
        if (timeStr.isNotEmpty)
          Text(
            l10n.weatherUpdatedAt(timeStr),
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
      ],
    );
  }

  // ── Hero: nhiệt độ lớn + feels like + label ─────────────────────────────────
  Widget _buildHero(
      CurrentWeatherResult w, WeatherDetailState detailState, bool isDark) {
    final feelsLike = detailState.detail.valueOrNull?.feelsLike;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Temp + icon
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  w.weatherIcon,
                  style: const TextStyle(fontSize: 52),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.temperature.round()}°C',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        height: 1.0,
                      ),
                    ),
                    if (feelsLike != null)
                      Text(
                        l10n.weatherFeelsLike(feelsLike.round()),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        // Weather label pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(w.themeColor).withValues(alpha: isDark ? 0.2 : 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color(w.themeColor).withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            w.weatherLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Grid: 2x2 ─────────────────────────────────────────────────────────
  Widget _buildStatsGrid(
      WeatherDetailResult d, bool isDark, Color cardColor) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        _statCard(
          icon: Icons.water_drop_rounded,
          iconColor: const Color(0xFF38BDF8),
          label: l10n.weatherHumidity,
          value: '${d.current.humidity.round()}%',
          isDark: isDark,
          cardColor: cardColor,
        ),
        _statCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFF94A3B8),
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
          value: d.aqi != null ? l10n.weatherAqiLabel(d.aqi!) : '—',
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
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
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

  // ── Hourly Row: cuộn ngang ───────────────────────────────────────────────────
  Widget _buildHourlyRow(
      List<HourlyWeather> hourly, bool isDark, Color cardColor) {
    final now = DateTime.now();
    // Lọc chỉ lấy tối đa 24 giờ từ bây giờ, bước 1 giờ
    final filtered = hourly
        .where((h) {
          final diff = h.time.difference(now).inMinutes;
          return diff >= -30 && diff <= 24 * 60;
        })
        .toList();

    if (filtered.isEmpty) return _buildErrorChip(isDark);

    return SizedBox(
      height: 100,
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
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isNow ? AppColors.primary.withValues(alpha: 0.15) : cardColor,
        borderRadius: BorderRadius.circular(14),
        border: isNow
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5)
            : null,
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
              fontSize: 10.5,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: isNow
                  ? AppColors.primary
                  : (isDark ? Colors.white60 : const Color(0xFF64748B)),
            ),
          ),
          Text(h.weatherIcon, style: const TextStyle(fontSize: 22)),
          Text(
            '${h.temperature.round()}°',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          if (h.precipitationProbability > 0)
            Text(
              '${h.precipitationProbability}%',
              style: TextStyle(fontSize: 10, color: rainColor),
            ),
        ],
      ),
    );
  }

  // ── Daily 7-day List ─────────────────────────────────────────────────────────
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
          // Day label
          SizedBox(
            width: 80,
            child: Text(
              dayLabel,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          // Weather icon
          Text(d.weatherIcon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          // Temp range
          Text(
            '${d.tempMin.round()}°~${d.tempMax.round()}°',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: textColor),
          ),
          const Spacer(),
          // Rain probability bar + %
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$rainProb%',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: rainProb > 40 ? barColor : subColor),
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
    if (prob <= 30) return const Color(0xFF10B981); // xanh lá — ít mưa
    if (prob <= 60) return const Color(0xFFF59E0B); // vàng — trung bình
    return const Color(0xFF3B82F6); // xanh dương — mưa nhiều
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        letterSpacing: 0.3,
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
          Text('Không thể tải dữ liệu thời tiết',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFEF4444))),
        ],
      ),
    );
  }
}
