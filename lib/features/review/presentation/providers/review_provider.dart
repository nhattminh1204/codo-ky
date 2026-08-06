import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/config/localization/locale_provider.dart';
import 'package:codoky/features/review/data/models/review_model.dart';

class ReviewState {
  final List<ReviewModel> allReviews;
  final List<ReviewModel> myReviews;
  final bool isLoadingAll;
  final bool isLoadingMine;
  final bool isRefreshingAll;
  final bool isRefreshingMine;
  final String? error;
  final bool hasMoreAll;
  final bool hasMoreMine;
  final DocumentSnapshot? lastDocAll;
  final DocumentSnapshot? lastDocMine;

  const ReviewState({
    this.allReviews = const [],
    this.myReviews = const [],
    this.isLoadingAll = false,
    this.isLoadingMine = false,
    this.isRefreshingAll = false,
    this.isRefreshingMine = false,
    this.error,
    this.hasMoreAll = false,
    this.hasMoreMine = false,
    this.lastDocAll,
    this.lastDocMine,
  });

  ReviewState copyWith({
    List<ReviewModel>? allReviews,
    List<ReviewModel>? myReviews,
    bool? isLoadingAll,
    bool? isLoadingMine,
    bool? isRefreshingAll,
    bool? isRefreshingMine,
    String? error,
    bool clearError = false,
    bool? hasMoreAll,
    bool? hasMoreMine,
    DocumentSnapshot? lastDocAll,
    DocumentSnapshot? lastDocMine,
  }) {
    return ReviewState(
      allReviews: allReviews ?? this.allReviews,
      myReviews: myReviews ?? this.myReviews,
      isLoadingAll: isLoadingAll ?? this.isLoadingAll,
      isLoadingMine: isLoadingMine ?? this.isLoadingMine,
      isRefreshingAll: isRefreshingAll ?? this.isRefreshingAll,
      isRefreshingMine: isRefreshingMine ?? this.isRefreshingMine,
      error: clearError ? null : (error ?? this.error),
      hasMoreAll: hasMoreAll ?? this.hasMoreAll,
      hasMoreMine: hasMoreMine ?? this.hasMoreMine,
      lastDocAll: lastDocAll ?? this.lastDocAll,
      lastDocMine: lastDocMine ?? this.lastDocMine,
    );
  }
}

