/// Centralized sizing, touch target, and overlap constants for CodoKy Map Markers.
class MarkerConstants {
  MarkerConstants._();

  /// Baseline visible marker size (Default gốc: 42.0px)
  static const double baseSize = 42.0;

  /// Visible size increase factor (+10%)
  static const double sizeIncreaseFactor = 1.10;

  /// Visible size after +10% increase (46.2px)
  static const double visibleSize = baseSize * sizeIncreaseFactor;

  /// Minimum recommended touch target size (Apple HIG & Material Design: 44px)
  static const double minTouchTarget = 44.0;

  /// Effective touch target size (guaranteed >= 44.0px)
  static double get touchTargetSize =>
      visibleSize >= minTouchTarget ? visibleSize : minTouchTarget;

  /// Invisible padding around marker if visibleSize < minTouchTarget
  static double get invisiblePadding =>
      (touchTargetSize - visibleSize) / 2;

  /// Scale multiplier for Selected state (applied on top of visibleSize, not compounded)
  static const double selectedScale = 1.16;

  /// Distance threshold in screen pixels to detect unclustered marker overlap
  static const double overlapThresholdPx = 40.0;
}
