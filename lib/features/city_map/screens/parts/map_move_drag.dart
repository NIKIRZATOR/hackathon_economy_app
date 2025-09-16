part of '../city_map_screen.dart';

extension _CityMapStateMoveDrag on _CityMapScreenState {
  /// Начало перетаскивания (жест на child внутри InteractiveViewer → локальные = scene)
  void _onMovePanStart(DragStartDetails d, double cellSize) {
    if (!_moveMode || _moveRequestedId == null || _dragging != null) return;

    final scene = d.localPosition;
    final int x = (scene.dx / cellSize).floor();
    final int y = (scene.dy / cellSize).floor();

    final b = buildings.firstWhere((e) => e.id == _moveRequestedId);
    if (!(x >= b.x && x < b.x + b.w && y >= b.y && y < b.y + b.h)) return;

    _dragOffsetInCellsX = x - b.x;
    _dragOffsetInCellsY = y - b.y;
    _origX = b.x;
    _origY = b.y;

    doSetState(() {
      _dragging = b;
      _updatePreviewForScene(scene, cellSize);
    });
  }

  /// Обновление перетаскивания
  void _onMovePanUpdate(DragUpdateDetails d, double cellSize) {
    if (_dragging == null) return;
    final scene = d.localPosition;
    doSetState(() => _updatePreviewForScene(scene, cellSize));
  }

  /// Завершение перетаскивания
  void _onMovePanEnd(DragEndDetails d, double cellSize) {
    if (_dragging == null) return;
    final b = _dragging!;
    final prev = _preview;

    doSetState(() {
      if (prev != null && prev.isValid) {
        b.x = prev.rect.left.toInt();
        b.y = prev.rect.top.toInt();
        _paintVersion++;
      } else {
        b.x = _origX;
        b.y = _origY;
        if (prev != null) _toast('Нельзя поставить сюда.');
      }
      _dragging = null;
      _preview = null;
      // режим переноса остаётся до нажатия на ✅
    });
  }

  /// Пересчёт «призрачного» прямоугольника превью и валидации
  void _updatePreviewForScene(Offset scene, double cellSize) {
    final b = _dragging!;
    final int cellX = (scene.dx / cellSize).floor() - _dragOffsetInCellsX;
    final int cellY = (scene.dy / cellSize).floor() - _dragOffsetInCellsY;

    final valid = canPlaceAt(
      terrain: terrain,
      buildings: buildings,
      x: cellX, y: cellY, w: b.w, h: b.h,
      cols: kMapCols, rows: kMapRows,
      exceptId: b.id,
    );

    _preview = DragPreview(
      Rect.fromLTWH(cellX.toDouble(), cellY.toDouble(), b.w.toDouble(), b.h.toDouble()),
      valid,
    );
  }
}
