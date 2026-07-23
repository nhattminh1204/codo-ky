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
    required this.createdAt,
    required this.updatedAt,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      budget: (json['budget'] ?? 0).toDouble(),
      interests: List<String>.from(json['interests'] ?? []),
      days: (json['days'] as List? ?? [])
          .map((e) => ItineraryDayModel.fromJson(e))
          .toList(),
      imageUrl: json['image_url'],
      thumbnailUrl: json['thumbnail_url'] ?? json['image_url'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isAIGenerated: json['is_ai_generated'] ?? false,
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

  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) {
    return ItineraryDayModel(
      dayNumber: json['day_number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      activities: (json['activities'] as List? ?? [])
          .map((e) => ItineraryActivityModel.fromJson(e))
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
  });

  factory ItineraryActivityModel.fromJson(Map<String, dynamic> json) {
    return ItineraryActivityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      placeId: json['place_id'] ?? '',
      placeName: json['place_name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now(),
      type: json['type'] ?? 'visit',
      estimatedCost: json['estimated_cost']?.toDouble(),
      notes: json['notes'],
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
    };
  }
}