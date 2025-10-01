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

  factory UserBuildingModel.fromJson(Map<String, dynamic> j) =>
      UserBuildingModel(
        idUserBuilding: j['idUserBuilding'] ?? j['id'] ?? j['id_user_building'],
        idUser:
            j['idUser'] ??
            j['userId'] ??
            j['user_userid'] ??
            (j['user']?['userId']),
        idBuildingType:
            j['idBuildingType'] ??
            j['buildingTypeId'] ??
            j['buildingtype_idbuildingtype'] ??
            (j['buildingType']?['idBuildingType']),
        x: j['x'],
        y: j['y'],
        currentLevel: j['currentLevel'],
        state: j['state'],
        placedAt: DateTime.parse(j['placedAt']),
        lastUpgradeAt: j['lastUpgradeAt'] != null
            ? DateTime.parse(j['lastUpgradeAt'])
            : null,
        clientId: j['client_id'] ?? j['clientId'],
      );

  Map<String, dynamic> toJson() => {
    'idUserBuilding': idUserBuilding,
    'idUser': idUser,
    'idBuildingType': idBuildingType,
    'x': x,
    'y': y,
    'currentLevel': currentLevel,
    'state': state,
    'placedAt': placedAt.toUtc().toIso8601String(),
    'lastUpgradeAt': lastUpgradeAt?.toUtc().toIso8601String(),
    if (clientId != null) ...{'client_id': clientId, 'clientId': clientId},
  };

  UserBuildingModel copyWith({
    int? x,
    int? y,
    int? currentLevel,
    String? state,
    DateTime? lastUpgradeAt,
    String? clientId,
  }) => UserBuildingModel(
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
