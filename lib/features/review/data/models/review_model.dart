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
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      userAvatarUrl: json['user_avatar_url'],
      placeId: json['place_id']?.toString() ?? '',
      placeName: json['place_name'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      title: json['title'],
      content: json['content'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
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
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}