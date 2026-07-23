import 'package:flutter_test/flutter_test.dart';
import 'dart:ui';

import 'package:codoky/core/utils/extensions/extensions.dart';
import 'package:codoky/core/utils/validators/validators.dart';
import 'package:codoky/core/utils/helpers/helpers.dart';

void main() {
  group('Example Unit Tests', () {
    test('TODO: Add unit tests here', () {
      expect(true, isTrue);
    });

    group('String Extensions', () {
      test('capitalize returns capitalized string', () {
        expect('hello'.capitalize(), equals('Hello'));
        expect('HELLO'.capitalize(), equals('Hello'));
        expect(''.capitalize(), equals(''));
      });

      test('capitalizeWords capitalizes each word', () {
        expect('hello world'.capitalizeWords(), equals('Hello World'));
      });

      test('isValidEmail validates email format', () {
        expect('test@example.com'.isValidEmail(), isTrue);
        expect('invalid-email'.isValidEmail(), isFalse);
        expect('@domain.com'.isValidEmail(), isFalse);
      });

      test('isValidPhoneNumber validates Vietnamese phone numbers', () {
        expect('0901234567'.isValidPhoneNumber(), isTrue);
        expect('+84901234567'.isValidPhoneNumber(), isTrue);
        expect('123456789'.isValidPhoneNumber(), isFalse);
      });

      test('truncate truncates string with suffix', () {
        expect('hello world'.truncate(5), equals('hello...'));
        expect('hi'.truncate(10), equals('hi'));
      });

      test('removeDiacritics removes Vietnamese diacritics', () {
        expect('Tiếng Việt'.removeDiacritics(), equals('Tieng Viet'));
        expect('Đà Nẵng'.removeDiacritics(), equals('Da Nang'));
      });

      test('toSlug creates URL-friendly slug', () {
        expect('Tiếng Việt'.toSlug(), equals('tieng-viet'));
        expect('Hello World!'.toSlug(), equals('hello-world'));
      });
    });

    group('DateTime Extensions', () {
      test('formatDMY formats as DD/MM/YYYY', () {
        final date = DateTime(2024, 1, 15);
        expect(date.formatDMY(), equals('15/01/2024'));
      });

      test('formatTime formats as HH:mm', () {
        final date = DateTime(2024, 1, 15, 14, 30);
        expect(date.formatTime(), equals('14:30'));
      });

      test('timeAgo returns relative time in Vietnamese', () {
        final now = DateTime.now();
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        expect(fiveMinutesAgo.timeAgo(locale: const Locale('vi')), contains('phút trước'));
      });

      test('isToday returns true for today', () {
        expect(DateTime.now().isToday(), isTrue);
      });
    });

    group('List Extensions', () {
      test('uniqueBy removes duplicates by key', () {
        final list = [
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
          {'id': 1, 'name': 'C'},
        ];
        final unique = list.uniqueBy((e) => e['id'] as int);
        expect(unique.length, equals(2));
      });

      test('firstOrNull returns null for empty list', () {
        expect(<int>[].firstOrNull(), isNull);
      });
    });

    group('Num Extensions', () {
      test('formatCurrency formats VND', () {
        expect(1000000.formatCurrency(), equals('1,000,000 ₫'));
        expect(1234567.formatCurrency(), equals('1,234,567 ₫'));
      });

      test('formatCompact formats compact numbers', () {
        expect(1500.formatCompact(), equals('1.5K'));
        expect(2500000.formatCompact(), equals('2.5M'));
      });
    });

    group('Validators', () {
      test('email validator', () {
        expect(Validators.email('invalid'), isNotNull);
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email(''), isNotNull);
      });

      test('password validator', () {
        expect(Validators.password('12345'), isNotNull);
        expect(Validators.password('12345678'), isNull);
        expect(Validators.password(''), isNotNull);
      });

      test('phone validator', () {
        expect(Validators.phone('123'), isNotNull);
        expect(Validators.phone('0901234567'), isNull);
        expect(Validators.phone(''), isNotNull);
      });

      test('required validator', () {
        expect(Validators.required(null, fieldName: 'Name'), isNotNull);
        expect(Validators.required('', fieldName: 'Name'), isNotNull);
        expect(Validators.required('value'), isNull);
      });
    });

    group('Helpers', () {
      test('formatCurrency formats VND', () {
        expect(Helpers.formatCurrency(1000000), equals('1,000,000₫'));
      });

      test('formatDistance formats meters and km', () {
        expect(Helpers.formatDistance(500), equals('500m'));
        expect(Helpers.formatDistance(1500), equals('1.5km'));
      });

      test('formatDuration formats minutes and hours', () {
        expect(Helpers.formatDuration(30), equals('30 min'));
        expect(Helpers.formatDuration(90), equals('1 h 30 min'));
      });
    });
  });
}