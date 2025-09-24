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

  // позиция кнопки подтверждения (галочка)
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
}
