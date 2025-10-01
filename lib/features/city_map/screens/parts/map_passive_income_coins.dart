part of '../city_map_screen.dart';

// конфиг пассивного дохода
const _incomeTickSeconds = 3;
const _coinsResourceId = 1; // ID ресурса coins
const _coinsCode = 'coins'; // код ресурса coins в инвентаре

Timer? _incomeTimer;

final _cityStorage = UserCityStorage();
final _outputStorage = BuildingTypeOutputStorage();
final _inventoryStorage = UserInventoryStorage();

final _coinsDeltaStream = StreamController<double>.broadcast();

extension _PassiveIncome on _CityMapScreenState {
  // cтарт-тикер, если есть userId
  void _startPassiveIncomeTicker() {
    final uid = _user?.userId;
    if (uid == null) return;
    _incomeTimer?.cancel(); // защита от дублей
    _incomeTimer = Timer.periodic(
      const Duration(seconds: _incomeTickSeconds),
      (_) => _onIncomeTick(uid),
    );

  }

  // стоп-тикер
  void _stopPassiveIncomeTicker() {
    _incomeTimer?.cancel();
    _incomeTimer = null;
  }

  // разовый пересчёт и начисление за тик
  Future<void> _onIncomeTick(int userId) async {
    try {
      final delta = await _calcCoinsDeltaForTick(userId, _incomeTickSeconds);

      if (delta > 0) {
        _coinsDeltaStream.add(delta);
      }




      // начисляем монеты в локальный инвентарь
      await _inventoryStorage.addByCode(
        userId: userId,
        code: _coinsCode,
        delta: delta,
      );

      // обновляем топбар
      final coinsNow = await _inventoryStorage.getAmountByCodeSafe(
        userId,
        _coinsCode,
      );
      if (!mounted) return;
      doSetState(() => _coins = coinsNow.toInt());
    } catch (_) {}
  }

  /// Считает, сколько монет должно упасть за один тик, в *монетах*
  ///
  /// Алгоритм расчета суммы монет за 1 ти
  /// к
  /// - produceMode == 'per_sec'  -> берём producePerSec (монет/сек)
  /// - produceMode == 'per_cycle' -> amountPerCycle / cycleDuration (монет/сек)
  /// Если поля заданы «смешанно» - приоритет у per_sec; если его нет — считаем по per_cycle.
  Future<double> _calcCoinsDeltaForTick(int userId, int tickSeconds) async {
    // здания пользователя
    final userBuildings = await _cityStorage.load(userId);
    if (userBuildings.isEmpty) return 0;

    // каталог выходов (outputs)
    final outputs = await _outputStorage.load();
    if (outputs.isEmpty) return 0;

    // типы размещённых зданий
    final placedTypeIds = userBuildings
        .where((ub) => ub.state == 'placed' || ub.state == 'active')
        .map((ub) => ub.idBuildingType)
        .toSet();
    if (placedTypeIds.isEmpty) return 0;

    // берём только монеты и только те, что per_sec > 0
    final coinsOutputsPerSec = outputs.where(
          (o) =>
      o.idResource == _coinsResourceId &&
          placedTypeIds.contains(o.idBuildingType) &&
          ((o.producePerSec ?? 0) > 0), // только per_sec
    );
    if (coinsOutputsPerSec.isEmpty) return 0;

    double totalPerSec = 0.0;

    for (final o in coinsOutputsPerSec) {
      final buildingsCountOfThisType = userBuildings
          .where((ub) =>
      ub.idBuildingType == o.idBuildingType &&
          (ub.state == 'placed' || ub.state == 'active'))
          .length;
      if (buildingsCountOfThisType == 0) continue;

      final perSec = o.producePerSec ?? 0;
      if (perSec <= 0) continue;

      totalPerSec += perSec * buildingsCountOfThisType;
    }

    return totalPerSec * tickSeconds; // монеты за тик
  }

  // проверка: есть ли у игрока здания, которые дают монеты
  Future<bool> _hasCoinProducers(int userId) async {
    final userBuildings = await _cityStorage.load(userId);
    if (userBuildings.isEmpty) return false;

    final outputs = await _outputStorage.load();
    if (outputs.isEmpty) return false;

    final placedTypeIds = userBuildings
        .where((ub) => ub.state == 'placed' || ub.state == 'active')
        .map((ub) => ub.idBuildingType)
        .toSet();

    // есть ли среди размещённых типов такой, у кого producePerSec > 0 для монет
    return outputs.any((o) =>
    o.idResource == _coinsResourceId &&
        placedTypeIds.contains(o.idBuildingType) &&
        ((o.producePerSec ?? 0) > 0));
  }

  // перезапуск тикера: если зданий-build_type_out нет, останавливаем
  Future<void> _rearmPassiveIncomeTicker() async {
    final uid = _user?.userId;
    if (uid == null) return;
    final hasCoinsProducers = await _hasCoinProducers(uid);
    if (hasCoinsProducers) {
      _startPassiveIncomeTicker();
    } else {
      _stopPassiveIncomeTicker();
    }
  }

}
