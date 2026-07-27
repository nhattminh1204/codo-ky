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
    return UserModel(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      name: json['name'] ?? json['displayName'] ?? 'Người dùng CodoKy',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'] ?? json['photoURL'],
      preferences: List<String>.from(json['preferences'] ?? []),
      membershipTier: json['membership_tier'] ?? 'gold',
      rewardPoints: (json['reward_points'] is int)
          ? json['reward_points']
          : int.tryParse(json['reward_points']?.toString() ?? '350') ?? 350,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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