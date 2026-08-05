import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

/// WeatherIconWidget — Render icon thời tiết 3D Glassmorphic cao cấp
/// Tự động thiết kế hiệu ứng 3D (Mặt trời phát sáng, Mây kính nảy, Giọt mưa Cyan, Sét Vàng)
/// theo đúng mã WMO (Open-Meteo).
class WeatherIconWidget extends StatelessWidget {
  final int weatherCode;
  final double size;
  final bool useEmojiFallback;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.size = 32.0,
    this.useEmojiFallback = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useEmojiFallback) {
      return Text(
        WmoCodeMapper.toIcon(weatherCode),
        style: TextStyle(fontSize: size * 0.85),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: _build3dIcon(context, weatherCode, size),
      ),
    );
  }

  Widget _build3dIcon(BuildContext context, int code, double s) {
    // 1. Nắng quang đãng (Clear / Sunny)
    if (code == 0) {
      return _build3dSun(s);
    }

    // 2. Ít mây / Nhiều mây (Partly Cloudy / Cloudy)
    if (code >= 1 && code <= 3) {
      return _build3dCloudy(s, isOvercast: code == 3);
    }

    // 3. Sương mù (Fog / Mist)
    if (code == 45 || code == 48) {
      return _build3dFog(s);
    }

    // 4. Mưa phùn / Mưa nhẹ / Mưa rào (Drizzle / Light Rain / Rain Showers)
    if ((code >= 51 && code <= 55) || (code >= 80 && code <= 82)) {
      return _build3dRain(s, isHeavy: false);
    }

    // 5. Mưa to / Mưa rào nặng hạt (Heavy Rain)
    if (code >= 61 && code <= 67) {
      return _build3dRain(s, isHeavy: true);
    }

    // 6. Giông bão kèm sấm sét (Thunderstorm)
    if (code >= 95 && code <= 99) {
      return _build3dThunderstorm(s);
    }

    // Default Fallback
    return _build3dCloudy(s, isOvercast: false);
  }

  // ☀️ 3D Sun Widget
  Widget _build3dSun(double s) {
    final sunSize = s * 0.72;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow Ring
        Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.45),
                const Color(0xFFFBBF24).withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // 3D Solar Orb
        Container(
          width: sunSize,
          height: sunSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDE047), // Bright Yellow
                Color(0xFFF59E0B), // Warm Amber
                Color(0xFFD97706), // Deep Solar
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                blurRadius: s * 0.25,
                offset: Offset(0, s * 0.08),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GlossHighlightPainter(),
          ),
        ),
      ],
    );
  }

  // ⛅ 3D Cloudy Widget
  Widget _build3dCloudy(double s, {required bool isOvercast}) {
    final cloudSize = s * 0.78;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Sun Peek (nếu không phải âm u hoàn toàn)
        if (!isOvercast)
          Positioned(
            top: s * 0.04,
            right: s * 0.08,
            child: Container(
              width: s * 0.45,
              height: s * 0.45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFFDE047), Color(0xFFF59E0B)],
                ),
              ),
            ),
          ),
        // Glassmorphic Cloud Front
        Positioned(
          bottom: s * 0.08,
          child: Container(
            width: cloudSize,
            height: cloudSize * 0.58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isOvercast
                    ? [
                        const Color(0xFF94A3B8),
                        const Color(0xFF64748B),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFE2E8F0),
                      ],
              ),
              borderRadius: BorderRadius.circular(cloudSize * 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: s * 0.18,
                  offset: Offset(0, s * 0.08),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Cloud Puff Top Left
                Positioned(
                  left: cloudSize * 0.15,
                  top: -cloudSize * 0.22,
                  child: Container(
                    width: cloudSize * 0.42,
                    height: cloudSize * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOvercast ? const Color(0xFF94A3B8) : Colors.white,
                    ),
                  ),
                ),
                // Cloud Puff Top Right
                Positioned(
                  right: cloudSize * 0.20,
                  top: -cloudSize * 0.14,
                  child: Container(
                    width: cloudSize * 0.34,
                    height: cloudSize * 0.34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOvercast ? const Color(0xFF64748B) : const Color(0xFFF1F5F9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🌧️ 3D Rain Widget
  Widget _build3dRain(double s, {required bool isHeavy}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cloud Top
        Positioned(
          top: s * 0.05,
          child: Container(
            width: s * 0.72,
            height: s * 0.42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF64748B), Color(0xFF475569)],
              ),
              borderRadius: BorderRadius.circular(s * 0.2),
              border: Border.all(color: Colors.white30, width: 0.8),
            ),
          ),
        ),
        // Raindrops
        Positioned(
          bottom: s * 0.08,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRainDrop(s, delayMs: 0),
              SizedBox(width: s * 0.12),
              _buildRainDrop(s, delayMs: 150),
              SizedBox(width: s * 0.12),
              _buildRainDrop(s, delayMs: 300),
              if (isHeavy) ...[
                SizedBox(width: s * 0.12),
                _buildRainDrop(s, delayMs: 450),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRainDrop(double s, {required int delayMs}) {
    return Transform.rotate(
      angle: 15 * math.pi / 180,
      child: Container(
        width: s * 0.09,
        height: s * 0.24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s * 0.05),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF38BDF8),
              Color(0xFF0284C7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  // ⛈️ 3D Thunderstorm Widget
  Widget _build3dThunderstorm(double s) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dark Storm Cloud
        Positioned(
          top: s * 0.05,
          child: Container(
            width: s * 0.76,
            height: s * 0.45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              ),
              borderRadius: BorderRadius.circular(s * 0.22),
              border: Border.all(
                color: const Color(0xFFA855F7).withValues(alpha: 0.5),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B21A8).withValues(alpha: 0.4),
                  blurRadius: s * 0.2,
                  offset: Offset(0, s * 0.08),
                ),
              ],
            ),
          ),
        ),
        // Lightning Bolt ⚡
        Positioned(
          bottom: s * 0.04,
          child: Icon(
            Icons.bolt_rounded,
            size: s * 0.48,
            color: const Color(0xFFFACC15),
          ),
        ),
      ],
    );
  }

  // 🌫️ 3D Fog Widget
  Widget _build3dFog(double s) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _fogBar(s * 0.7, s * 0.08),
        SizedBox(height: s * 0.06),
        _fogBar(s * 0.85, s * 0.08),
        SizedBox(height: s * 0.06),
        _fogBar(s * 0.6, s * 0.08),
      ],
    );
  }

  Widget _fogBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(height * 0.5),
        border: Border.all(color: Colors.white, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Gloss Highlight Painter cho quả cầu mặt trời 3D
class _GlossHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addOval(Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.12,
        size.width * 0.38,
        size.height * 0.22,
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
