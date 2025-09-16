import '../models/building.dart';

bool insideWithoutBorder(int x, int y, int w, int h, int cols, int rows) {
  if (x <= 0 || y <= 0) return false;
  if (x + w >= cols || y + h >= rows) return false;
  return true;
}

bool terrainFreeFor(List<List<int>> terrain, int x, int y, int w, int h) {
  for (int j = y; j < y + h; j++) {
    for (int i = x; i < x + w; i++) {
      final cell = terrain[j][i];
      // 1 — дорога, 2 — занято зданием карты, 3 — вода
      if (cell == 1 || cell == 2 || cell == 3) return false;
    }
  }
  return true;
}

bool overlapsOther(List<Building> buildings, int x, int y, int w, int h, {String? exceptId}) {
  final nx1 = x, ny1 = y, nx2 = x + w, ny2 = y + h;
  for (final b in buildings) {
    if (b.id == exceptId) continue;
    final bx1 = b.x, by1 = b.y, bx2 = b.x + b.w, by2 = b.y + b.h;
    final inter = nx1 < bx2 && nx2 > bx1 && ny1 < by2 && ny2 > by1;
    if (inter) return true;
  }
  return false;
}

bool canPlaceAt({
  required List<List<int>> terrain,
  required List<Building> buildings,
  required int x,
  required int y,
  required int w,
  required int h,
  required int cols,
  required int rows,
  String? exceptId,
}) {
  return insideWithoutBorder(x, y, w, h, cols, rows) &&
      terrainFreeFor(terrain, x, y, w, h) &&
      !overlapsOther(buildings, x, y, w, h, exceptId: exceptId);
}
