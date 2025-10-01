class BuildingTypeInputModel {
  final int idBuildingTypeInput;
  final int idBuildingType; // building_type.id_building
  final int idResource; // resource_items.id_item

  final String? consumeMode; // per_sec | per_cycle | null
  final double? consumePerCycle; // расход за цикл
  final int? cycleDuration; // сек (если per_cycle)
  final int? bufferForResource;

  final double? consumePerSec;
  final double? amountPerSec;

  // храним вложенные объекты целиком
  final Map<String, dynamic>? buildingType;
  final Map<String, dynamic>? resource;

  BuildingTypeInputModel({
    required this.idBuildingTypeInput,
    required this.idBuildingType,
    required this.idResource,
    this.consumeMode,
    this.consumePerCycle,
    this.cycleDuration,
    this.bufferForResource,
    this.consumePerSec,
    this.amountPerSec,
    this.buildingType,
    this.resource,
  });

  factory BuildingTypeInputModel.fromJson(Map<String, dynamic> json) {
    final bt = (json['buildingType'] as Map<String, dynamic>?) ?? const {};
    final res = (json['resource'] as Map<String, dynamic>?) ?? const {};

    return BuildingTypeInputModel(
      idBuildingTypeInput: json['idBuildingTypeInput'] ?? json['id'],
      idBuildingType: bt['idBuildingType'] ?? json['idBuildingType'],
      idResource: res['idResource'] ?? json['idResource'] ?? res['idItem'],
      consumeMode: json['consumeMode'],
      consumePerCycle: (json['consumePerCycle'] as num?)?.toDouble(),
      cycleDuration: json['cycleDuration'],
      bufferForResource: json['bufferForResource'],
      consumePerSec: (json['consumePerSec'] as num?)?.toDouble(),
      amountPerSec: (json['amountPerSec'] as num?)?.toDouble(),
      buildingType: json['buildingType'] as Map<String, dynamic>?,
      resource: json['resource'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'idBuildingTypeInput': idBuildingTypeInput,
    'idBuildingType': idBuildingType,
    'idResource': idResource,
    if (consumeMode != null) 'consumeMode': consumeMode,
    if (consumePerCycle != null) 'consumePerCycle': consumePerCycle,
    if (cycleDuration != null) 'cycleDuration': cycleDuration,
    if (bufferForResource != null) 'bufferForResource': bufferForResource,
    if (consumePerSec != null) 'consumePerSec': consumePerSec,
    if (amountPerSec != null) 'amountPerSec': amountPerSec,
    if (buildingType != null) 'buildingType': buildingType,
    if (resource != null) 'resource': resource,
  };
}
