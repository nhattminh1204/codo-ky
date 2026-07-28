import 'package:flutter/material.dart';

/// AppMotion là nguồn chuẩn DUY NHẤT chứa thông số chuyển động, Curves và Physics của CodoKy.
/// Mọi animation trong ứng dụng phải tham chiếu từ đây, không hardcode rải rác.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 150);      // Feedback nhỏ: tap nút, toggle
  static const Duration standard = Duration(milliseconds: 300);   // Chuyển tab, mở bottom sheet
  static const Duration emphasized = Duration(milliseconds: 450); // Mở chi tiết địa điểm, map camera zoom

  // Curves
  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeOutBack; // Overshoot nhẹ (5-10%), nảy tự nhiên
  static const Curve springyCurve = Curves.elasticOut;      // Đàn hồi, dùng tiết chế cho marker tap

  // Spring physics dùng cho Bottom Sheet / Drag Gestures
  static const SpringDescription softSpring = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 20, // Damping cao hơn = nảy nhẹ, êm ái
  );
}
