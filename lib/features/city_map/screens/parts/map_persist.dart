part of '../city_map_screen.dart';

// локальное сохранение прогресса пользователя
final _storage = UserCityStorage();

extension _CityPersistSaveLoadUpdate on _CityMapScreenState {

// загрузка сохранённых построек
  Future<void> _loadUserCityFromStorage() async {
    final saved = await _storage.load(_userId);
    doSetState(() {
      for (final ub in saved.where((e) => e.state == 'active')) {
        final bt = _typesById[ub.idBuildingType];
        final w = bt?.wSize ?? 2;
        final h = bt?.hSize ?? 2;
        final name = bt?.titleBuildingType ?? 'Здание #${ub.idUserBuilding}';
        final imageAsset = bt?.imageAsset;

        final b = Building(
          id: ub.clientId ?? 'ub_${ub.idUserBuilding}',
          name: name,
          level: ub.currentLevel,
          x: ub.x,
          y: ub.y,
          w: w,
          h: h,
          fill: Colors.blue.withValues(alpha: .65),
          border: Colors.blueGrey,
          imageAsset: imageAsset,
        );
        buildings.add(b);

        // асинхронно подтянем ui.Image и перерисуем
        _getOrLoadBuildingImage(imageAsset).then((img) {
          if (img != null && mounted) {
            doSetState(() {
              b.image = img;
              _paintVersion++;
            });
          }
        });
      }
      _paintVersion++;
    });
  }

// сохранение новой постройки (после первого подтверждения размещения)
  Future<void> _persistNewBuilding(Building b, BuildingType bt) async {
    final newId = await _storage.nextLocalId(_userId);
    final ub = UserBuilding(
      idUserBuilding: newId,
      idUser: _userId,
      idBuildingType: bt.idBuildingType,
      x: b.x,
      y: b.y,
      currentLevel: b.level,
      state: 'active',
      placedAt: DateTime.now().toUtc(),
      lastUpgradeAt: null,
      clientId: b.id,
    );
    await _storage.upsert(_userId, ub);
    // лог
    // ignore: avoid_print
    print(
      "[$_username] купил здание "
          "(idType=${bt.idBuildingType}, title=${bt.titleBuildingType}) "
          "по координатам (x=${b.x}, y=${b.y}), lvl=${b.level}",
    );
  }

// обновление позиции существующего здания
  Future<void> _persistUpdateBuildingPosition(Building b) async {
    await _storage.updatePositionByClientId(_userId, b.id, b.x, b.y);
    // ignore: avoid_print
    print(
      "[$_username] переместил здание "
          "(clientId=${b.id}, title=${b.name}) "
          "на новые координаты (x=${b.x}, y=${b.y})",
    );
  }
}