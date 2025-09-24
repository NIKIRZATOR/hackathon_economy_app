// user_model.dart
class UserModel {
  final int? userId;
  final String username;
  final String? name;
  final int userLvl;
  final int userXp;
  final DateTime? lastClaimAt;

  UserModel({
    this.userId,
    required this.username,
    this.name,
    required this.userLvl,
    required this.userXp,
    this.lastClaimAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'],
    username: json['username'] ?? '',
    name: json['name'],
    userLvl: json['user_lvl'] ?? 1,
    userXp: json['user_xp'] ?? 0,
    lastClaimAt: json['last_claim_at'] != null
        ? DateTime.parse(json['last_claim_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    if (userId != null) 'user_id': userId,
    'username': username,
    'name': name,
    'user_lvl': userLvl,
    'user_xp': userXp,
    'last_claim_at': lastClaimAt?.toIso8601String(),
  };
}
