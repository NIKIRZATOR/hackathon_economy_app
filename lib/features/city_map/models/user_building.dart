class UserBuilding {
  final int idUserBuilding;
  final int idUser;
  final int idBuildingType;
  final int x;
  final int y;
  final int currentLevel;
  final String state;
  final DateTime placedAt;
  final DateTime? lastUpgradeAt;

  // связь с отрисованным Building\зданием
  final String? clientId;

  UserBuilding({
    required this.idUserBuilding,
    required this.idUser,
    required this.idBuildingType,
    required this.x,
    required this.y,
    required this.currentLevel,
    required this.state,
    required this.placedAt,
    this.lastUpgradeAt,
    this.clientId,
  });

  factory UserBuilding.fromJson(Map<String, dynamic> json) => UserBuilding(
    idUserBuilding: json['id_user_building'],
    idUser: json['id_user'],
    idBuildingType: json['id_building_type'],
    x: json['x'],
    y: json['y'],
    currentLevel: json['current_level'],
    state: json['state'],
    placedAt: DateTime.parse(json['placed_at']),
    lastUpgradeAt: json['last_upgrade_at'] != null ? DateTime.parse(json['last_upgrade_at']) : null,
    clientId: json['client_id'],
  );

  Map<String, dynamic> toJson() => {
    'id_user_building': idUserBuilding,
    'id_user': idUser,
    'id_building_type': idBuildingType,
    'x': x,
    'y': y,
    'current_level': currentLevel,
    'state': state,
    'placed_at': placedAt.toUtc().toIso8601String(),
    'last_upgrade_at': lastUpgradeAt?.toUtc().toIso8601String(),
    if (clientId != null) 'client_id': clientId,
  };

  UserBuilding copyWith({
    int? x,
    int? y,
    int? currentLevel,
    String? state,
    DateTime? lastUpgradeAt,
    String? clientId,
  }) => UserBuilding(
    idUserBuilding: idUserBuilding,
    idUser: idUser,
    idBuildingType: idBuildingType,
    x: x ?? this.x,
    y: y ?? this.y,
    currentLevel: currentLevel ?? this.currentLevel,
    state: state ?? this.state,
    placedAt: placedAt,
    lastUpgradeAt: lastUpgradeAt ?? this.lastUpgradeAt,
    clientId: clientId ?? this.clientId,
  );
}
