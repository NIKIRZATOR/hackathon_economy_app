class BuildingType {
  final int idBuildingType;
  final String titleBuildingType;
  final String? description;
  final int cost;
  final int hSize;
  final int wSize;
  final int unlockLevel;
  final int maxUpgradeLvl;
  final String? imageAsset;

  BuildingType({
    required this.idBuildingType,
    required this.titleBuildingType,
    this.description,
    required this.cost,
    required this.hSize,
    required this.wSize,
    required this.unlockLevel,
    required this.maxUpgradeLvl,
    this.imageAsset,
  });

  factory BuildingType.fromJson(Map<String, dynamic> json) => BuildingType(
    idBuildingType: json['id_building_type'] ?? 0,
    titleBuildingType: json['title_building_type'] ?? '',
    description: json['description'],
    cost: json['cost'],
    hSize: json['h_size'] ?? 1,
    wSize: json['w_size'] ?? 1,
    unlockLevel: json['unlock_level'] ?? 1,
    maxUpgradeLvl: json['max_upgrade_lvl'] ?? 1,
    imageAsset: json['image_asset'],
  );

  Map<String, dynamic> toJson() => {
    'id_building_type': idBuildingType,
    'title_building_type': titleBuildingType,
    'description': description,
    'cost': cost,
    'h_size': hSize,
    'w_size': wSize,
    'unlock_level': unlockLevel,
    'max_upgrade_lvl': maxUpgradeLvl,
    'image_asset': imageAsset,
  };

  /// фабрика под моковые данные (ключи id_building / title_building)
  factory BuildingType.fromMockJson(Map<String, dynamic> json) => BuildingType(
    idBuildingType: json['id_building'] ?? 0,
    titleBuildingType: json['title_building'] ?? '',
    description: json['description'],
    cost: json['cost'] ?? 0,
    hSize: json['h_size'] ?? 1,
    wSize: json['w_size'] ?? 1,
    unlockLevel: json['unlock_level'] ?? 1,
    maxUpgradeLvl: json['max_upgrade_lvl'] ?? 1,
    imageAsset: json['image_asset'],
  );
}
