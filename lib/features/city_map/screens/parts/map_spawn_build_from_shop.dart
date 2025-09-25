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

  void _spawnFromTypeAndEnterMove(BuildingType bt) {
    final int w = bt.wSize.clamp(1, kMapCols);
    final int h = bt.hSize.clamp(1, kMapRows);

    // центр карты
    final int startX = ((kMapCols - w) / 2).floor().clamp(0, kMapCols - w);
    final int startY = ((kMapRows - h) / 2).floor().clamp(0, kMapRows - h);

    final fill = Colors.blue.withValues(alpha: .65);
    final border = Colors.blueGrey;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final b = Building(
      id: id,
      name: bt.titleBuildingType,
      level: 1,
      x: startX,
      y: startY,
      w: w,
      h: h,
      fill: fill,
      border: border,
      imageAsset: bt.imageAsset, // >>> картинка типа
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
        final cell = _lastCellSize!;
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
