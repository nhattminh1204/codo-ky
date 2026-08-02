import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

/// Enum định nghĩa các phương tiện di chuyển
enum TravelMode {
  walking,
  motorbike,
  driving,
}

/// Widget TravelModePicker: Segmented control 3 lựa chọn (Đi bộ, Xe máy, Ô tô)
/// phong cách Google Maps với hiệu ứng trượt thẻ nền xanh nhạt mượt mà.
class TravelModePicker extends StatefulWidget {
  /// Phương tiện ban đầu được chọn
  final TravelMode initialMode;

  /// Callback gọi khi giá trị phương tiện được chọn thay đổi
  final ValueChanged<TravelMode> onChanged;

  /// Chiều cao của picker container (mặc định 46px)
  final double height;

  /// Màu nền của thẻ pill đang được chọn
  final Color activePillColor;

  /// Màu icon của phương tiện đang chọn
  final Color activeIconColor;

  /// Màu icon của phương tiện không chọn
  final Color inactiveIconColor;

  const TravelModePicker({
    super.key,
    this.initialMode = TravelMode.motorbike,
    required this.onChanged,
    this.height = 46.0,
    this.activePillColor = AppColors.primaryContainer,
    this.activeIconColor = AppColors.primaryDark,
    this.inactiveIconColor = const Color(0xFF64748B),
  });

  @override
  State<TravelModePicker> createState() => _TravelModePickerState();
}

class _TravelModePickerState extends State<TravelModePicker> {
  late int _selectedIndex;
  late int _lastHapticIndex;

  final List<TravelMode> _modes = const [
    TravelMode.walking,
    TravelMode.motorbike,
    TravelMode.driving,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = _modes.indexOf(widget.initialMode);
    if (_selectedIndex < 0) _selectedIndex = 1; // Default: Motorbike
    _lastHapticIndex = _selectedIndex;
  }

  @override
  void didUpdateWidget(covariant TravelModePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      final newIdx = _modes.indexOf(widget.initialMode);
      if (newIdx >= 0 && newIdx != _selectedIndex) {
        setState(() {
          _selectedIndex = newIdx;
        });
      }
    }
  }

  void _selectModeIndex(int index) {
    if (index < 0 || index >= _modes.length) return;

    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // 1. Kích hoạt rung HapticFeedback đúng 1 lần duy nhất khi thực sự đổi item
      if (_selectedIndex != _lastHapticIndex) {
        _lastHapticIndex = _selectedIndex;
        _triggerHapticFeedback();
      }

      // 2. Báo callback cho widget cha
      widget.onChanged(_modes[_selectedIndex]);
    }
  }

  /// Gọi HapticFeedback.selectionClick() an toàn 100% trên mọi nền tảng (Android/iOS/Web/Desktop)
  void _triggerHapticFeedback() {
    try {
      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        HapticFeedback.selectionClick();
      }
    } catch (_) {
      // Ignored for non-supported devices
    }
  }

  /// Chuyển đổi index thành giá trị Alignment X (-1.0 -> 0.0 -> 1.0) cho AnimatedAlign
  double _getAlignmentX(int index) {
    switch (index) {
      case 0:
        return -1.0; // Left: Walking
      case 1:
        return 0.0; // Center: Motorbike
      case 2:
        return 1.0; // Right: Driving
      default:
        return 0.0;
    }
  }

  IconData _getModeIcon(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return Icons.directions_walk_rounded;
      case TravelMode.motorbike:
        return Icons.two_wheeler_rounded;
      case TravelMode.driving:
        return Icons.directions_car_rounded;
    }
  }

  String _getModeTooltip(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return 'Đi bộ';
      case TravelMode.motorbike:
        return 'Xe máy';
      case TravelMode.driving:
        return 'Ô tô';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final activePill = isDark ? const Color(0xFF1E3A8A) : widget.activePillColor;
    final activeIcon = isDark ? const Color(0xFF93C5FD) : widget.activeIconColor;
    final inactiveIcon = isDark ? Colors.white54 : widget.inactiveIconColor;

    return GestureDetector(
      // Hỗ trợ vuốt lướt tay ngang để chuyển nấc phương tiện
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -120) {
          // Vuốt sang Trái -> Tiến sang phương tiện tiếp theo
          _selectModeIndex((_selectedIndex + 1).clamp(0, 2));
        } else if (velocity > 120) {
          // Vuốt sang Phải -> Lùi về phương tiện phía trước
          _selectModeIndex((_selectedIndex - 1).clamp(0, 2));
        }
      },
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(9999),
        ),
        padding: const EdgeInsets.all(3.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 3;

            return Stack(
              children: [
                // --- SLIDING PILL BACKGROUND ANIMATION ---
                // Thẻ nền màu xanh nhạt trượt ngang mượt mà (AnimatedAlign 200ms easeOut)
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment(_getAlignmentX(_selectedIndex), 0.0),
                  child: Container(
                    width: itemWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: activePill,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: activePill.withValues(alpha: isDark ? 0.3 : 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 3 ICON BUTTONS XẾP NGANG ---
                Row(
                  children: List.generate(_modes.length, (index) {
                    final mode = _modes[index];
                    final isSelected = index == _selectedIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectModeIndex(index),
                        behavior: HitTestBehavior.opaque,
                        child: Tooltip(
                          message: _getModeTooltip(mode),
                          child: Center(
                            child: AnimatedColorIcon(
                              icon: _getModeIcon(mode),
                              color: isSelected ? activeIcon : inactiveIcon,
                              duration: const Duration(milliseconds: 120),
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Helper Icon Widget fade đổi màu mượt 120ms
class AnimatedColorIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Duration duration;
  final double size;

  const AnimatedColorIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.duration,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: color, end: color),
      duration: duration,
      builder: (context, animatedColor, child) {
        return Icon(
          icon,
          size: size,
          color: animatedColor ?? color,
        );
      },
    );
  }
}

// ============================================================================
// DEMO SCAFFOLD KÈM THEO
// ============================================================================
class TravelModePickerDemoScreen extends StatefulWidget {
  const TravelModePickerDemoScreen({super.key});

  @override
  State<TravelModePickerDemoScreen> createState() => _TravelModePickerDemoScreenState();
}

class _TravelModePickerDemoScreenState extends State<TravelModePickerDemoScreen> {
  TravelMode _selectedMode = TravelMode.motorbike;

  String _getModeLabel(TravelMode mode) {
    switch (mode) {
      case TravelMode.walking:
        return 'Đi bộ (Walking)';
      case TravelMode.motorbike:
        return 'Xe máy (Motorbike)';
      case TravelMode.driving:
        return 'Ô tô (Driving)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Style TravelModePicker'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Phương tiện hiện tại: ${_getModeLabel(_selectedMode)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Segmented Control TravelModePicker
              TravelModePicker(
                initialMode: _selectedMode,
                onChanged: (newMode) {
                  setState(() {
                    _selectedMode = newMode;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
