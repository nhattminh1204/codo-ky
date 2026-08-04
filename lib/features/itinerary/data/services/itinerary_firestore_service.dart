import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';

/// Service ghi/đọc lộ trình (itineraries) vào Firestore.
///
/// Mỗi doc là 1 root collection `itineraries`, có field `user_id` để phân quyền
/// owner-only (khớp với rule `/itineraries/{itineraryId}` trong firestore.rules).
class ItineraryFirestoreService {
  final FirebaseFirestore _firestore;

  ItineraryFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lưu lộ trình vào `itineraries/{itinerary.id}`.
  ///
  /// Dùng `.set(..., merge: true)` nên vừa tạo mới vừa cập nhật được, không tạo
  /// bản ghi trùng khi lưu lại cùng id.
  ///
  /// Throws [ItineraryPersistenceException] nếu Firestore lỗi.
  Future<void> saveItinerary(ItineraryModel itinerary, String userId) async {
    try {
      final data = itinerary.toJson()..['user_id'] = userId;
      await _firestore
          .collection('itineraries')
          .doc(itinerary.id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw ItineraryPersistenceException(
        'Không thể lưu lộ trình "${itinerary.title}": $e',
        cause: e,
      );
    }
  }

  /// Lấy danh sách lộ trình của đúng [userId].
  ///
  /// Throws [ItineraryPersistenceException] nếu Firestore lỗi.
  Future<List<ItineraryModel>> getMyItineraries(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('itineraries')
          .where('user_id', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => ItineraryModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ItineraryPersistenceException(
        'Không thể đọc danh sách lộ trình của user $userId: $e',
        cause: e,
      );
    }
  }

  /// Xoá lộ trình theo [itineraryId].
  ///
  /// Throws [ItineraryPersistenceException] nếu Firestore lỗi.
  Future<void> deleteItinerary(String itineraryId) async {
    try {
      await _firestore.collection('itineraries').doc(itineraryId).delete();
    } catch (e) {
      throw ItineraryPersistenceException(
        'Không thể xoá lộ trình $itineraryId: $e',
        cause: e,
      );
    }
  }
}

/// Exception riêng cho persistence của itinerary — có thể catch cụ thể trong UI.
class ItineraryPersistenceException implements Exception {
  final String message;
  final Object? cause;

  const ItineraryPersistenceException(this.message, {this.cause});

  @override
  String toString() => 'ItineraryPersistenceException: $message';
}
