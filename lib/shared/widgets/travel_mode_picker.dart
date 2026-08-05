import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';

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

  /// Cho phép sử dụng giao diện 3D Infinite Wheel Dial khi mở rộng
  final bool isWheelMode;

  const TravelModePicker({
    super.key,
    this.initialMode = TravelMode.motorbike,
    required this.onChanged,
    this.height = 46.0,
    this.activePillColor = AppColors.primaryContainer,
    this.activeIconColor = AppColors.primaryDark,
    this.inactiveIconColor = const Color(0xFF64748B),
    this.isWheelMode = false,
  });

  @override
  State<TravelModePicker> createState() => _TravelModePickerState();
}

class _TravelModePickerState extends State<TravelModePicker> {
  int _selectedIndex = 1;
  int _lastHapticIndex = 1;
  FixedExtentScrollController? _wheelController;

  FixedExtentScrollController get _controller =>
      _wheelController ??= FixedExtentScrollController(initialItem: 3000 + _selectedIndex);

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
    _wheelController = FixedExtentScrollController(initialItem: 3000 + _selectedIndex);
  }

  @override
  void didUpdateWidget(covariant TravelModePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      final newIdx = _modes.indexOf(widget.initialMode);
      if (newIdx >= 0 && newIdx != _selectedIndex) {
        _selectModeIndex(newIdx, animateWheel: true);
      }
    }
  }

  @override
  void dispose() {
    _wheelController?.dispose();
    super.dispose();
  }

  void _selectModeIndex(int index, {bool animateWheel = false}) {
    final normalizedIndex = (index % _modes.length + _modes.length) % _modes.length;

    if (normalizedIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = normalizedIndex;
      });

      if (_selectedIndex != _lastHapticIndex) {
        _lastHapticIndex = _selectedIndex;
        _triggerHapticFeedback();
      }

      widget.onChanged(_modes[_selectedIndex]);
    }

    if (animateWheel && _controller.hasClients) {
      final currentItem = _controller.selectedItem;
      final currentMod = (currentItem % _modes.length + _modes.length) % _modes.length;
      int diff = normalizedIndex - currentMod;
      if (diff > 1) diff -= 3;
      if (diff < -1) diff += 3;
      _controller.animateToItem(
        currentItem + diff,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Gọi HapticFeedback.selectionClick() & lightImpact() tạo hiệu ứng nấc khấc rung giật nhẹ kiểu iOS Alarm Clock Wheel
  void _triggerHapticFeedback() {
    try {
      HapticFeedback.selectionClick();
      HapticFeedback.lightImpact();
    } catch (_) {
      // Ignored for non-supported hardware
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

  String _getModeTooltip(TravelMode mode, AppLocalizations l10n) {
    switch (mode) {
      case TravelMode.walking:
        return l10n.travelWalking;
      case TravelMode.motorbike:
        return l10n.travelMotorbike;
      case TravelMode.driving:
        return l10n.travelDriving;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pillBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final activePill = isDark ? const Color(0xFF1E3A8A) : widget.activePillColor;
    final activeIcon = isDark ? const Color(0xFF93C5FD) : widget.activeIconColor;
    final inactiveIcon = isDark ? Colors.white54 : widget.inactiveIconColor;

    if (!widget.isWheelMode) {
      // --- GIỮ NGUYÊN GIAO DIỆN CHỌN BAN ĐẦU KHI VUỐT XUỐNG (COLLAPSED / COMPACT VIEW) ---
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -120) {
            _selectModeIndex((_selectedIndex + 1).clamp(0, 2));
          } else if (velocity > 120) {
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
                  Row(
                    children: List.generate(_modes.length, (index) {
                      final mode = _modes[index];
                      final isSelected = index == _selectedIndex;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _selectModeIndex(index),
                          behavior: HitTestBehavior.opaque,
                          child: Tooltip(
message: _getModeTooltip(mode, context.l10n),
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

    // --- 3D INFINITE WHEEL DIAL (KHI MỞ RỘNG / VUỐT LÊN) ---
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: GestureDetector(
        // Hỗ trợ vuốt xoay chuyển phương tiện theo vòng lặp vô hạn (Infinite Loop)
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -120) {
            // Vuốt sang Trái -> Tiến sang phương tiện tiếp theo (vòng lặp vô hạn)
            _selectModeIndex(_selectedIndex + 1, animateWheel: true);
          } else if (velocity > 120) {
            // Vuốt sang Phải -> Lùi về phương tiện phía trước (vòng lặp vô hạn)
            _selectModeIndex(_selectedIndex - 1, animateWheel: true);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- PILL NỀN XANH HIGHLIGHT TẠI NẤC ĐANG CHỌN ---
            AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment(_getAlignmentX(_selectedIndex), 0.0),
              child: Container(
                width: 44,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: activePill,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: activePill.withValues(alpha: isDark ? 0.35 : 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // --- 3D INFINITE WHEEL DIAL (VÒNG LẶP VÔ HẠN PHONG CÁCH iOS ALARM PICKER) ---
            ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: 44,
              diameterRatio: 1.1,
              perspective: 0.003,
              magnification: 1.2,
              useMagnifier: true,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                final realIndex = (index % _modes.length + _modes.length) % _modes.length;
                _selectModeIndex(realIndex, animateWheel: false);
              },
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(_modes.length, (index) {
                  final mode = _modes[index];
                  final isSelected = index == _selectedIndex;

                  return GestureDetector(
                    onTap: () => _selectModeIndex(index, animateWheel: true),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Tooltip(
                        message: _getModeTooltip(mode, context.l10n),
                        child: AnimatedScale(
                          scale: isSelected ? 1.15 : 0.85,
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            _getModeIcon(mode),
                            color: isSelected ? activeIcon : inactiveIcon,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
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
