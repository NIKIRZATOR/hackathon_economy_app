part of '../city_map_screen.dart';

extension _CityMapStateBuildings on _CityMapScreenState {
  void _createRandomBuilding() {
    final w = rng.nextInt(4) + 1;
    final h = rng.nextInt(4) + 1;
    final fill = HSVColor.fromAHSV(1, rng.nextDouble() * 360, 0.5 + rng.nextDouble() * 0.5, 0.7).toColor();
    final border = HSVColor.fromAHSV(1, rng.nextDouble() * 360, 0.7, 0.4).toColor();

    const maxTries = 500;
    for (int attempt = 0; attempt < maxTries; attempt++) {
      final x = rng.nextInt(kMapCols - w);
      final y = rng.nextInt(kMapRows - h);
      final ok = canPlaceAt(
        terrain: terrain,
        buildings: buildings,
        x: x, y: y, w: w, h: h,
        cols: kMapCols, rows: kMapRows,
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
        doSetState(() {
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
}
