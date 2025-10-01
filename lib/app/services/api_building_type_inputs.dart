import 'package:dio/dio.dart';
import 'api_service.dart';
import '../../features/building_types/model/building_type_input.dart';

class ApiBuildingTypeInput {
  final _dio = ApiClient.I.dio;
  static const _base = '/building-type-input';


  Map<String, dynamic> _pickBuildingType(Map<String, dynamic>? src) {
    if (src == null) return {};
    return {
      'idBuildingType': src['idBuildingType'],
      'titleBuildingType': src['titleBuildingType'],
      'imagePath': src['imagePath'],
      //'wSize': src['wSize'],
      //'hSize': src['hSize'],
      //'cost': src['cost'],
      //'unlockLevel': src['unlockLevel'],
      'maxUpgradeLvl': src['maxUpgradeLvl'],
    };
  }

  Map<String, dynamic> _pickResource(Map<String, dynamic>? src) {
    if (src == null) return {};
    return {
      'idResource': src['idResource'] ?? src['idItem'],
      'title': src['title'],
      'code': src['code'],
      'imagePath': src['imagePath'],
      'resourceCost': src['resourceCost'],
      //'isCurrency': src['isCurrency'],
      //'isStorable': src['isStorable'],
    };
  }

  Map<String, dynamic> _flatten(Map<String, dynamic> e) {
    final bt = (e['buildingType'] as Map<String, dynamic>?) ?? const {};
    final res = (e['resource'] as Map<String, dynamic>?) ?? const {};

    return {
      'idBuildingTypeInput': e['idBuildingTypeInput'] ?? e['id'],
      'idBuildingType': bt['idBuildingType'] ?? e['idBuildingType'],
      'idResource': res['idResource'] ?? res['idItem'] ?? e['idResource'],

      'consumeMode': e['consumeMode'],
      'consumePerCycle': e['consumePerCycle'],
      'cycleDuration': e['cycleDuration'],
      'bufferForResource': e['bufferForResource'],
      'consumePerSec': e['consumePerSec'],
      'amountPerSec': e['amountPerSec'],

      // срезы:
      'buildingType': _pickBuildingType(bt),
      'resource': _pickResource(res),
    };
  }


  Future<List<BuildingTypeInputModel>> getAll() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
  }

  Future<List<BuildingTypeInputModel>> getByBuilding(int idBuilding) async {
    try {
      final r = await _dio.get('$_base/by-building/$idBuilding');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeInputModel>[];
      rethrow;
    }
  }

  Future<List<BuildingTypeInputModel>> getByResource(int idResource) async {
    try {
      final r = await _dio.get('$_base/by-resource/$idResource');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map((e) => BuildingTypeInputModel.fromJson(_flatten(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return <BuildingTypeInputModel>[];
      rethrow;
    }
  }
}
