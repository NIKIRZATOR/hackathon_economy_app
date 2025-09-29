part of '../city_map_screen.dart';

// при покупке из магазина —  id и тип
String? _pendingNewBuildingId;
BuildingType? _pendingNewBuildingType;

// последний рассчитанный размер клетки (px)
double? _lastCellSize;

// drag-предпросмотр
DragPreview? _preview;

// перерисовка
int _paintVersion = 0;

// режим переноса
bool _moveMode = false;
String? _moveRequestedId;

Building? _dragging;
late int _dragOffsetInCellsX;
late int _dragOffsetInCellsY;
late int _origX, _origY;

extension _CitySpawnBuildFromShop on _CityMapScreenState {

  // покупаем здание (локально списываются coins, создается запись в UserCityStorage),
  Future<void> _spawnFromTypeAndEnterMove(BuildingType bt) async {
    final uid = _user?.userId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала войдите в игру')),
      );
      return;
    }

    // 1 локальная покупка
    final res = await _purchase.buyBuildingLocal(
      userId: uid,
      buildingTypeId: bt.idBuildingType,
      costCoins: bt.cost.toDouble(),
    );

    if (!res.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error ?? 'Ошибка покупки')),
      );
      return;
    }

    // 2 обновление монет в профиле
    doSetState(() {
      _coins = (res.newCoins ?? _coins).round();
    });

    // 3 подготовка объекта к режиму переноса
    final ub = res.building!; // запись из локального стораджа
    final int w = bt.wSize.clamp(1, kMapCols);
    final int h = bt.hSize.clamp(1, kMapRows);

    // центр карты
    final int startX = ((kMapCols - w) / 2).floor().clamp(0, kMapCols - w);
    final int startY = ((kMapRows - h) / 2).floor().clamp(0, kMapRows - h);

    final fill = Colors.blue.withValues(alpha: .65);
    final border = Colors.blueGrey;

    final id = ub.clientId ?? 'ub_${ub.idUserBuilding}';
    final b = Building(
      id: id,
      name: bt.titleBuildingType,
      level: ub.currentLevel,
      x: startX,
      y: startY,
      w: w,
      h: h,
      fill: fill,
      border: border,
      imageAsset: bt.imageAsset,
      idUserBuilding: ub.idUserBuilding,
      idBuildingType: ub.idBuildingType,
    );

    doSetState(() {
      buildings.add(b);
      _paintVersion++;

      _moveMode = true;
      _moveRequestedId = id;

      // помечаем как «новая покупка»
      _pendingNewBuildingId = id;
      _pendingNewBuildingType = bt;

      if (_lastCellSize != null) {
        _dragging = null; // пусть panStart отработает
        _preview = DragPreview(
          Rect.fromLTWH(
            b.x.toDouble(),
            b.y.toDouble(),
            b.w.toDouble(),
            b.h.toDouble(),
          ),
          canPlaceAt(
            terrain: terrain,
            buildings: buildings,
            x: b.x,
            y: b.y,
            w: b.w,
            h: b.h,
            cols: kMapCols,
            rows: kMapRows,
            exceptId: b.id,
          ),
        );
      }
    });

    // загрузим текстуру картинки здания и перерисуем
    _getOrLoadBuildingImage(bt.imageAsset).then((img) {
      if (img != null && mounted) {
        doSetState(() {
          b.image = img;
          _paintVersion++;
        });
      }
    });
  }
}
