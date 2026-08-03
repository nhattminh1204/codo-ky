import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

void main() {
  group('WmoCodeMapper — toIcon()', () {
    test('code 0 → ☀️ (quang đãng)', () {
      expect(WmoCodeMapper.toIcon(0), equals('☀️'));
    });

    test('code 1-3 → ⛅ (ít mây / có mây / nhiều mây)', () {
      expect(WmoCodeMapper.toIcon(1), equals('⛅'));
      expect(WmoCodeMapper.toIcon(2), equals('⛅'));
      expect(WmoCodeMapper.toIcon(3), equals('⛅'));
    });

    test('code 45/48 → 🌫️ (sương mù)', () {
      expect(WmoCodeMapper.toIcon(45), equals('🌫️'));
      expect(WmoCodeMapper.toIcon(48), equals('🌫️'));
    });

    test('code 51-55 → 🌦️ (mưa phùn)', () {
      for (final code in [51, 53, 55]) {
        expect(WmoCodeMapper.toIcon(code), equals('🌦️'),
            reason: 'code $code phải là 🌦️');
      }
    });

    test('code 61-65 → 🌧️ (mưa)', () {
      for (final code in [61, 63, 65]) {
        expect(WmoCodeMapper.toIcon(code), equals('🌧️'),
            reason: 'code $code phải là 🌧️');
      }
    });

    test('code 80-82 → 🌦️ (mưa rào)', () {
      for (final code in [80, 81, 82]) {
        expect(WmoCodeMapper.toIcon(code), equals('🌦️'),
            reason: 'code $code (mưa rào) phải là 🌦️');
      }
    });

    test('code 95-99 → ⛈️ (giông bão)', () {
      for (final code in [95, 96, 99]) {
        expect(WmoCodeMapper.toIcon(code), equals('⛈️'),
            reason: 'code $code phải là ⛈️');
      }
    });
  });

  group('WmoCodeMapper — toLabel()', () {
    test('code 0 → "Quang đãng"', () {
      expect(WmoCodeMapper.toLabel(0), equals('Quang đãng'));
    });

    test('code 1 → "Ít mây"', () {
      expect(WmoCodeMapper.toLabel(1), equals('Ít mây'));
    });

    test('code 2 → "Có mây"', () {
      expect(WmoCodeMapper.toLabel(2), equals('Có mây'));
    });

    test('code 3 → "Nhiều mây"', () {
      expect(WmoCodeMapper.toLabel(3), equals('Nhiều mây'));
    });

    test('code 45/48 → "Sương mù"', () {
      expect(WmoCodeMapper.toLabel(45), equals('Sương mù'));
      expect(WmoCodeMapper.toLabel(48), equals('Sương mù'));
    });

    test('code 51-53 → "Mưa phùn nhẹ"', () {
      expect(WmoCodeMapper.toLabel(51), equals('Mưa phùn nhẹ'));
      expect(WmoCodeMapper.toLabel(52), equals('Mưa phùn nhẹ'));
      expect(WmoCodeMapper.toLabel(53), equals('Mưa phùn nhẹ'));
    });

    test('code 61-63 → "Mưa nhỏ"', () {
      expect(WmoCodeMapper.toLabel(61), equals('Mưa nhỏ'));
      expect(WmoCodeMapper.toLabel(63), equals('Mưa nhỏ'));
    });

    test('code 64-65 → "Mưa to"', () {
      expect(WmoCodeMapper.toLabel(64), equals('Mưa to'));
      expect(WmoCodeMapper.toLabel(65), equals('Mưa to'));
    });

    test('code 80-82 → "Mưa rào"', () {
      expect(WmoCodeMapper.toLabel(80), equals('Mưa rào'));
      expect(WmoCodeMapper.toLabel(81), equals('Mưa rào'));
      expect(WmoCodeMapper.toLabel(82), equals('Mưa rào'));
    });

    test('code 95 → "Giông bão"', () {
      expect(WmoCodeMapper.toLabel(95), equals('Giông bão'));
    });

    test('code 96/99 → "Giông kèm mưa đá"', () {
      expect(WmoCodeMapper.toLabel(96), equals('Giông kèm mưa đá'));
      expect(WmoCodeMapper.toLabel(99), equals('Giông kèm mưa đá'));
    });

    test('code không xác định → "Chưa rõ"', () {
      // Các code không nằm trong bảng WMO chuẩn
      expect(WmoCodeMapper.toLabel(999), equals('Chưa rõ'));
      expect(WmoCodeMapper.toLabel(100), equals('Chưa rõ'));
    });
  });

  group('WmoCodeMapper — toThemeColor()', () {
    test('code 0 → màu vàng nắng', () {
      expect(WmoCodeMapper.toThemeColor(0), equals(0xFFFFF9C4));
    });

    test('code 1-3 → màu xanh nhạt', () {
      expect(WmoCodeMapper.toThemeColor(1), equals(0xFFE3F2FD));
      expect(WmoCodeMapper.toThemeColor(3), equals(0xFFE3F2FD));
    });

    test('code 45/48 → màu xám sương', () {
      expect(WmoCodeMapper.toThemeColor(45), equals(0xFFECEFF1));
    });

    test('code giông bão 95-99 → màu đỏ nhạt', () {
      expect(WmoCodeMapper.toThemeColor(95), equals(0xFFFCE4EC));
      expect(WmoCodeMapper.toThemeColor(99), equals(0xFFFCE4EC));
    });
  });

  group('DayWeatherForecast — computed getters', () {
    late DayWeatherForecast sunny;
    late DayWeatherForecast storm;

    setUp(() {
      sunny = DayWeatherForecast(
        date: DateTime(2026, 8, 5),
        weatherCode: 0,
        tempMax: 35.0,
        tempMin: 27.0,
        rainProbability: 5,
      );

      storm = DayWeatherForecast(
        date: DateTime(2026, 8, 6),
        weatherCode: 95,
        tempMax: 28.0,
        tempMin: 24.0,
        rainProbability: 90,
      );
    });

    test('sunny.weatherIcon = ☀️', () {
      expect(sunny.weatherIcon, equals('☀️'));
    });

    test('sunny.weatherLabel = Quang đãng', () {
      expect(sunny.weatherLabel, equals('Quang đãng'));
    });

    test('sunny.themeColor = màu vàng', () {
      expect(sunny.themeColor, equals(0xFFFFF9C4));
    });

    test('storm.weatherIcon = ⛈️', () {
      expect(storm.weatherIcon, equals('⛈️'));
    });

    test('storm.weatherLabel = Giông bão', () {
      expect(storm.weatherLabel, equals('Giông bão'));
    });
  });

  group('WeatherForecastResult — helper methods', () {
    test('isEmpty = true khi không có ngày', () {
      const result = WeatherForecastResult(days: []);
      expect(result.isEmpty, isTrue);
      expect(result.length, equals(0));
    });

    test('dayAt(0) trả đúng ngày đầu tiên', () {
      final day = DayWeatherForecast(
        date: DateTime(2026, 8, 5),
        weatherCode: 1,
        tempMax: 33.0,
        tempMin: 26.0,
        rainProbability: 10,
      );
      final result = WeatherForecastResult(days: [day]);
      expect(result.dayAt(0), equals(day));
    });

    test('dayAt(index out-of-range) → null', () {
      const result = WeatherForecastResult(days: []);
      expect(result.dayAt(0), isNull);
      expect(result.dayAt(-1), isNull);
      expect(result.dayAt(99), isNull);
    });
  });
}
