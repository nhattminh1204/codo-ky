import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/review/data/models/review_model.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReviewModel & ReviewNotifier Unit Tests', () {
    test('ReviewModel.fromJson and toJson work accurately', () {
      final now = DateTime.now();
      final review = ReviewModel(
        id: 'rev_123',
        userId: 'usr_456',
        userName: 'Nguyễn Văn A',
        placeId: 'place_789',
        placeName: 'Đại Nội Huế',
        rating: 5.0,
        title: 'Trải nghiệm tuyệt vời',
        content: 'Hoàng Thành rất tráng lệ.',
        images: ['https://example.com/img1.jpg'],
        likeCount: 15,
        likedByUserIds: ['usr_456', 'usr_789'],
        isLiked: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = review.toJson();
      expect(json['id'], equals('rev_123'));
      expect(json['user_id'], equals('usr_456'));
      expect(json['liked_by_user_ids'], contains('usr_456'));

      final parsed = ReviewModel.fromJson(json);
      expect(parsed.id, equals('rev_123'));
      expect(parsed.userName, equals('Nguyễn Văn A'));
      expect(parsed.likedByUserIds.length, equals(2));
      expect(parsed.rating, equals(5.0));
    });

    test('ReviewState copyWith handles review updates', () {
      final state = ReviewState();
      expect(state.allReviews, isEmpty);
      expect(state.myReviews, isEmpty);

      final review = ReviewModel(
        id: 'r1',
        userId: 'u1',
        userName: 'Test User',
        placeId: 'p1',
        placeName: 'Chùa Thiên Mụ',
        rating: 4.8,
        content: 'Chùa rất đẹp',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedState = state.copyWith(
        allReviews: [review],
        myReviews: [review],
        isLoadingAll: false,
      );

      expect(updatedState.allReviews.length, equals(1));
      expect(updatedState.myReviews.length, equals(1));
      expect(updatedState.allReviews.first.placeName, equals('Chùa Thiên Mụ'));
    });

    test('ReviewState clearError and error handling work properly', () {
      var state = const ReviewState(isLoadingAll: true, error: 'Lỗi tải đánh giá');
      expect(state.error, equals('Lỗi tải đánh giá'));

      state = state.copyWith(isLoadingAll: false, clearError: true);

      expect(state.isLoadingAll, isFalse);
      expect(state.error, isNull);
    });

    test('ReviewState handles SWR isRefreshingAll and isRefreshingMine flags accurately', () {
      var state = const ReviewState();
      expect(state.isRefreshingAll, isFalse);
      expect(state.isRefreshingMine, isFalse);

      state = state.copyWith(isRefreshingAll: true, isRefreshingMine: true);

      expect(state.isRefreshingAll, isTrue);
      expect(state.isRefreshingMine, isTrue);

      state = state.copyWith(isRefreshingAll: false, isRefreshingMine: false);

      expect(state.isRefreshingAll, isFalse);
      expect(state.isRefreshingMine, isFalse);
    });
  });
}