class ReviewNotifier extends StateNotifier<ReviewState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Ref? ref;

  ReviewNotifier({FirebaseFirestore? firestore, FirebaseAuth? auth, this.ref})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ReviewState()) {
    loadReviews();
  }

  AppLocalizations get _t =>
      AppLocalizations(ref?.read(localeProvider) ?? const Locale('vi'));

  Future<void> loadReviews() async {
    await Future.wait([loadAllReviews(), loadMyReviews()]);
  }

  Future<void> loadAllReviews({String? placeId, bool refresh = false}) async {
    if ((state.isLoadingAll || state.isRefreshingAll) && !refresh) return;

    final hasExistingData = state.allReviews.isNotEmpty;
    if (hasExistingData && refresh) {
      // SWR: Preserve existing reviews in RAM during background refresh
      state = state.copyWith(isRefreshingAll: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingAll: true, clearError: true);
    }

    try {
      Query query = _firestore.collection('reviews').orderBy('created_at', descending: true);
      if (placeId != null && placeId.isNotEmpty) {
        query = query.where('place_id', isEqualTo: placeId);
      }

      final snapshot = await query.limit(10).get();
      final currentUid = _auth.currentUser?.uid ?? '';

      final reviews = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final likedIds = (data['liked_by_user_ids'] as List? ?? []).map((e) => e.toString()).toList();
        data['is_liked'] = currentUid.isNotEmpty && likedIds.contains(currentUid);
        return ReviewModel.fromJson(data);
      }).toList();

      state = state.copyWith(
        allReviews: reviews,
        isLoadingAll: false,
        isRefreshingAll: false,
        hasMoreAll: snapshot.docs.length >= 10,
        lastDocAll: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      AppLogger.w('Firestore loadAllReviews fallback or error: $e');
      state = state.copyWith(
        isLoadingAll: false,
        isRefreshingAll: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMyReviews({bool refresh = false}) async {
    final currentUid = _auth.currentUser?.uid;
    if (currentUid == null || currentUid.isEmpty) {
      state = state.copyWith(myReviews: [], isLoadingMine: false, isRefreshingMine: false);
      return;
    }

    if ((state.isLoadingMine || state.isRefreshingMine) && !refresh) return;

    final hasExistingMine = state.myReviews.isNotEmpty;
    if (hasExistingMine && refresh) {
      state = state.copyWith(isRefreshingMine: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMine: true, clearError: true);
    }

    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('user_id', isEqualTo: currentUid)
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      final reviews = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final likedIds = (data['liked_by_user_ids'] as List? ?? []).map((e) => e.toString()).toList();
        data['is_liked'] = likedIds.contains(currentUid);
        return ReviewModel.fromJson(data);
      }).toList();

      state = state.copyWith(
        myReviews: reviews,
        isLoadingMine: false,
        isRefreshingMine: false,
        hasMoreMine: snapshot.docs.length >= 10,
        lastDocMine: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      );
    } catch (e) {
      AppLogger.w('Firestore loadMyReviews fallback or error: $e');
      state = state.copyWith(
        isLoadingMine: false,
        isRefreshingMine: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMoreReviews({String? placeId}) async {
    if (!state.hasMoreAll || state.lastDocAll == null) return;

    try {
      Query query = _firestore.collection('reviews').orderBy('created_at', descending: true);
      if (placeId != null && placeId.isNotEmpty) {
        query = query.where('place_id', isEqualTo: placeId);
      }

      final snapshot = await query.startAfterDocument(state.lastDocAll!).limit(10).get();
      final currentUid = _auth.currentUser?.uid ?? '';

      final newReviews = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data() as Map);
        data['id'] = doc.id;
        final likedIds = (data['liked_by_user_ids'] as List? ?? []).map((e) => e.toString()).toList();
        data['is_liked'] = currentUid.isNotEmpty && likedIds.contains(currentUid);
        return ReviewModel.fromJson(data);
      }).toList();

      state = state.copyWith(
        allReviews: [...state.allReviews, ...newReviews],
        hasMoreAll: snapshot.docs.length >= 10,
        lastDocAll: snapshot.docs.isNotEmpty ? snapshot.docs.last : state.lastDocAll,
      );
    } catch (e) {
      AppLogger.w('Firestore loadMoreReviews error: $e');
    }
  }

  Future<void> createReview(ReviewModel review) async {
    try {
      final docRef = _firestore.collection('reviews').doc();
      final currentUid = _auth.currentUser?.uid ?? (review.userId.isNotEmpty ? review.userId : 'user_guest');
      final currentName = _auth.currentUser?.displayName ?? (review.userName.isNotEmpty ? review.userName : _t.userHue);

      final newReview = review.copyWith(
        id: docRef.id,
        userId: currentUid,
        userName: currentName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newReview.toJson());

      state = state.copyWith(
        myReviews: [newReview, ...state.myReviews],
        allReviews: [newReview, ...state.allReviews],
      );
    } catch (e) {
      AppLogger.e('Error creating review on Firestore: $e', e);
      throw Exception(_t.cannotSubmitReview(e.toString()));
    }
  }

  Future<void> updateReview(ReviewModel review) async {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid != null && review.userId.isNotEmpty && review.userId != currentUid) {
        throw Exception(_t.noPermissionEdit);
      }

      final updatedReview = review.copyWith(updatedAt: DateTime.now());
      await _firestore.collection('reviews').doc(review.id).update(updatedReview.toJson());

      state = state.copyWith(
        myReviews: state.myReviews.map((r) => r.id == review.id ? updatedReview : r).toList(),
        allReviews: state.allReviews.map((r) => r.id == review.id ? updatedReview : r).toList(),
      );
    } catch (e) {
      AppLogger.e('Error updating review on Firestore: $e', e);
      throw Exception(_t.cannotUpdateReview(e.toString()));
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();

      state = state.copyWith(
        myReviews: state.myReviews.where((r) => r.id != reviewId).toList(),
        allReviews: state.allReviews.where((r) => r.id != reviewId).toList(),
      );
    } catch (e) {
      AppLogger.e('Error deleting review on Firestore: $e', e);
      throw Exception(_t.cannotDeleteReview(e.toString()));
    }
  }

  Future<void> toggleLikeReview(String reviewId) async {
    final currentUid = _auth.currentUser?.uid;

    final reviewIndexAll = state.allReviews.indexWhere((r) => r.id == reviewId);
    if (reviewIndexAll == -1) return;
    final review = state.allReviews[reviewIndexAll];

    final isLikedCurrently = review.isLiked;
    final newLikeCount = isLikedCurrently ? (review.likeCount - 1).clamp(0, 999999) : review.likeCount + 1;
    final newLikedIds = List<String>.from(review.likedByUserIds);

    if (currentUid != null) {
      if (isLikedCurrently) {
        newLikedIds.remove(currentUid);
      } else {
        newLikedIds.add(currentUid);
      }
    }

    final updated = review.copyWith(
      isLiked: !isLikedCurrently,
      likeCount: newLikeCount,
      likedByUserIds: newLikedIds,
    );

    state = state.copyWith(
      allReviews: state.allReviews.map((r) => r.id == reviewId ? updated : r).toList(),
      myReviews: state.myReviews.map((r) => r.id == reviewId ? updated : r).toList(),
    );

    try {
      final docRef = _firestore.collection('reviews').doc(reviewId);
      if (isLikedCurrently) {
        await docRef.update({
          'like_count': FieldValue.increment(-1),
          if (currentUid != null) 'liked_by_user_ids': FieldValue.arrayRemove([currentUid]),
        });
      } else {
        await docRef.update({
          'like_count': FieldValue.increment(1),
          if (currentUid != null) 'liked_by_user_ids': FieldValue.arrayUnion([currentUid]),
        });
      }
    } catch (e) {
      AppLogger.w('Firestore toggleLikeReview error: $e');
    }
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>((ref) {
  return ReviewNotifier(ref: ref);
});