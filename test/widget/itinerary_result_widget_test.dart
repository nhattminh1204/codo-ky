import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/itinerary/presentation/screens/itinerary_result_screen.dart';
import 'package:codoky/features/itinerary/presentation/widgets/place_picker_bottom_sheet.dart';
import 'package:codoky/features/explore/presentation/providers/explore_provider.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'dart:io';

import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:latlong2/latlong.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MockOsrmRemoteService extends OsrmRemoteService {
  MockOsrmRemoteService() : super(apiClient: ApiClient(Dio()));

  @override
  Future<OsrmRoute> getMultiWaypointRoute({
    required List<LatLng> waypoints,
    String profile = 'driving',
  }) async {
    throw Exception('Mocked exception to skip routing calculation');
  }
}

class MockExploreNotifier extends ExploreNotifier {
  MockExploreNotifier() : super();

  @override
  Future<void> loadPlaces({bool refresh = false}) async {
    state = state.copyWith(isLoading: false, allPlaces: [
      {
        'id': 'new_p',
        'name': 'New P',
        'latitude': 16.5,
        'longitude': 107.6,
        'category': 'attraction'
      }
    ], categories: [
      {'id': 'all', 'name': 'Tất cả', 'count': 1}
    ]);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MyHttpOverrides();
  });

  testWidgets('ItineraryResultScreen handles drag and drop reordering correctly', (
    WidgetTester tester,
  ) async {
    // 1. Prepare data
    final activity1 = ItineraryActivityModel(
      id: 'act1',
      name: 'Chùa Thiên Mụ',
      description: 'Chùa cổ kính',
      placeId: 'p1',
      placeName: 'Chùa Thiên Mụ',
      latitude: 16.45,
      longitude: 107.58,
      startTime: DateTime(2026, 1, 1, 8, 0),
      endTime: DateTime(2026, 1, 1, 10, 0),
      type: 'visit',
      status: 'active',
    );
    final activity2 = ItineraryActivityModel(
      id: 'act2',
      name: 'Đại Nội Huế',
      description: 'Kinh thành Huế',
      placeId: 'p2',
      placeName: 'Đại Nội Huế',
      latitude: 16.46,
      longitude: 107.59,
      startTime: DateTime(2026, 1, 1, 10, 30),
      endTime: DateTime(2026, 1, 1, 12, 30),
      type: 'visit',
      status: 'active',
    );
    final activity3 = ItineraryActivityModel(
      id: 'act3',
      name: 'Lăng Tự Đức',
      description: 'Lăng tẩm',
      placeId: 'p3',
      placeName: 'Lăng Tự Đức',
      latitude: 16.47,
      longitude: 107.60,
      startTime: DateTime(2026, 1, 1, 14, 0),
      endTime: DateTime(2026, 1, 1, 16, 0),
      type: 'visit',
      status: 'active',
    );

    final itinerary = ItineraryModel(
      id: 'it1',
      title: 'Lộ trình test',
      description: 'Test',
      durationDays: 1,
      budget: 1000000,
      interests: ['culture'],
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      days: [
        ItineraryDayModel(
          dayNumber: 1,
          title: 'Ngày 1',
          description: 'Ngày 1',
          activities: [activity1, activity2, activity3],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        aiRemoteServiceProvider.overrideWithValue(
          AiRemoteService(apiClient: ApiClient(Dio())),
        ),
        osrmRemoteServiceProvider.overrideWithValue(MockOsrmRemoteService()),
        exploreProvider.overrideWith((ref) => MockExploreNotifier()),
      ],
    );

    container.read(itineraryProvider.notifier).state = ItineraryState(
      myItineraries: [itinerary],
      isLoading: false,
    );

    // Add dummy go router
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ItineraryResultScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('vi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Chùa Thiên Mụ'), findsOneWidget);
    expect(find.text('Đại Nội Huế'), findsOneWidget);
    expect(find.text('Lăng Tự Đức'), findsOneWidget);

    final initialState = container.read(itineraryProvider);
    expect(initialState.myItineraries.first.days[0].activities[0].id, 'act1');
    expect(initialState.myItineraries.first.days[0].activities[1].id, 'act2');
    expect(initialState.myItineraries.first.days[0].activities[2].id, 'act3');

    // ReorderableListView.builder dùng onReorderItem (Flutter ≥ 3.22) thay vì onReorder cũ.
    // onReorderItem nhận newIndex là vị trí đích thật sự (đã tự bù trừ off-by-one nội bộ),
    // khác với onReorder cũ trả về raw index cần caller tự trừ 1 khi kéo xuống.
    // Ta invoke trực tiếp callback để tránh flakiness của gesture drag trong headless test.
    final reorderableListFinder = find.byType(ReorderableListView);
    expect(reorderableListFinder, findsOneWidget);

    final reorderableList = tester.widget<ReorderableListView>(
      reorderableListFinder,
    );

    // Kéo XUỐNG: act1 (index 0) → vị trí đích index 2 (sau act3)
    // onReorderItem đã tự bù trừ — ta truyền newIndex=2 (không phải 3 như onReorder cũ).
    reorderableList.onReorderItem!(0, 2);

    // Wait for the provider to finish its async task (since it's async but returns void)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final updatedState = container.read(itineraryProvider);
    final updatedActivities =
        updatedState.myItineraries.first.days[0].activities;

    // Kết quả mong muốn: act2, act3, act1
    expect(updatedActivities[0].id, 'act2');
    expect(updatedActivities[1].id, 'act3');
    expect(updatedActivities[2].id, 'act1');
  });

  testWidgets('ItineraryResultScreen handles drag UP (reorder from bottom to top) correctly', (
    WidgetTester tester,
  ) async {
    // Kéo NGƯỢC LÊN: bug off-by-one kinh điển CHỈ xảy ra khi kéo xuống (newIndex > oldIndex).
    // Test này xác nhận onReorderItem cũng hoạt động đúng chiều ngược lại.
    final activity1 = ItineraryActivityModel(
      id: 'act1',
      name: 'Chùa Thiên Mụ',
      description: 'Chùa cổ kính',
      placeId: 'p1',
      placeName: 'Chùa Thiên Mụ',
      latitude: 16.45,
      longitude: 107.58,
      startTime: DateTime(2026, 1, 1, 8, 0),
      endTime: DateTime(2026, 1, 1, 10, 0),
      type: 'visit',
      status: 'active',
    );
    final activity2 = ItineraryActivityModel(
      id: 'act2',
      name: 'Đại Nội Huế',
      description: 'Kinh thành Huế',
      placeId: 'p2',
      placeName: 'Đại Nội Huế',
      latitude: 16.46,
      longitude: 107.59,
      startTime: DateTime(2026, 1, 1, 10, 30),
      endTime: DateTime(2026, 1, 1, 12, 30),
      type: 'visit',
      status: 'active',
    );
    final activity3 = ItineraryActivityModel(
      id: 'act3',
      name: 'Lăng Tự Đức',
      description: 'Lăng tẩm',
      placeId: 'p3',
      placeName: 'Lăng Tự Đức',
      latitude: 16.47,
      longitude: 107.60,
      startTime: DateTime(2026, 1, 1, 14, 0),
      endTime: DateTime(2026, 1, 1, 16, 0),
      type: 'visit',
      status: 'active',
    );

    final itinerary = ItineraryModel(
      id: 'it2',
      title: 'Lộ trình test drag-up',
      description: 'Test',
      durationDays: 1,
      budget: 1000000,
      interests: const ['culture'],
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      days: [
        ItineraryDayModel(
          dayNumber: 1,
          title: 'Ngày 1',
          description: 'Ngày 1',
          activities: [activity1, activity2, activity3],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        aiRemoteServiceProvider.overrideWithValue(
          AiRemoteService(apiClient: ApiClient(Dio())),
        ),
        osrmRemoteServiceProvider.overrideWithValue(MockOsrmRemoteService()),
        exploreProvider.overrideWith((ref) => MockExploreNotifier()),
      ],
    );

    container.read(itineraryProvider.notifier).state = ItineraryState(
      myItineraries: [itinerary],
      isLoading: false,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ItineraryResultScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('vi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Xác nhận thứ tự ban đầu: act1, act2, act3
    final initialState = container.read(itineraryProvider);
    expect(initialState.myItineraries.first.days[0].activities[0].id, 'act1');
    expect(initialState.myItineraries.first.days[0].activities[1].id, 'act2');
    expect(initialState.myItineraries.first.days[0].activities[2].id, 'act3');

    final reorderableListFinder = find.byType(ReorderableListView);
    expect(reorderableListFinder, findsOneWidget);

    final reorderableList = tester.widget<ReorderableListView>(reorderableListFinder);

    // Kéo LÊN: act3 (index 2) → vị trí đích index 0 (trước act1)
    // Khi kéo LÊN (newIndex < oldIndex), onReorderItem KHÔNG bù trừ — newIndex là index đích chính xác.
    reorderableList.onReorderItem!(2, 0);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final updatedState = container.read(itineraryProvider);
    final updatedActivities = updatedState.myItineraries.first.days[0].activities;

    // Kết quả mong muốn: act3, act1, act2
    expect(updatedActivities[0].id, 'act3');
    expect(updatedActivities[1].id, 'act1');
    expect(updatedActivities[2].id, 'act2');
  });

  testWidgets('ItineraryResultScreen calls addActivity when valid place is selected', (WidgetTester tester) async {

    final activity1 = ItineraryActivityModel(
      id: 'act1',
      name: 'Chùa Thiên Mụ',
      description: 'Chùa cổ kính',
      placeId: 'p1',
      placeName: 'Chùa Thiên Mụ',
      latitude: 16.45,
      longitude: 107.58,
      startTime: DateTime(2026, 1, 1, 8, 0),
      endTime: DateTime(2026, 1, 1, 10, 0),
      type: 'visit',
      status: 'active',
    );
    final itinerary = ItineraryModel(
      id: 'it1',
      title: 'Lộ trình test',
      description: 'Test',
      durationDays: 1,
      budget: 1000000,
      interests: const ['culture'],
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      days: [
        ItineraryDayModel(
          dayNumber: 1,
          title: 'Ngày 1',
          description: 'Ngày 1',
          activities: [activity1],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        aiRemoteServiceProvider.overrideWithValue(AiRemoteService(apiClient: ApiClient(Dio()))),
        osrmRemoteServiceProvider.overrideWithValue(MockOsrmRemoteService()),
        exploreProvider.overrideWith((ref) => MockExploreNotifier()),
      ],
    );
    container.read(itineraryProvider.notifier).state = ItineraryState(
      myItineraries: [itinerary],
      isLoading: false,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ItineraryResultScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('vi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Thêm điểm đến vào lộ trình'), findsOneWidget);
    await tester.tap(find.text('Thêm điểm đến vào lộ trình'));
    await tester.pumpAndSettle();

    final bottomSheetContext = tester.element(find.byType(PlacePickerBottomSheet));
    Navigator.pop(bottomSheetContext, {
      'id': 'new_p',
      'name': 'New P',
      'latitude': 16.5,
      'longitude': 107.6,
    });
    await tester.pumpAndSettle();

    final updatedState = container.read(itineraryProvider);
    expect(updatedState.myItineraries.first.days[0].activities.length, 2);
    expect(updatedState.myItineraries.first.days[0].activities.any((a) => a.placeId == 'new_p'), true);
  });

  testWidgets('ItineraryResultScreen shows SnackBar and does NOT call addActivity when latitude is missing', (WidgetTester tester) async {
    final activity1 = ItineraryActivityModel(
      id: 'act1',
      name: 'Chùa Thiên Mụ',
      description: 'Chùa cổ kính',
      placeId: 'p1',
      placeName: 'Chùa Thiên Mụ',
      latitude: 16.45,
      longitude: 107.58,
      startTime: DateTime(2026, 1, 1, 8, 0),
      endTime: DateTime(2026, 1, 1, 10, 0),
      type: 'visit',
      status: 'active',
    );
    final itinerary = ItineraryModel(
      id: 'it1',
      title: 'Lộ trình test',
      description: 'Test',
      durationDays: 1,
      budget: 1000000,
      interests: const ['culture'],
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      days: [
        ItineraryDayModel(
          dayNumber: 1,
          title: 'Ngày 1',
          description: 'Ngày 1',
          activities: [activity1],
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        aiRemoteServiceProvider.overrideWithValue(AiRemoteService(apiClient: ApiClient(Dio()))),
        osrmRemoteServiceProvider.overrideWithValue(MockOsrmRemoteService()),
        exploreProvider.overrideWith((ref) => MockExploreNotifier()),
      ],
    );
    container.read(itineraryProvider.notifier).state = ItineraryState(
      myItineraries: [itinerary],
      isLoading: false,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ItineraryResultScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('vi'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thêm điểm đến vào lộ trình'));
    await tester.pumpAndSettle();

    final bottomSheetContext = tester.element(find.byType(PlacePickerBottomSheet));
    Navigator.pop(bottomSheetContext, {
      'id': 'new_p',
      'name': 'New P',
      // latitude bị thiếu
      'longitude': 107.6,
    });
    await tester.pump();

    expect(find.text('Dữ liệu địa điểm không hợp lệ, vui lòng thử lại'), findsOneWidget);
    
    final updatedState = container.read(itineraryProvider);
    expect(updatedState.myItineraries.first.days[0].activities.length, 1);
  });
}
