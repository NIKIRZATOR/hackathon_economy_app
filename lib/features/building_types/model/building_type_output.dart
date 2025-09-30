class BuildingTypeOutputModel {
  final int idBuildingTypeOutput;
  final int idBuildingType; // building_type.id_building
  final int idResource; // resource_items.id_item
  final String? produceMode; // per_sec | per_cycle | null
  final double? producePerSec;
  final int? cycleDuration;
  final double? amountPerCycle;
  final int? bufferForResource;

  BuildingTypeOutputModel({
    required this.idBuildingTypeOutput,
    required this.idBuildingType,
    required this.idResource,
    this.produceMode,
    this.producePerSec,
    this.cycleDuration,
    this.amountPerCycle,
    this.bufferForResource,
  });

  factory BuildingTypeOutputModel.fromJson(Map<String, dynamic> json) => BuildingTypeOutputModel(
    idBuildingTypeOutput: json['idBuildingTypeOutput'] ?? json['id'],
    idBuildingType: json['idBuildingType'],
    idResource: json['idResource'],
    produceMode: json['produceMode'],
    producePerSec: json['producePerSec'],
    cycleDuration: json['cycleDuration'],
    amountPerCycle: json['amountPerCycle'],
    bufferForResource: json['bufferForResource'],
  );

  Map<String, dynamic> toJson() => {
    'idBuildingTypeOutput': idBuildingTypeOutput,
    'idBuildingType': idBuildingType,
    'idResource': idResource,
    if (produceMode != null) 'produceMode': produceMode,
    if (producePerSec != null) 'producePerSec': producePerSec,
    if (cycleDuration != null) 'cycleDuration': cycleDuration,
    if (amountPerCycle != null) 'amountPerCycle': amountPerCycle,
    if (bufferForResource != null) 'bufferForResource': bufferForResource,
  };
}
