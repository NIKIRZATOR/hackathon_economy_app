part of '../city_map_screen.dart';

extension _SearchAndTapBuild on _CityMapScreenState {

  // поиск зданий на карте
  Building? _buildingAtCell(int cellX, int cellY) {
    for (final b in buildings) {
      if (cellX >= b.x && cellX < b.x + b.w && cellY >= b.y && cellY < b.y + b.h) {
        return b;
      }
    }
    return null;
  }

  // нажатие по карте (если не перенос) — открываем диалог здания
  void _onTapAt(Offset viewportPos, double cellSize) {
    if (_moveMode) return;
    final scene = _toScene(viewportPos);
    final int x = (scene.dx / cellSize).floor();
    final int y = (scene.dy / cellSize).floor();
    if (x < 0 || y < 0 || x >= kMapCols || y >= kMapRows) return;

    final tapped = _buildingAtCell(x, y);
    if (tapped != null) _openBuildingDialog(tapped);
  }

  // строка ключ-значение в диалоге
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
}
