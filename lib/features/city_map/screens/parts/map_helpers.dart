part of '../city_map_screen.dart';

extension _CityMapStateHelpers on _CityMapScreenState {
  // перевод точки viewport -> scene
  Offset _toScene(Offset viewportPoint) => _tc.toScene(viewportPoint);

  // перевод точки scene -> viewport (обратно)
  Offset _sceneToViewport(Offset scenePoint) {
    final m = _tc.value;
    final v = v_math.Vector3(scenePoint.dx, scenePoint.dy, 0);
    final r = m.transform3(v);
    return Offset(r.x, r.y);
  }

  /// позиция кнопки подтверждения (галочка)
  Offset? _confirmBtnViewportPos(double cellSize) {
    if (!_moveMode || _moveRequestedId == null) return null;
    final b = buildings.firstWhere(
          (e) => e.id == _moveRequestedId,
      orElse: () => Building(
        id: '', name: '', level: 0, x: -9999, y: -9999, w: 1, h: 1,
        fill: Colors.transparent, border: Colors.transparent,
      ),
    );
    if (b.id.isEmpty) return null;

    final scenePt = Offset((b.x + b.w) * cellSize, b.y * cellSize);
    final vp = _sceneToViewport(scenePt);
    return vp + const Offset(8, -8);
  }

  void _spawnFromTypeAndEnterMove(BuildingType bt) {
    // размеры из типа
    final int w = bt.wSize.clamp(1, kMapCols);
    final int h = bt.hSize.clamp(1, kMapRows);

    // центр карты (в ячейках)
    final int startX = ((kMapCols - w) / 2).floor().clamp(0, kMapCols - w);
    final int startY = ((kMapRows - h) / 2).floor().clamp(0, kMapRows - h);

    // произвольные цвета  TODO палитру
    final fill = Colors.blue.withValues(alpha: .65);
    final border = Colors.blueGrey;

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final b = Building(
      id: id,
      name: bt.titleBuildingType,
      level: 1,
      x: startX, y: startY, w: w, h: h,
      fill: fill,
      border: border,
    );

    doSetState(() {
      buildings.add(b);
      _paintVersion++;

      // включаем режим переноса для только что созданного

      _moveMode = true;
      _moveRequestedId = id;

      // не выставляем _dragging — игрок сразу тянет и перенос сработает

      if (_lastCellSize != null) {
        final cell = _lastCellSize!;
        final sceneTopLeft = Offset(b.x * cell, b.y * cell);
        _dragging = null; // пусть panStart отработает, иначе баг
        _preview = DragPreview(
          Rect.fromLTWH(b.x.toDouble(), b.y.toDouble(), b.w.toDouble(), b.h.toDouble()),
          canPlaceAt(
            terrain: terrain,
            buildings: buildings,
            x: b.x, y: b.y, w: b.w, h: b.h,
            cols: kMapCols, rows: kMapRows,
            exceptId: b.id,
          ),
        );
      }
    });
  }
}
