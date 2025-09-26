
import '../../../app/services/api_building_type.dart';
import '../model/building_type_model.dart';

class BuildingTypeRepository {
  final _api = ApiBuildingType();

  List<BuildingType>? _allCache;
  final Map<int, BuildingType> _byId = {};

  Future<List<BuildingType>> getAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _allCache != null) return _allCache!;
    final list = await _api.getAll();
    _allCache = list;
    _byId
      ..clear()
      ..addEntries(list.map((b) => MapEntry(b.idBuildingType, b)));
    return list;
  }

  Future<BuildingType> getById(int id) async {
    final c = _byId[id];
    if (c != null) return c;
    final item = await _api.getById(id);
    _byId[id] = item;
    return item;
  }

  void clearCache() {
    _allCache = null;
    _byId.clear();
  }
}
