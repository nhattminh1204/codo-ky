class ItineraryModel {
  final String id;
  final String title;
  final String description;
  final int durationDays;
  final double budget;
  final List<String> interests;
  final List<ItineraryDayModel> days;
  final String? imageUrl;
  final String? thumbnailUrl;
  final double rating;
  final int reviewCount;
  final bool isAIGenerated;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItineraryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.budget,
    required this.interests,
    required this.days,
    this.imageUrl,
    this.thumbnailUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.isAIGenerated = false,
    this.status = 'draft',
    required this.createdAt,
    required this.updatedAt,
  });

  ItineraryModel copyWith({
    String? id,
    String? title,
    String? description,
    int? durationDays,
    double? budget,
    List<String>? interests,
    List<ItineraryDayModel>? days,
    String? imageUrl,
    String? thumbnailUrl,
    double? rating,
    int? reviewCount,
    bool? isAIGenerated,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      budget: budget ?? this.budget,
      interests: interests ?? this.interests,
      days: days ?? this.days,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    final daysList = json['days'] as List? ?? [];
    final duration = json['duration_days'] ?? json['durationDays'] ?? json['total_days'] ?? daysList.length;
    return ItineraryModel(
      id: json['id']?.toString() ?? 'itinerary_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Lộ trình Du lịch Huế',
      description: json['description']?.toString() ?? 'Lộ trình khám phá Cố đô Huế được đề xuất bởi AI.',
      durationDays: duration is int ? duration : (int.tryParse(duration.toString()) ?? 1),
      budget: (json['budget'] ?? json['estimated_budget'] ?? 0).toDouble(),
      interests: (json['interests'] as List? ?? []).map((e) => e.toString()).toList(),
      days: daysList
          .map((e) => ItineraryDayModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString() ?? json['imageUrl']?.toString(),
      rating: (json['rating'] ?? 4.8).toDouble(),
      reviewCount: (json['review_count'] ?? 12) as int,
      isAIGenerated: json['is_ai_generated'] ?? true,
      status: json['status']?.toString() ?? 'draft',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_days': durationDays,
      'budget': budget,
      'interests': interests,
      'days': days.map((e) => e.toJson()).toList(),
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'rating': rating,
      'review_count': reviewCount,
      'is_ai_generated': isAIGenerated,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ItineraryDayModel {
  final int dayNumber;
  final String title;
  final String description;
  final List<ItineraryActivityModel> activities;

  ItineraryDayModel({
    required this.dayNumber,
    required this.title,
    required this.description,
    required this.activities,
  });

  ItineraryDayModel copyWith({
    int? dayNumber,
    String? title,
    String? description,
    List<ItineraryActivityModel>? activities,
  }) {
    return ItineraryDayModel(
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      activities: activities ?? this.activities,
    );
  }

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'] ?? json['items'] ?? json['stops'] ?? [];
    final dayNum = json['day_number'] ?? json['dayNumber'] ?? json['day'] ?? 1;
    return ItineraryDayModel(
      dayNumber: dayNum is int ? dayNum : (int.tryParse(dayNum.toString().replaceAll(RegExp(r'\D'), '')) ?? 1),
      title: json['title']?.toString() ?? 'Ngày $dayNum',
      description: json['description']?.toString() ?? '',
      activities: (rawActivities as List? ?? [])
          .map((e) => ItineraryActivityModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      'title': title,
      'description': description,
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }
}

class ItineraryActivityModel {
  final String id;
  final String name;
  final String description;
  final String placeId;
  final String placeName;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String type; // visit, eat, move, rest
  final double? estimatedCost;
  final String? notes;
  /// Trạng thái hoạt động ('draft'/'active'/'completed') - 'completed' độc lập để đánh dấu check-in/gắn ảnh từng điểm dừng khi lộ trình chung vẫn 'active'
  final String status;

  ItineraryActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.placeId,
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.estimatedCost,
    this.notes,
    this.status = 'draft',
  });

  ItineraryActivityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? placeId,
    String? placeName,
    double? latitude,
    double? longitude,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    double? estimatedCost,
    String? notes,
    String? status,
  }) {
    return ItineraryActivityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  factory ItineraryActivityModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(dynamic raw) {
      if (raw == null) return DateTime.now();
      final str = raw.toString().trim();
      if (str.isEmpty) return DateTime.now();
      try {
        return DateTime.parse(str);
      } catch (_) {}
      final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(str);
      if (match != null) {
        final hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
      return DateTime.now();
    }

    return ItineraryActivityModel(
      id: json['id']?.toString() ?? json['place_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? json['place_name']?.toString() ?? json['title']?.toString() ?? 'Điểm tham quan',
      description: json['description']?.toString() ?? json['notes']?.toString() ?? json['tip']?.toString() ?? '',
      placeId: json['place_id']?.toString() ?? json['id']?.toString() ?? '',
      placeName: json['place_name']?.toString() ?? json['name']?.toString() ?? json['title']?.toString() ?? 'Địa điểm Huế',
      latitude: (json['latitude'] ?? json['lat'] ?? 16.4637).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 107.5909).toDouble(),
      startTime: parseTime(json['start_time'] ?? json['startTime'] ?? json['time']),
      endTime: parseTime(json['end_time'] ?? json['endTime']),
      type: json['type']?.toString() ?? json['category']?.toString() ?? 'visit',
      estimatedCost: json['estimated_cost'] != null ? (json['estimated_cost'] as num).toDouble() : null,
      notes: json['notes']?.toString() ?? json['tip']?.toString() ?? json['description']?.toString(),
      status: json['status']?.toString() ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'place_id': placeId,
      'place_name': placeName,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'type': type,
      'estimated_cost': estimatedCost,
      'notes': notes,
      'status': status,
    };
  }
}