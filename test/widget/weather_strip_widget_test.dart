import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/itinerary/presentation/widgets/weather_strip.dart';

// ---------------------------------------------------------------------------
// Helpers: build WeatherStrip trực tiếp (không qua provider),
// vì WeatherStrip là pure StatelessWidget nhận dữ liệu qua constructor.
// Provider integration được test riêng bằng cách override weatherForecastProvider.
// ---------------------------------------------------------------------------

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
        body: ProviderScope(child: child),
      ),
    );

void main() {
  group('WeatherStrip widget tests', () {
    // -----------------------------------------------------------------------
    // Test 1: Trạng thái loading — hiển thị skeleton, không crash
    // -----------------------------------------------------------------------
    testWidgets('1. Loading state: hiển thị skeleton, không crash, không có text nội dung thật', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const WeatherStrip.loading()));

      // Không crash — widget render được
      expect(find.byType(WeatherStrip), findsOneWidget);

      // Có Container (skeleton boxes bên trong _GlassCard)
      expect(find.byType(Container), findsWidgets);

      // KHÔNG hiển thị text nhiệt độ hay % mưa (chưa có data thật)
      expect(find.textContaining('°'), findsNothing);
      expect(find.textContaining('%'), findsNothing);

      // KHÔNG có SizedBox.shrink — skeleton không được ẩn
      // (SizedBox.shrink chỉ xuất hiện ở state empty/error)
      // Xác nhận bằng cách kiểm tra widget vẫn có kích thước > 0
      final renderBox = tester.renderObject<RenderBox>(find.byType(WeatherStrip));
      expect(renderBox.size.height, greaterThan(0));
    });

    // -----------------------------------------------------------------------
    // Test 2: Trạng thái success — hiển thị đúng icon/nhiệt độ/% mưa
    // -----------------------------------------------------------------------
    testWidgets('2. Data state: hiển thị weatherIcon, nhiệt độ max/min, % mưa khớp data mock', (
      WidgetTester tester,
    ) async {
      // Mock data: trời quang (code=0 → icon ☀️, label "Quang đãng"), mưa 20%
      final mockForecast = DayWeatherForecast(
        date: DateTime(2026, 8, 5),
        weatherCode: 0,
        tempMax: 34.0,
        tempMin: 26.5,
        rainProbability: 20,
      );

      await tester.pumpWidget(_wrap(WeatherStrip(forecast: mockForecast)));
      await tester.pumpAndSettle();

      // Icon thời tiết (emoji text)
      expect(find.text('☀️'), findsOneWidget);

      // Label tiếng Việt
      expect(find.text('Quang đãng'), findsOneWidget);

      // Nhiệt độ max/min đúng format
      expect(find.text('34° / 27°'), findsOneWidget);

      // % mưa hiển thị khi rainProbability > 0
      expect(find.text('20%'), findsOneWidget);

      // Không bị crash
      expect(tester.takeException(), isNull);
    });

    // -----------------------------------------------------------------------
    // Test 3: Trạng thái error — render SizedBox.shrink(), không crash, không hiện text
    // -----------------------------------------------------------------------
    testWidgets('3. Error state (WeatherStrip.empty): render rỗng (SizedBox.shrink), không crash, không có text lỗi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_wrap(const WeatherStrip.empty()));
      await tester.pumpAndSettle();

      // Widget vẫn tồn tại trong tree
      expect(find.byType(WeatherStrip), findsOneWidget);

      // Phải render SizedBox.shrink() — kích thước = 0×0
      final renderBox = tester.renderObject<RenderBox>(find.byType(WeatherStrip));
      expect(renderBox.size.width, equals(0.0));
      expect(renderBox.size.height, equals(0.0));

      // Không có bất kỳ text nào (không hiện thông báo lỗi làm rối UI)
      expect(find.byType(Text), findsNothing);

      // Không crash
      expect(tester.takeException(), isNull);
    });
  });
}
