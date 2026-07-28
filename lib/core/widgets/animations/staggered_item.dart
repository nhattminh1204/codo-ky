import 'dart:async';
import 'package:flutter/material.dart';
import 'package:codoky/core/theme/motion.dart';

/// StaggeredItem tạo hiệu ứng xuất hiện so le (fade-in + slide-up nhẹ) cho danh sách.
/// Giới hạn maxStaggerCount (mặc định 12) để duy trì 60 FPS trên các danh sách dài.
class StaggeredItem extends StatefulWidget {
  final int index;
  final Widget child;
  final int maxStaggerCount;
  final Duration delayStep;

  const StaggeredItem({
    super.key,
    required this.index,
    required this.child,
    this.maxStaggerCount = 12,
    this.delayStep = const Duration(milliseconds: 35),
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.standard,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    ));

    if (widget.index < widget.maxStaggerCount) {
      _timer = Timer(widget.delayStep * widget.index, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index >= widget.maxStaggerCount) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
