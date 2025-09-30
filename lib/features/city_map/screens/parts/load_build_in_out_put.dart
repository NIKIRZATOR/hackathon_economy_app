part of '../city_map_screen.dart';

final _btInRepo = BuildingTypeInputRepository();
final _btOutRepo = BuildingTypeOutputRepository();

// сгруппировано по idBuildingType
final Map<int, List<BuildingTypeInputModel>> _inputsByType = {};
final Map<int, List<BuildingTypeOutputModel>> _outputsByType = {};

// будущее применение входов\выходов (заменить на id)
// final inputs = _inputsByType[idBuildingType] ?? const [];
// final outputs = _outputsByType[idBuildingType] ?? const [];

extension _LoadBuildInOutPut on _CityMapScreenState {

  Future<void> _loadIOFromCache() async {
    final inputs = await _btInRepo.loadFromCache();
    final outputs = await _btOutRepo.loadFromCache();

    _inputsByType
      ..clear()
      ..addAll(_groupInputs(inputs));

    _outputsByType
      ..clear()
      ..addAll(_groupOutputs(outputs));
  }

  Map<int, List<BuildingTypeInputModel>> _groupInputs(List<BuildingTypeInputModel> items) {
    final map = <int, List<BuildingTypeInputModel>>{};
    for (final it in items) {
      (map[it.idBuildingType] ??= []).add(it);
    }
    return map;
  }

  Map<int, List<BuildingTypeOutputModel>> _groupOutputs(List<BuildingTypeOutputModel> items) {
    final map = <int, List<BuildingTypeOutputModel>>{};
    for (final it in items) {
      (map[it.idBuildingType] ??= []).add(it);
    }
    return map;
  }
}
