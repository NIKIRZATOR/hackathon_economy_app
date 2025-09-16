import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import '../models/building.dart';
import '../models/drag_preview.dart';
import '../painters/map_painter.dart';
import '../services/placement_rules.dart';
import '../services/static_city_layout.dart';
import '../widgets/confirm_button_overlay.dart';

class CityMapScreen extends StatefulWidget {
  const CityMapScreen({super.key});
  @override
  State<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends State<CityMapScreen> {
  static const int rows = 32;
  static const int cols = 32;

  late List<List<int>> terrain;
  final List<Building> buildings = [];
  final Random rng = Random(42);

  double cellScale = 1.0;
  final TransformationController _tc = TransformationController();

  bool _moveMode = false;
  String? _moveRequestedId;

  Building? _dragging;
  late int _dragOffsetInCellsX;
  late int _dragOffsetInCellsY;
  late int _origX, _origY;
  DragPreview? _preview;

  int _paintVersion = 0;

  @override
  void initState() {
    super.initState();
    terrain = buildStaticCityGrid();            // <— статичный 32×32 с 0/1/2/3
    buildings.addAll(initialBuildingsFromPlacements()); // <— словарь→размещения
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ======= helpers: coords
  Offset _toScene(Offset viewportPoint) => _tc.toScene(viewportPoint);

  Offset _sceneToViewport(Offset scenePoint) {
    final m = _tc.value;
    final v = vmath.Vector3(scenePoint.dx, scenePoint.dy, 0);
    final r = m.transform3(v);
    return Offset(r.x, r.y);
  }

  // ======= building ops
  void _createRandomBuilding() {
    final w = rng.nextInt(4) + 1;
    final h = rng.nextInt(4) + 1;
    final fill = HSVColor.fromAHSV(1, rng.nextDouble() * 360, 0.5 + rng.nextDouble() * 0.5, 0.7).toColor();
    final border = HSVColor.fromAHSV(1, rng.nextDouble() * 360, 0.7, 0.4).toColor();

    const maxTries = 500;
    for (int attempt = 0; attempt < maxTries; attempt++) {
      final x = rng.nextInt(cols - w);
      final y = rng.nextInt(rows - h);
      final ok = canPlaceAt(
        terrain: terrain,
        buildings: buildings,
        x: x, y: y, w: w, h: h,
        cols: cols, rows: rows,
      );
      if (ok) {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        final b = Building(
          id: id,
          name: 'Здание ${buildings.length + 1}',
          level: rng.nextInt(3) + 1,
          x: x, y: y, w: w, h: h,
          fill: fill, border: border,
        );
        setState(() {
          buildings.add(b);
          _paintVersion++;
        });
        return;
      }
    }
    _toast('Нет места для нового здания.');
  }

  Building? _buildingAtCell(int cellX, int cellY) {
    for (final b in buildings) {
      if (cellX >= b.x && cellX < b.x + b.w && cellY >= b.y && cellY < b.y + b.h) {
        return b;
      }
    }
    return null;
  }

  // ======= taps (dialog)
  void _onTapAt(Offset viewportPos, double cellSize) {
    if (_moveMode) return;
    final scene = _toScene(viewportPos);
    final int x = (scene.dx / cellSize).floor();
    final int y = (scene.dy / cellSize).floor();
    if (x < 0 || y < 0 || x >= cols || y >= rows) return;

    final tapped = _buildingAtCell(x, y);
    if (tapped != null) _openBuildingDialog(tapped);
  }

  void _openBuildingDialog(Building b) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(b.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Уровень', b.level.toString()),
              _infoRow('Размер', '${b.w} × ${b.h}'),
              _infoRow('Позиция', 'x:${b.x}, y:${b.y}'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(width: 20, height: 20, color: b.fill),
                  const SizedBox(width: 8),
                  Container(width: 20, height: 20, decoration: BoxDecoration(border: Border.all(color: b.border))),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final origW = b.w, origH = b.h;
                b.rotateTranspose();
                final ok = canPlaceAt(
                  terrain: terrain,
                  buildings: buildings,
                  x: b.x, y: b.y, w: b.w, h: b.h,
                  cols: cols, rows: rows,
                  exceptId: b.id,
                );
                if (ok) {
                  setState(() => _paintVersion++);
                } else {
                  b.w = origW; b.h = origH;
                  _toast('После поворота не помещается.');
                }
              },
              child: const Text('Повернуть'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _moveMode = true;
                  _moveRequestedId = b.id;
                });
                _toast('Режим переноса: перетащите здание и нажмите ✅ чтобы завершить.');
              },
              child: const Text('Переместить'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  buildings.removeWhere((e) => e.id == b.id);
                  _paintVersion++;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Убрать', style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Закрыть')),
          ],
        );
      },
    );
  }

  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(v)),
      ],
    ),
  );

  // ======= drag in move-mode (gestures are on child inside InteractiveViewer -> scene coords)
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

    setState(() {
      _dragging = b;
      _updatePreviewForScene(scene, cellSize);
    });
  }

  void _onMovePanUpdate(DragUpdateDetails d, double cellSize) {
    if (_dragging == null) return;
    final scene = d.localPosition;
    setState(() => _updatePreviewForScene(scene, cellSize));
  }

  void _onMovePanEnd(DragEndDetails d, double cellSize) {
    if (_dragging == null) return;
    final b = _dragging!;
    final prev = _preview;

    setState(() {
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

  void _updatePreviewForScene(Offset scene, double cellSize) {
    final b = _dragging!;
    final int cellX = (scene.dx / cellSize).floor() - _dragOffsetInCellsX;
    final int cellY = (scene.dy / cellSize).floor() - _dragOffsetInCellsY;

    final valid = canPlaceAt(
      terrain: terrain,
      buildings: buildings,
      x: cellX, y: cellY, w: b.w, h: b.h,
      cols: cols, rows: rows,
      exceptId: b.id,
    );

    _preview = DragPreview(Rect.fromLTWH(cellX.toDouble(), cellY.toDouble(), b.w.toDouble(), b.h.toDouble()), valid);
  }

  // позиция ✅ относительно правого-верхнего угла здания
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

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final mapHeightTarget = screen.height * 0.8;
    final baseCell = min(screen.width / cols, mapHeightTarget / rows);
    final cellSize = baseCell * cellScale;

    final mapWidthPx = cols * cellSize;
    final mapHeightPx = rows * cellSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Единая карта 32×32 — drag & pan'),
        actions: [
          if (_moveMode)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text('Режим переноса', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // панель
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.domain_add),
                  label: const Text('Создать здание'),
                  onPressed: _createRandomBuilding,
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Сбросить зум'),
                  onPressed: () => setState(() {
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
                        min: 0.5,
                        max: 2.5,
                        divisions: 20,
                        value: cellScale,
                        onChanged: (v) => setState(() => cellScale = v),
                      ),
                    ),
                    Text('${(cellSize).toStringAsFixed(1)} px'),
                  ],
                ),
              ],
            ),
          ),

          // карта
          Expanded(
            child: Center(
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
                              Listener(
                                onPointerSignal: (ps) {},
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (d) => _onTapAt(d.localPosition, cellSize),
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
                                          onPanStart: _moveMode ? (d) => _onMovePanStart(d, cellSize) : null,
                                          onPanUpdate: _moveMode ? (d) => _onMovePanUpdate(d, cellSize) : null,
                                          onPanEnd: _moveMode ? (d) => _onMovePanEnd(d, cellSize) : null,
                                          child: CustomPaint(
                                            painter: MapPainter(
                                              terrain: terrain,
                                              buildings: buildings,
                                              cellSize: cellSize,
                                              borderThickness: 4.0,
                                              dragPreview: _preview,
                                              version: _paintVersion,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_moveMode && _moveRequestedId != null)
                                ConfirmButtonOverlay(
                                  viewportPos: _confirmBtnViewportPos(cellSize),
                                  onConfirm: () {
                                    setState(() {
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
            ),
          ),
        ],
      ),
    );
  }
}
