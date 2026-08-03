/// Model dự báo thời tiết theo ngày cho lộ trình CodoKy.
/// Dùng Open-Meteo API (WMO weather codes).
library;

/// Dữ liệu thời tiết 1 ngày trong lộ trình.
class DayWeatherForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final int rainProbability; // 0–100%

  const DayWeatherForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.rainProbability,
  });

  /// Icon emoji đại diện cho thời tiết (dựa trên WMO code).
  String get weatherIcon => WmoCodeMapper.toIcon(weatherCode);

  /// Mô tả tiếng Việt ngắn gọn.
  String get weatherLabel => WmoCodeMapper.toLabel(weatherCode);

  /// Màu gợi ý cho nền card (hex int), tùy trạng thái thời tiết.
  int get themeColor => WmoCodeMapper.toThemeColor(weatherCode);

  @override
  String toString() =>
      'DayWeatherForecast(date: $date, code: $weatherCode, '
      'tempMax: $tempMax, tempMin: $tempMin, rain: $rainProbability%)';
}

/// Kết quả dự báo toàn bộ lộ trình.
class WeatherForecastResult {
  final List<DayWeatherForecast> days;

  const WeatherForecastResult({required this.days});

  bool get isEmpty => days.isEmpty;
  int get length => days.length;

  /// Lấy dự báo ngày theo index (0-based). Trả null nếu out-of-range.
  DayWeatherForecast? dayAt(int index) =>
      (index >= 0 && index < days.length) ? days[index] : null;
}

// ---------------------------------------------------------------------------
// WMO Code Mapper — hàm thuần túy, không phụ thuộc Flutter/Dio
// Dùng được trực tiếp trong unit test không cần platform setup.
// ---------------------------------------------------------------------------

/// Ánh xạ WMO weather code (từ Open-Meteo) sang icon emoji, label tiếng Việt
/// và màu gợi ý cho UI card.
///
/// Tham chiếu: https://open-meteo.com/en/docs (WMO Weather interpretation codes)
abstract class WmoCodeMapper {
  /// Trả về emoji icon đại diện cho [code].
  static String toIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌦️';
    if (code >= 56 && code <= 57) return '🌨️'; // mưa băng
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 66 && code <= 67) return '🌨️'; // mưa đá/giá
    if (code >= 71 && code <= 77) return '❄️'; // tuyết (n/a Huế)
    if (code >= 80 && code <= 82) return '🌦️'; // mưa rào
    if (code >= 85 && code <= 86) return '🌨️'; // tuyết rào
    if (code >= 95 && code <= 99) return '⛈️'; // giông bão
    return '🌤️'; // fallback
  }

  /// Trả về mô tả tiếng Việt ngắn gọn cho [code].
  static String toLabel(int code) {
    if (code == 0) return 'Quang đãng';
    if (code == 1) return 'Ít mây';
    if (code == 2) return 'Có mây';
    if (code == 3) return 'Nhiều mây';
    if (code == 45 || code == 48) return 'Sương mù';
    if (code >= 51 && code <= 53) return 'Mưa phùn nhẹ';
    if (code >= 54 && code <= 55) return 'Mưa phùn';
    if (code >= 56 && code <= 57) return 'Mưa lạnh';
    if (code >= 61 && code <= 63) return 'Mưa nhỏ';
    if (code == 64 || code == 65) return 'Mưa to';
    if (code >= 66 && code <= 67) return 'Mưa lạnh dày';
    if (code >= 71 && code <= 77) return 'Có tuyết';
    if (code >= 80 && code <= 82) return 'Mưa rào';
    if (code >= 85 && code <= 86) return 'Tuyết rào';
    if (code == 95) return 'Giông bão';
    if (code == 96 || code == 99) return 'Giông kèm mưa đá';
    return 'Chưa rõ';
  }

  /// Trả về màu hex (ARGB) gợi ý cho card nền theo [code].
  /// Sử dụng màu Royal Blue palette (nhạt) để phù hợp Design System.
  static int toThemeColor(int code) {
    if (code == 0) return 0xFFFFF9C4; // vàng nắng nhạt
    if (code <= 3) return 0xFFE3F2FD; // xanh da trời nhạt
    if (code == 45 || code == 48) return 0xFFECEFF1; // xám sương
    if (code >= 51 && code <= 67) return 0xFFE8EAF6; // xanh tím mưa phùn
    if (code >= 71 && code <= 77) return 0xFFE0F7FA; // xanh lạnh tuyết
    if (code >= 80 && code <= 82) return 0xFFE3F2FD; // mưa rào nhẹ
    if (code >= 85 && code <= 86) return 0xFFE0F7FA; // tuyết rào
    if (code >= 95 && code <= 99) return 0xFFFCE4EC; // đỏ nhạt giông bão
    return 0xFFE8EAF6;
  }
}
