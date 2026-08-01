import 'dart:async';
import 'package:flutter/material.dart';

/// Data Model đại diện cho một tùy chọn phương tiện
class VehicleOption {
  final String id;
  final String label;
  final IconData icon;

  const VehicleOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Widget chọn phương tiện cuộn ngang vô hạn dạng Wheel Picker (tương tự iOS UIDatePicker)
class VehicleWheelPicker extends StatefulWidget {
  /// Danh sách các phương tiện truyền vào
  final List<VehicleOption> items;

  /// Tùy chọn được chọn ban đầu
  final VehicleOption? initialSelection;

  /// Callback gọi khi phương tiện ở chính giữa thay đổi
  final ValueChanged<VehicleOption>? onChanged;

  /// Tỷ lệ width của mỗi item so với tổng chiều rộng viewport (mặc định 0.28 ~ 90-100px)
  final double viewportFraction;

  /// Chiều cao của picker widget (mặc định 72px)
  final double height;

  /// Màu Accent của item được chọn ở tâm
  final Color accentColor;

  /// Tỉ lệ phóng to của item ở tâm (scale max)
  final double scaleSelected;

  /// Tỉ lệ thu nhỏ của item ở rìa (scale min)
  final double scaleUnselected;

  const VehicleWheelPicker({
    super.key,
    required this.items,
    this.initialSelection,
    this.onChanged,
    this.viewportFraction = 0.28,
    this.height = 72.0,
    this.accentColor = const Color(0xFF2563EB),
    this.scaleSelected = 1.18,
    this.scaleUnselected = 0.85,
  }) : assert(items.length > 0, 'Danh sách items không được rỗng');

  @override
  State<VehicleWheelPicker> createState() => _VehicleWheelPickerState();
}

class _VehicleWheelPickerState extends State<VehicleWheelPicker> {
  static const int _kLoopItemCount = 10000;

  late PageController _pageController;
  double _currentPage = 0.0;
  int _lastReportedIndex = -1;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final initialRealIndex = _getInitialIndex();
    _lastReportedIndex = initialRealIndex;

    // Tính toán initialPage nằm ở giữa dải 10.000 để hỗ trợ cuộn vòng lặp cả 2 chiều vô hạn
    final middleOffset = (_kLoopItemCount ~/ 2);
    final initialPage = middleOffset - (middleOffset % widget.items.length) + initialRealIndex;

    _currentPage = initialPage.toDouble();
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: widget.viewportFraction,
    );

    _pageController.addListener(_onScroll);
  }

  int _getInitialIndex() {
    if (widget.initialSelection != null) {
      final index = widget.items.indexOf(widget.initialSelection!);
      if (index >= 0) return index;
    }
    return 0;
  }

  void _onScroll() {
    if (!_pageController.hasClients) return;

    setState(() {
      _currentPage = _pageController.page ?? _pageController.initialPage.toDouble();
    });

    final currentRoundPage = _currentPage.round();
    final currentRealIndex = currentRoundPage % widget.items.length;

    // Debounce 80ms để tránh trigger callback liên tục khi cuộn dở
    if (currentRealIndex != _lastReportedIndex) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 80), () {
        if (!mounted) return;
        _lastReportedIndex = currentRealIndex;
        widget.onChanged?.call(widget.items[currentRealIndex]);
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Thẻ Nền bo tròn cố định ở tâm highlight vị trí được chọn
          Container(
            width: (MediaQuery.of(context).size.width * widget.viewportFraction).clamp(76.0, 110.0),
            height: widget.height - 12,
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),

          // 2. PageView cuộn ngang vô hạn với snapping mặc định
          PageView.builder(
            controller: _pageController,
            itemCount: _kLoopItemCount,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final realIndex = index % widget.items.length;
              final item = widget.items[realIndex];

              // --- NỘI SUY TOÁN HỌC LIÊN TỤC THEO KHOẢNG CÁCH TỚI TÂM ---
              // distance = 0.0 khi item ở chính giữa tâm viewport
              final distance = (index - _currentPage).abs();
              final normalizedDistance = distance.clamp(0.0, 1.0);

              // Scale: 1.18 tại tâm -> 0.85 khi cách xa 1 page
              final scale = widget.scaleSelected -
                  (normalizedDistance * (widget.scaleSelected - widget.scaleUnselected));

              // Opacity: 1.0 tại tâm -> 0.40 khi cách xa 1 page
              final opacity = (1.0 - (normalizedDistance * 0.60)).clamp(0.40, 1.0);

              // Color: Tự động lerp mượt giữa màu Accent tại tâm và màu Xám khi cách xa tâm
              final itemColor = Color.lerp(
                    widget.accentColor,
                    isDark ? Colors.white54 : const Color(0xFF64748B),
                    normalizedDistance,
                  ) ??
                  widget.accentColor;

              return GestureDetector(
                onTap: () {
                  // Tap trực tiếp vào item để nhảy thẳng mượt tới vị trí đó
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: itemColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: distance < 0.4 ? FontWeight.bold : FontWeight.w500,
                            color: itemColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DEMO SCAFFOLD KÈM THEO
// ============================================================================
class VehicleWheelPickerDemoScreen extends StatefulWidget {
  const VehicleWheelPickerDemoScreen({super.key});

  @override
  State<VehicleWheelPickerDemoScreen> createState() => _VehicleWheelPickerDemoScreenState();
}

class _VehicleWheelPickerDemoScreenState extends State<VehicleWheelPickerDemoScreen> {
  // Danh sách các tùy chọn phương tiện mẫu
  final List<VehicleOption> _vehicles = const [
    VehicleOption(id: 'motorbike', label: 'Xe máy', icon: Icons.two_wheeler_rounded),
    VehicleOption(id: 'driving', label: 'Ô tô', icon: Icons.directions_car_rounded),
    VehicleOption(id: 'walking', label: 'Đi bộ', icon: Icons.directions_walk_rounded),
    VehicleOption(id: 'cycling', label: 'Xe đạp', icon: Icons.pedal_bike_rounded),
    VehicleOption(id: 'bus', label: 'Xe buýt', icon: Icons.directions_bus_rounded),
  ];

  late VehicleOption _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = _vehicles[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Wheel Picker Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hiển thị kết quả được chọn
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_selectedVehicle.icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Đã chọn: ${_selectedVehicle.label}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Widget Wheel Picker Cuộn Ngang Vô Hạn
              VehicleWheelPicker(
                items: _vehicles,
                initialSelection: _selectedVehicle,
                accentColor: const Color(0xFF2563EB),
                onChanged: (vehicle) {
                  setState(() {
                    _selectedVehicle = vehicle;
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
