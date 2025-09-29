part of '../city_map_screen.dart';

// локальное сохранение прогресса пользователя
final _storage = UserCityStorage();
final _ubRepo = UserBuildingRepository();

extension _CityPersistSaveLoadUpdate on _CityMapScreenState {
  // Загрузка зданий из локала и отрисовка
  Future<void> _loadUserCityFromStorage() async {
    final saved = await _storage.load(_userId);

    doSetState(() {
      buildings.clear(); // очистка -  чтобы не плодить дубликатов зданий

      for (final ub in saved) {
        final bt = _typesById[ub.idBuildingType];
        if (bt == null) {
          // если тип ещё не прогружен — пропускаем
          // при следующем вызове - дорисует
          continue;
        }

        final w = bt.wSize;
        final h = bt.hSize;
        final name = bt.titleBuildingType;
        final imageAsset = bt.imageAsset;

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

        // асинхронно подтянем ui.Image
        _getOrLoadBuildingImage(imageAsset).then((img) {
          if (!mounted || img == null) return;
          doSetState(() {
            b.image = img;
            _paintVersion++;
          });
        }).catchError((_) {});
      }

      _paintVersion++;
    });
  }

  // сохранение новой постройки (после подтверждения размещения) — локально
  Future<void> _persistNewBuilding(Building b, BuildingType bt) async {
    final newId = await _storage.nextLocalId(_userId);
    final ub = UserBuildingModel(
      idUserBuilding: newId,
      idUser: _userId,
      idBuildingType: bt.idBuildingType,
      x: b.x,
      y: b.y,
      currentLevel: b.level,
      state: 'placed',
      placedAt: DateTime.now().toUtc(),
      lastUpgradeAt: null,
      clientId: b.id,
    );
    await _storage.upsert(_userId, ub);

    print(
      "[$_username] купил здание "
          "(idType=${bt.idBuildingType}, title=${bt.titleBuildingType}) "
          "по координатам (x=${b.x}, y=${b.y}), lvl=${b.level}",
    );
  }

  // обновление позиции существующего здания — локально
  Future<void> _persistUpdateBuildingPosition(Building b) async {
    await _storage.updatePositionByClientId(_userId, b.id, b.x, b.y);
    // ignore: avoid_print
    print(
      "[$_username] переместил здание "
          "(clientId=${b.id}, title=${b.name}) "
          "на новые координаты (x=${b.x}, y=${b.y})",
    );
  }

  // синхронизация: запрос с сервера
  // если 404 и пустой
  // сохраняем в localstorage + перерисовываем
  Future<void> _syncUserBuildingsFromServer(int userId) async {
    try {
      // вернёт [] при 404, либо кэш при оффлайне
      final serverList = await _ubRepo.syncFromServerAndCache(userId);

      // нормализация
      final normalized = serverList.map((e) {
        final clientId = e.clientId ?? 'ub_${e.idUserBuilding}';
        return e.copyWith(state: 'placed', clientId: clientId);
      }).toList();

      // кладём нормализованное в кэш + перерисовка
      await _storage.saveAll(userId, normalized);
      await _loadUserCityFromStorage();
    } catch (_) {
    }
  }
}
