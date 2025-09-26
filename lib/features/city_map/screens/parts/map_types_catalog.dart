part of '../city_map_screen.dart';

extension _CityTypeCatalog on _CityMapScreenState {
  Future<void> _loadTypesThenUserCity() async {
    // 1) Каталог типов
    final btRepo = BuildingTypeRepository();
    final types = await btRepo.getAll();

    _typesById.clear();
    for (final t in types) {
      _typesById[t.idBuildingType] = t;

      // Прогрев кэша изображений (не блокируем)
      if (t.imageAsset != null) {
        _getOrLoadBuildingImage(t.imageAsset);
      }
    }

    // 2) Гарантируем, что знаем пользователя (если _initUser еще не успел)
    _user ??= await _authRepo.getSavedUser();
    final uid = _user?.userId ?? 0;

    // 3) Если есть userId — тянем постройки с бэка и кладем в локал
    if (uid > 0) {
      await _syncUserBuildingsFromServer(uid);
    }

    // 4) Рисуем из локала
    await _loadUserCityFromStorage();
  }
}
