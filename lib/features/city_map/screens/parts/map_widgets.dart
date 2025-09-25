part of '../city_map_screen.dart';

extension _CityMapWidget on _CityMapScreenState {

  /// центральная область: отрисовка карты, панорамирование/перенос, overlay
  Widget buildMapCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        // максимально возможная квадратная сетка внутри доступной области
        final baseCell = min(maxW / _CityMapScreenState.cols, maxH / _CityMapScreenState.rows);

        // настраиваемый множитель, ссылка на 51 строку
        final realCell = (baseCell * cellSizeMultiplier).clamp(6.0, 64.0);

        _lastCellSize = realCell;

        final mapWidthPx  = _CityMapScreenState.cols * realCell;
        final mapHeightPx = _CityMapScreenState.rows * realCell;

        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // область панорамирования (масштаб выключен)
                  Listener(
                    onPointerSignal: (ps) {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _onTapAt(d.localPosition, realCell),
                      child: Center(
                        child: InteractiveViewer(
                          transformationController: _tc,
                          panEnabled: !_moveMode,
                          scaleEnabled: true,
                          minScale: 0.4,
                          maxScale: 1.5,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(2000),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: mapWidthPx,
                            height: mapHeightPx,
                            child: GestureDetector(
                              onPanStart: _moveMode ? (d) => _onMovePanStart(d, realCell) : null,
                              onPanUpdate: _moveMode ? (d) => _onMovePanUpdate(d, realCell) : null,
                              onPanEnd: _moveMode ? (d) => _onMovePanEnd(d, realCell) : null,
                              child: CustomPaint(
                                painter: MapPainter(
                                  terrain: terrain,
                                  buildings: buildings,
                                  cellSize: realCell,
                                  borderThickness: 4.0,
                                  dragPreview: _preview,
                                  version: _paintVersion,
                                  roadTexture: _roadTex,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // плавающая кнопка подтверждения переноса
                  if (_moveMode && _moveRequestedId != null)
                    ConfirmButtonOverlay(
                      viewportPos: _confirmBtnViewportPos(realCell),
                      onConfirm: () async {
                        // найдём активное здание
                        final b = buildings.firstWhere((e) => e.id == _moveRequestedId);

                        // если это новое (только что купленное) — сохраняем как новую запись
                        if (_pendingNewBuildingId == b.id && _pendingNewBuildingType != null) {
                          await _persistNewBuilding(b, _pendingNewBuildingType!);
                          _pendingNewBuildingId = null;
                          _pendingNewBuildingType = null;
                        } else {
                          // иначе — это перенос существующего: обновим координаты
                          await _persistUpdateBuildingPosition(b);
                        }
                        
                        AudioManager().playSfx('build.mp3');
                        
                        doSetState(() {
                          _moveMode = false;
                          _moveRequestedId = null;
                          _dragging = null;
                          _preview = null;
                        });
                        _toast('Перенос завершён.');
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

