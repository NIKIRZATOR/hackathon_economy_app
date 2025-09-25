part of '../city_map_screen.dart';

extension _CityTypeCatalog on _CityMapScreenState {

  Future<void> _loadTypesThenUserCity() async {
    final repo = MockBuildingTypeRepository();
    final types = await repo.loadAll();
    _typesById.clear();
    for (final t in types) {
      _typesById[t.idBuildingType] = t;

      // по желанию — прогреть кэш картинок заранее:
      if (t.imageAsset != null) {
        // не ждём, просто подгружаем
        _getOrLoadBuildingImage(t.imageAsset);
      }
    }
    await _loadUserCityFromStorage();
  }
}