class UserModel {
  final int? userId;
  final String username;
  final String? cityTitle;
  final int userLvl;
  final int userXp;
  final DateTime? lastClaimAt;

  UserModel({
    required this.userId,
    required this.username,
    this.cityTitle,
    required this.userLvl,
    required this.userXp,
    this.lastClaimAt,
  });

  // парсер ДЛЯ ОТВЕТА СЕРВЕРА (допускаем оба формата ключей)
  factory UserModel.fromApiJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'] ?? json['userId'],
    username: (json['username'] ?? '') as String,
    cityTitle: json['cityTitle'] as String?,
    userLvl: (json['user_lvl'] ?? json['userLvl'] ?? 1) as int,
    userXp: (json['user_xp'] ?? json['userXp'] ?? 0) as int,
    lastClaimAt: (json['last_claim_at'] ?? json['lastClaimAt']) != null
        ? DateTime.parse((json['last_claim_at'] ?? json['lastClaimAt']) as String)
        : null,
  );

  // парсер ДЛЯ ЛОКАЛЬНОГО КЭША (используем ровно то, что сами пишем)
  factory UserModel.fromCacheJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'] as int?,
    username: (json['username'] ?? '') as String,
    cityTitle: json['cityTitle'] as String?,
    userLvl: (json['user_lvl'] ?? 1) as int,
    userXp: (json['user_xp'] ?? 0) as int,
    lastClaimAt: json['last_claim_at'] != null
        ? DateTime.parse(json['last_claim_at'] as String)
        : null,
  );

  Map<String, dynamic> toCacheJson() => {
    'user_id': userId,
    'username': username,
    'cityTitle': cityTitle,
    'user_lvl': userLvl,
    'user_xp': userXp,
    'last_claim_at': lastClaimAt?.toIso8601String(),
  };
}
