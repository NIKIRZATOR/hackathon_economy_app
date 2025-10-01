class BuildingTypeOutputModel {
  final int idBuildingTypeOutput;
  final int idBuildingType; // building_type.id_building
  final int idResource; // resource_items.id_item
  final String? produceMode; // per_sec | per_cycle | null
  final double? producePerSec;
  final int? cycleDuration;
  final double? amountPerCycle;
  final int? bufferForResource;

  final Map<String, dynamic>? buildingType;
  final Map<String, dynamic>? resource;

  BuildingTypeOutputModel({
    required this.idBuildingTypeOutput,
    required this.idBuildingType,
    required this.idResource,
    this.produceMode,
    this.producePerSec,
    this.cycleDuration,
    this.amountPerCycle,
    this.bufferForResource,
    this.buildingType,
    this.resource,
  });

  factory BuildingTypeOutputModel.fromJson(Map<String, dynamic> json) {
    final bt = (json['buildingType'] as Map<String, dynamic>?) ?? const {};
    final res = (json['resource'] as Map<String, dynamic>?) ?? const {};

    return BuildingTypeOutputModel(
      idBuildingTypeOutput: json['idBuildingTypeOutput'] ?? json['id'],
      idBuildingType: bt['idBuildingType'] ?? json['idBuildingType'],
      idResource: res['idResource'] ?? json['idResource'] ?? res['idItem'],
      produceMode: json['produceMode'],
      producePerSec: (json['producePerSec'] as num?)?.toDouble(),
      cycleDuration: json['cycleDuration'],
      amountPerCycle: (json['amountPerCycle'] as num?)?.toDouble(),
      bufferForResource: json['bufferForResource'],
      buildingType: bt.isNotEmpty ? _pickBuildingType(bt) : null,
      resource: res.isNotEmpty ? _pickResource(res) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'idBuildingTypeOutput': idBuildingTypeOutput,
    'idBuildingType': idBuildingType,
    'idResource': idResource,
    if (produceMode != null) 'produceMode': produceMode,
    if (producePerSec != null) 'producePerSec': producePerSec,
    if (cycleDuration != null) 'cycleDuration': cycleDuration,
    if (amountPerCycle != null) 'amountPerCycle': amountPerCycle,
    if (bufferForResource != null) 'bufferForResource': bufferForResource,
    if (buildingType != null) 'buildingType': buildingType,
    if (resource != null) 'resource': resource,
  };
}

Map<String, dynamic> _pickBuildingType(Map<String, dynamic> src) => {
  'idBuildingType': src['idBuildingType'],
  'titleBuildingType': src['titleBuildingType'],
  'imagePath': src['imagePath'],
  'wSize': src['wSize'],
  'hSize': src['hSize'],
  'cost': src['cost'],
  'unlockLevel': src['unlockLevel'],
  'maxUpgradeLvl': src['maxUpgradeLvl'],
};

Map<String, dynamic> _pickResource(Map<String, dynamic> src) => {
  'idResource': src['idResource'] ?? src['idItem'],
  'title': src['title'],
  'code': src['code'],
  'imagePath': src['imagePath'],
  'resourceCost': src['resourceCost'],
  'isCurrency': src['isCurrency'],
  'isStorable': src['isStorable'],
};
