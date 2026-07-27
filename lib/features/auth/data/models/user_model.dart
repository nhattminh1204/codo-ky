class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final List<String> preferences;
  final String membershipTier; // 'standard' | 'gold' | 'vip'
  final int rewardPoints;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.preferences = const [],
    this.membershipTier = 'gold',
    this.rewardPoints = 350,
    required this.createdAt,
  });

  bool get isGold => membershipTier.toLowerCase() == 'gold' || rewardPoints >= 300;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Safe String extraction
    String safeString(dynamic val, [String fallback = '']) {
      if (val == null) return fallback;
      final str = val.toString().trim();
      return str.isEmpty ? fallback : str;
    }

    // 2. Safe Avatar URL extraction
    String? safeAvatarUrl(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      if (str.isEmpty || str == 'null' || str == 'undefined') return null;
      return str;
    }

    // 3. Safe Preferences List extraction (handles nulls & non-strings gracefully)
    List<String> safePreferences(dynamic val) {
      if (val == null) return const [];
      if (val is List) {
        return val
            .map((item) => item?.toString().trim())
            .where((item) => item != null && item.isNotEmpty && item != 'null')
            .cast<String>()
            .toList();
      }
      return const [];
    }

    // 4. Safe Reward Points extraction
    int safePoints(dynamic val) {
      if (val == null) return 350;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 350;
    }

    // 5. Safe DateTime extraction (supports Timestamp, String, DateTime, int)
    DateTime safeDateTime(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        if (val.trim().isEmpty) return DateTime.now();
        return DateTime.tryParse(val.trim()) ?? DateTime.now();
      }
      // Firestore Timestamp support
      try {
        final dynamic timestamp = val;
        if (timestamp.toDate != null) {
          return timestamp.toDate() as DateTime;
        }
      } catch (_) {}
      return DateTime.now();
    }

    return UserModel(
      id: safeString(json['id'] ?? json['uid'], ''),
      name: safeString(json['name'] ?? json['displayName'], 'Người dùng CodoKy'),
      email: safeString(json['email'], ''),
      phone: safeString(json['phone'], ''),
      avatarUrl: safeAvatarUrl(json['avatar_url'] ?? json['avatarUrl'] ?? json['photoURL']),
      preferences: safePreferences(json['preferences']),
      membershipTier: safeString(json['membership_tier'] ?? json['membershipTier'], 'gold'),
      rewardPoints: safePoints(json['reward_points'] ?? json['rewardPoints']),
      createdAt: safeDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'preferences': preferences,
      'membership_tier': membershipTier,
      'reward_points': rewardPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    List<String>? preferences,
    String? membershipTier,
    int? rewardPoints,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferences: preferences ?? this.preferences,
      membershipTier: membershipTier ?? this.membershipTier,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}