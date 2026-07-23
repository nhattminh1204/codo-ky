import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/review/data/models/review_model.dart';

class ReviewState {
  final List<ReviewModel> allReviews;
  final List<ReviewModel> myReviews;
  final bool isLoadingAll;
  final bool isLoadingMine;
  final String? error;
  final bool hasMoreAll;
  final bool hasMoreMine;

  const ReviewState({
    this.allReviews = const [],
    this.myReviews = const [],
    this.isLoadingAll = false,
    this.isLoadingMine = false,
    this.error,
    this.hasMoreAll = false,
    this.hasMoreMine = false,
  });

  ReviewState copyWith({
    List<ReviewModel>? allReviews,
    List<ReviewModel>? myReviews,
    bool? isLoadingAll,
    bool? isLoadingMine,
    String? error,
    bool? hasMoreAll,
    bool? hasMoreMine,
  }) {
    return ReviewState(
      allReviews: allReviews ?? this.allReviews,
      myReviews: myReviews ?? this.myReviews,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingMine: isLoadingMine ?? this.isLoadingMine,
      error: error ?? this.error,
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      hasMoreMine: hasMoreMine ?? this.hasMoreMine,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(const ReviewState());

  Future<void> loadReviews() async {
    await Future.wait([loadAllReviews(), loadMyReviews()]);
  }

  Future<void> loadAllReviews() async {
    state = state.copyWith(isLoadingAll: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Load from API
      state = state.copyWith(
        allReviews: [],
        isLoadingAll: false,
        hasMoreAll: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingAll: false, error: e.toString());
    }
  }

  Future<void> loadMyReviews() async {
    state = state.copyWith(isLoadingMine: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Load from API
      state = state.copyWith(
        myReviews: [],
        isLoadingMine: false,
        hasMoreMine: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMine: false, error: e.toString());
    }
  }

  Future<void> loadMoreReviews() async {
    // TODO: Implement pagination
    state = state.copyWith(hasMoreAll: false);
  }

  Future<void> loadMoreMyReviews() async {
    // TODO: Implement pagination
    state = state.copyWith(hasMoreMine: false);
  }

  Future<void> createReview(ReviewModel review) async {
    // TODO: Create via API
    state = state.copyWith(
      myReviews: [review, ...state.myReviews],
      allReviews: [review, ...state.allReviews],
    );
  }

  Future<void> updateReview(ReviewModel review) async {
    // TODO: Update via API
    state = state.copyWith(
      myReviews: state.myReviews.map((r) => r.id == review.id ? review : r).toList(),
      allReviews: state.allReviews.map((r) => r.id == review.id ? review : r).toList(),
    );
  }

  Future<void> deleteReview(String reviewId) async {
    // TODO: Delete via API
    state = state.copyWith(
      myReviews: state.myReviews.where((r) => r.id != reviewId).toList(),
      allReviews: state.allReviews.where((r) => r.id != reviewId).toList(),
    );
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier();
});