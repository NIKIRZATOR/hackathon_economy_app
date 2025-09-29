class UserBuildingModel {
  final int idUserBuilding;
  final int idUser;
  final int idBuildingType;
  final int x;
  final int y;
  final int currentLevel;
  final String state; // будем хранить 'placed'
  final DateTime placedAt;
  final DateTime? lastUpgradeAt;

  // связь с отрисованным Building\зданием
  final String? clientId;

  UserBuildingModel({
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

  factory UserBuildingModel.fromJson(Map<String, dynamic> json) => UserBuildingModel(
    idUserBuilding: json['idUserBuilding'],
    idUser: json['idUser'],
    idBuildingType: json['idBuildingType'],
    x: json['x'],
    y: json['y'],
    currentLevel: json['currentLevel'],
    state: json['state'],
    placedAt: DateTime.parse(json['placedAt']),
    lastUpgradeAt: json['lastUpgradeAt'] != null ? DateTime.parse(json['lastUpgradeAt']) : null,
    clientId: json['client_id'],
  );

  Map<String, dynamic> toJson() => {
    'idUserBuilding': idUserBuilding,
    'idUser': idUser, // <-- фикс опечатки
    'idBuildingType': idBuildingType,
    'x': x,
    'y': y,
    'currentLevel': currentLevel,
    'state': state, // всегда 'placed'
    'placedAt': placedAt.toUtc().toIso8601String(),
    'lastUpgradeAt': lastUpgradeAt?.toUtc().toIso8601String(),
    if (clientId != null) 'client_id': clientId,
  };

  UserBuildingModel copyWith({
    int? x,
    int? y,
    int? currentLevel,
    String? state,
    DateTime? lastUpgradeAt,
    String? clientId,
  }) =>
      UserBuildingModel(
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
