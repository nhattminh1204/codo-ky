class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String placeId;
  final String placeName;
  final double rating;
  final String? title;
  final String content;
  final List<String> images;
  final int likeCount;
  final List<String> likedByUserIds;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.placeId,
    required this.placeName,
    required this.rating,
    this.title,
    required this.content,
    this.images = const [],
    this.likeCount = 0,
    this.likedByUserIds = const [],
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {}
      return DateTime.now();
    }

    final likedIdsRaw = json['liked_by_user_ids'] ?? json['likedByUserIds'];
    final likedIds = likedIdsRaw is List ? likedIdsRaw.map((e) => e.toString()).toList() : <String>[];

    final imagesRaw = json['images'];
    final imagesList = imagesRaw is List ? imagesRaw.map((e) => e.toString()).toList() : <String>[];

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? json['userName']?.toString() ?? 'Người dùng Huế',
      userAvatarUrl: json['user_avatar_url']?.toString() ?? json['userAvatarUrl']?.toString(),
      placeId: json['place_id']?.toString() ?? json['placeId']?.toString() ?? '',
      placeName: json['place_name']?.toString() ?? json['placeName']?.toString() ?? 'Địa điểm Huế',
      rating: (json['rating'] ?? 5.0).toDouble(),
      title: json['title']?.toString(),
      content: json['content']?.toString() ?? '',
      images: imagesList,
      likeCount: json['like_count'] ?? json['likeCount'] ?? likedIds.length,
      likedByUserIds: likedIds,
      commentCount: json['comment_count'] ?? json['commentCount'] ?? 0,
      isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'place_id': placeId,
      'place_name': placeName,
      'rating': rating,
      'title': title,
      'content': content,
      'images': images,
      'like_count': likeCount,
      'liked_by_user_ids': likedByUserIds,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? placeId,
    String? placeName,
    double? rating,
    String? title,
    String? content,
    List<String>? images,
    int? likeCount,
    List<String>? likedByUserIds,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}