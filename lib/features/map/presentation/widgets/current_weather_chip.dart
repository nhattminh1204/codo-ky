import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';

/// Chip thời tiết hiện tại nhỏ gọn, theo đúng phong cách glass/pill đã dùng
/// cho nav bar (bản sao nhẹ của `_buildGlassOverlay` ở map_home_screen).
///
/// - Có dữ liệu: hiện icon + nhiệt độ (vd "☀️ 32°"). Bấm vào mở rộng thêm
///   % mưa và độ ẩm.
/// - Đang tải: skeleton pill nhỏ.
/// - Lỗi: ẩn hẳn (SizedBox.shrink) — không hiện chip báo lỗi gây rối bản đồ.
///
/// Dữ liệu lấy từ [currentWeatherProvider] (đã có cache vị trí/30 phút),
/// KHÔNG tự gọi API ở đây — chỉ render theo state.
class CurrentWeatherChip extends ConsumerStatefulWidget {
  const CurrentWeatherChip({super.key});

  @override
  ConsumerState<CurrentWeatherChip> createState() => _CurrentWeatherChipState();
}

class _CurrentWeatherChipState extends ConsumerState<CurrentWeatherChip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(currentWeatherProvider).currentWeather;

    if (current is AsyncData<CurrentWeatherResult>) {
      return _buildDataChip(current.value);
    }
    if (current is AsyncError) {
      // Lỗi mạng/timeout → ẩn hẳn, không làm rối bản đồ.
      return const SizedBox.shrink();
    }
    // Loading (kể cả AsyncLoading khi refresh lại)
    return _buildLoadingChip();
  }

  Widget _buildGlassPill({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.40),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GlassContainer(
        useOwnLayer: true,
        quality: GlassQuality.standard,
        shape: LiquidRoundedRectangle(borderRadius: 9999),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: child,
      ),
    );
  }

  Widget _buildDataChip(CurrentWeatherResult data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tempColor = isDark ? Colors.white : AppColors.primaryDark;
    final subColor = isDark ? Colors.white70 : AppColors.primary;

    final collapsed = Row(
      key: const ValueKey('collapsed'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(data.weatherIcon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          '${data.temperature.round()}°',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: tempColor,
          ),
        ),
      ],
    );

    final expanded = Row(
      key: const ValueKey('expanded'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(data.weatherIcon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          '${data.temperature.round()}°',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: tempColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 1,
          height: 12,
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.15),
        ),
        const SizedBox(width: 8),
        Icon(Icons.water_drop_rounded, size: 13, color: subColor),
        const SizedBox(width: 2),
        Text(
          '${data.precipitation.round()}%',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
        const SizedBox(width: 7),
        Icon(Icons.opacity_rounded, size: 13, color: subColor),
        const SizedBox(width: 2),
        Text(
          '${data.humidity.round()}%',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: _buildGlassPill(
        child: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) =>
                SizeTransition(sizeFactor: animation, alignment: Alignment.centerLeft, child: child),
            child: _expanded ? expanded : collapsed,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingChip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildGlassPill(
      child: SizedBox(
        width: 62,
        height: 16,
        child: Center(
          child: Container(
            width: 46,
            height: 8,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
      ),
    );
  }
}