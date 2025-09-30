part of '../city_map_screen.dart';

extension _CityMapWidget on _CityMapScreenState {
  double _currentScale() => _tc.value.getMaxScaleOnAxis();

  Widget buildMapCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        final baseCell =
        min(maxW / _CityMapScreenState.cols, maxH / _CityMapScreenState.rows);

        final realCell = (baseCell * cellSizeMultiplier).clamp(6.0, 64.0);
        _lastCellSize = realCell;

        final mapWidthPx = _CityMapScreenState.cols * realCell;
        final mapHeightPx = _CityMapScreenState.rows * realCell;

        Building? active;
        if (_moveMode && _moveRequestedId != null) {
          active = buildings.cast<Building?>().firstWhere(
                (e) => e!.id == _moveRequestedId,
            orElse: () => null,
          );
        }

        final scale = _currentScale();
        final invScale = scale == 0 ? 1.0 : (1.0 / scale);

        const pxShift = Offset(8, -8);

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
                  Listener(
                    onPointerSignal: (ps) {},
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
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
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (d) =>
                                  _onTapInScene(d.localPosition, realCell),
                              onPanStart:
                              _moveMode ? (d) => _onMovePanStart(d, realCell) : null,
                              onPanUpdate:
                              _moveMode ? (d) => _onMovePanUpdate(d, realCell) : null,
                              onPanEnd:
                              _moveMode ? (d) => _onMovePanEnd(d, realCell) : null,
                              child: Stack(
                                children: [
                                  CustomPaint(
                                    painter: MapPainter(
                                      terrain: terrain,
                                      buildings: buildings,
                                      cellSize: realCell,
                                      borderThickness: 4.0,
                                      dragPreview: _preview,
                                      version: _paintVersion,
                                      roadTexture: _roadTex,
                                      grassTexture: _grassTex,
                                      showGrid: _moveMode,
                                    ),
                                  ),
                                  if (_moveMode && active != null)
                                    Positioned(
                                      left: (active.x + active.w) * realCell + pxShift.dx,
                                      top:  (active.y) * realCell + pxShift.dy,
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.diagonal3Values(
                                            invScale, invScale, 1),
                                        child: _ConfirmBtn(
                                          onTap: () async {
                                            final b = active!;
                                            if (_pendingNewBuildingId == b.id &&
                                                _pendingNewBuildingType != null) {
                                              await _persistNewBuilding(
                                                  b, _pendingNewBuildingType!);
                                              _pendingNewBuildingId = null;
                                              _pendingNewBuildingType = null;
                                            } else {
                                              await _persistUpdateBuildingPosition(b);
                                            }
                                            AudioManager().playSfx('build.mp3');
                                            doSetState(() {
                                              _moveMode = false;
                                              _moveRequestedId = null;
                                              _dragging = null;
                                              _preview = null;
                                            });
                                            // сообщаем туториалу: здание установлено
                                            _tutorialKey.currentState?.completeCurrentAction();
                                            _toast('Перенос завершён.');
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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
