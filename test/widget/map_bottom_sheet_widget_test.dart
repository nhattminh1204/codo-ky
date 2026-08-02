import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';

class MockOsrmRemoteService implements OsrmRemoteService {
  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<OsrmRoute>> getRoutes({required LatLng start, required LatLng end, String profile = 'driving', bool alternatives = true}) async {
    return [];
  }

  @override
  Future<OsrmRoute> getDrivingRoute({required LatLng start, required LatLng end, String profile = 'driving'}) async {
    return OsrmRoute(points: [], distanceMeters: 0, durationSeconds: 0);
  }
}

class MapNotifierMock extends MapNotifier {
  MapNotifierMock() : super(osrmRemoteService: MockOsrmRemoteService());
}

class ReviewNotifierMock extends StateNotifier<ReviewState> implements ReviewNotifier {
  ReviewNotifierMock() : super(const ReviewState());

  @override
  Future<void> loadReviews() async {}

  @override
  Future<void> loadAllReviews({String? placeId, bool refresh = false}) async {}

  @override
  Future<void> loadMyReviews({bool refresh = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MapBottomSheet Expand & Gesture Tests', () {
    final mockPlace = {
      'id': 'p_101',
      'name': 'Đại Nội Huế',
      'category': 'attraction',
      'address': 'Đường 23/8, Thuận Hòa, Thành phố Huế',
      'rating': 4.9,
      'review_count': 342,
      'latitude': 16.4637,
      'longitude': 107.5909,
      'open_hours': '07:00 - 17:30 (Thứ 2 - Chủ Nhật)',
      'ticket_price': '200.000 VNĐ / Người lớn',
      'phone': '0234 3523 237',
      'description': 'Đại Nội Huế là quần thể di tích Hoàng thành thuộc Quần thể di tích Cố đô Huế.',
      'image_url': '',
    };

    testWidgets('1. Renders compact preview mode initially with swipe up hint', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapProvider.overrideWith((ref) => MapNotifierMock()),
            reviewProvider.overrideWith((ref) => ReviewNotifierMock()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 600,
                  child: MapBottomSheet(
                    place: mockPlace,
                    onClose: () {},
                    onNavigate: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MapBottomSheet), findsOneWidget);
      expect(find.text('Đại Nội Huế'), findsOneWidget);
      expect(find.text('Giới thiệu & Lịch sử'), findsNothing);
    });

    testWidgets('2. Expands UPWARDS on gesture or tap to reveal place detail and collapses back', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapProvider.overrideWith((ref) => MapNotifierMock()),
            reviewProvider.overrideWith((ref) => ReviewNotifierMock()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  height: 600,
                  child: MapBottomSheet(
                    place: mockPlace,
                    onClose: () {},
                    onNavigate: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Fling UP to expand
      await tester.fling(find.byType(MapBottomSheet), const Offset(0, -300), 1000);
      await tester.pumpAndSettle();

      // Verify expanded detail view elements appear
      expect(find.text('Giới thiệu & Lịch sử'), findsOneWidget);
      expect(find.text('Đánh giá & Trải nghiệm'), findsOneWidget);
      expect(find.text('Gọi điện'), findsOneWidget);
      expect(find.text('Bản đồ ngoài'), findsOneWidget);

      // Tap collapse button to collapse back
      final collapseButtonFinder = find.byIcon(Icons.keyboard_arrow_down_rounded);
      await tester.tap(collapseButtonFinder);
      await tester.pumpAndSettle();

      // Verify collapsed back to compact view
      expect(find.text('Giới thiệu & Lịch sử'), findsNothing);
    });
  });
}
