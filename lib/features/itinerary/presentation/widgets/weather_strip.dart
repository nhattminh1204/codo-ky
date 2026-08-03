import 'package:flutter/material.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

/// Dải thời tiết nhỏ gọn hiển thị forecast 1 ngày trong lộ trình.
///
/// 3 trạng thái:
/// - Loading: skeleton shimmer nhẹ.
/// - Data: icon + nhiệt độ max/min + % mưa (glass card ~60px).
/// - Lỗi / không có dữ liệu: ẩn hoàn toàn (SizedBox.shrink) — tuyệt đối
///   không làm crash hay block hiển thị activity list.
class WeatherStrip extends StatelessWidget {
  /// Dữ liệu dự báo ngày đang hiển thị. Null = loading/lỗi.
  final DayWeatherForecast? forecast;

  /// true = đang chờ load dữ liệu.
  final bool isLoading;

  const WeatherStrip({
    super.key,
    this.forecast,
    this.isLoading = false,
  });

  /// Trạng thái skeleton khi đang load.
  const WeatherStrip.loading({super.key})
      : forecast = null,
        isLoading = true;

  /// Trạng thái rỗng (lỗi hoặc không có data).
  const WeatherStrip.empty({super.key})
      : forecast = null,
        isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Lỗi / không có data → ẩn hoàn toàn
    if (!isLoading && forecast == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: isLoading ? _buildSkeleton(isDark) : _buildContent(isDark),
    );
  }

  // ---------------------------------------------------------------------------
  // Skeleton shimmer khi đang load
  // ---------------------------------------------------------------------------
  Widget _buildSkeleton(bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Row(
        children: [
          // Icon placeholder
          _SkeletonBox(width: 36, height: 36, isDark: isDark, radius: 10),
          const SizedBox(width: 12),
          // Temp placeholder
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _SkeletonBox(width: 64, height: 12, isDark: isDark, radius: 6),
              const SizedBox(height: 6),
              _SkeletonBox(width: 88, height: 10, isDark: isDark, radius: 6),
            ],
          ),
          const Spacer(),
          // Rain placeholder
          _SkeletonBox(width: 52, height: 10, isDark: isDark, radius: 6),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Nội dung khi có data
  // ---------------------------------------------------------------------------
  Widget _buildContent(bool isDark) {
    final f = forecast!;

    // Màu nhấn dịu theo loại thời tiết (từ WmoCodeMapper, không phải hardcode)
    final accentColor = Color(f.themeColor);
    final isStorm = f.weatherCode >= 95;
    final isClear = f.weatherCode == 0;

    return _GlassCard(
      isDark: isDark,
      accentColor: accentColor,
      child: Row(
        children: [
          // Weather Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.18 : 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                f.weatherIcon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Label + nhiệt độ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  f.weatherLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${f.tempMax.toStringAsFixed(0)}° / ${f.tempMin.toStringAsFixed(0)}°',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Xác suất mưa
          if (f.rainProbability > 0) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 13,
                  color: isStorm
                      ? AppColors.error
                      : (isClear
                          ? AppColors.textLight
                          : AppColors.primary.withValues(alpha: 0.75)),
                ),
                const SizedBox(width: 3),
                Text(
                  '${f.rainProbability}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isStorm
                        ? AppColors.error
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Glass Card container — Liquid Glass 20% opacity theo UI_RULES.md
// ---------------------------------------------------------------------------
class _GlassCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color? accentColor;

  const _GlassCard({
    required this.child,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Glass tint: Light=0x33FFFFFF, Dark=0x33000000 (UI_RULES.md §1)
    final glassTint =
        isDark ? const Color(0x33000000) : const Color(0x33FFFFFF);
    final borderColor = isDark
        ? const Color(0x2994A3B8) // Slate-400 ghost border dark
        : const Color(0x2964748B); // Slate-500 ghost border light

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.60)
            : glassTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.40)
                : Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton shimmer box nhỏ
// ---------------------------------------------------------------------------
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isDark;
  final double radius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.isDark,
    this.radius = 4,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final base = widget.isDark ? 0.10 : 0.08;
        final bright = widget.isDark ? 0.20 : 0.16;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(
              alpha: base + (bright - base) * _anim.value,
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
