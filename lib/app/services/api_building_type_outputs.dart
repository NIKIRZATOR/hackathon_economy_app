import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../features/building_types/model/building_type_output.dart';

class ApiBuildingTypeOutput {
  final _dio = ApiClient.I.dio;
  static const _base = '/building-type-output';

  Map<String, dynamic> _flatten(Map<String, dynamic> e) {
    final bt = (e['buildingType'] as Map<String, dynamic>?) ?? const {};
    final res = (e['resource'] as Map<String, dynamic>?) ?? const {};

    return {
      'idBuildingTypeOutput': e['idBuildingTypeOutput'] ?? e['id'],
      'idBuildingType': bt['idBuildingType'] ?? e['idBuildingType'],
      'idResource': res['idResource'] ?? res['idItem'] ?? e['idResource'],
      'produceMode': e['produceMode'],
      'producePerSec': e['producePerSec'],
      'cycleDuration': e['cycleDuration'],
      'amountPerCycle': e['amountPerCycle'],
      'bufferForResource': e['bufferForResource'],
      'buildingType': _pickBuildingType(bt),
      'resource': _pickResource(res),
    };
  }

  Future<List<BuildingTypeOutputModel>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => BuildingTypeOutputModel.fromJson(_flatten(e))).toList();
  }

  Future<List<BuildingTypeOutputModel>> getByBuilding(int idBuilding) async {
    try {
      final r = await _dio.get('$_base/by-building/$idBuilding');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeOutputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeOutputModel>[];
      rethrow;
    }
  }

  Future<List<BuildingTypeOutputModel>> getByResource(int idResource) async {
    try {
      final r = await _dio.get('$_base/by-resource/$idResource');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeOutputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeOutputModel>[];
      rethrow;
    }
  }
}

Map<String, dynamic> _pickBuildingType(Map<String, dynamic> src) => {
  'idBuildingType': src['idBuildingType'],
  'titleBuildingType': src['titleBuildingType'],
  'imagePath': src['imagePath'],
  //'wSize': src['wSize'],
  //'hSize': src['hSize'],
  //'cost': src['cost'],
  //'unlockLevel': src['unlockLevel'],
  'maxUpgradeLvl': src['maxUpgradeLvl'],
};

Map<String, dynamic> _pickResource(Map<String, dynamic> src) => {
  'idResource': src['idResource'] ?? src['idItem'],
  'title': src['title'],
  'code': src['code'],
  'imagePath': src['imagePath'],
  'resourceCost': src['resourceCost'],
  //'isCurrency': src['isCurrency'],
  //'isStorable': src['isStorable'],
};