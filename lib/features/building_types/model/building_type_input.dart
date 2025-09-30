class BuildingTypeInputModel {
  final int idBuildingTypeInput;
  final int idBuildingType; // building_type.id_building
  final int idResource; // resource_items.id_item
  final double consumePerSec;
  final double amountPerSec;

  BuildingTypeInputModel({
    required this.idBuildingTypeInput,
    required this.idBuildingType,
    required this.idResource,
    required this.consumePerSec,
    required this.amountPerSec,
  });

  factory BuildingTypeInputModel.fromJson(Map<String, dynamic> json) => BuildingTypeInputModel(
    idBuildingTypeInput: json['idBuildingTypeInput'] ?? json['id'],
    idBuildingType: json['idBuildingType'],
    idResource: json['idResource'],
    consumePerSec: json['consumePerSec'] ?? 0,
    amountPerSec: json['amountPerSec'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'idBuildingTypeInput': idBuildingTypeInput,
    'idBuildingType': idBuildingType,
    'idResource': idResource,
    'consumePerSec': consumePerSec,
    'amountPerSec': amountPerSec,
  };
}
