part of '../city_map_screen.dart';

extension _CityMapStateWidgets on _CityMapScreenState {
  /// Верхняя панель: создание здания, сброс зума, слайдер размера клетки
  Widget buildTopToolbar(double cellSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16, runSpacing: 8,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.domain_add),
            label: const Text('Создать здание'),
            onPressed: _createRandomBuilding,
          ),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.center_focus_strong),
            label: const Text('Сбросить зум'),
            onPressed: () => doSetState(() {
              cellScale = 1.0;
              _tc.value = Matrix4.identity();
            }),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Размер клетки'),
              SizedBox(
                width: 220,
                child: Slider(
                  min: 0.5, max: 2.5, divisions: 20,
                  value: cellScale,
                  onChanged: (v) => doSetState(() => cellScale = v),
                ),
              ),
              Text('${cellSize.toStringAsFixed(1)} px'),
            ],
          ),
        ],
      ),
    );
  }

  /// Центральная область: отрисовка карты, панорамирование/перенос, overlay с ✅
  Widget buildMapCanvas(double cellSize) {
    final screen = MediaQuery.of(context).size;
    final mapHeightTarget = screen.height * 0.8;
    final baseCell = min(
      screen.width / _CityMapScreenState.cols,
      mapHeightTarget / _CityMapScreenState.rows,
    );
    final realCell = baseCell * cellScale;

    final mapWidthPx  = _CityMapScreenState.cols * realCell;
    final mapHeightPx = _CityMapScreenState.rows * realCell;

    return Center(
      child: SizedBox(
        height: mapHeightTarget,
        width: double.infinity,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.black12),
              ),
              child: LayoutBuilder(
                builder: (context, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // область панорамирования/зумирования
                      Listener(
                        onPointerSignal: (ps) {},
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (d) => _onTapAt(d.localPosition, realCell),
                          child: Center(
                            child: InteractiveViewer(
                              transformationController: _tc,
                              panEnabled: !_moveMode,
                              scaleEnabled: false,
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
                          onConfirm: () {
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
