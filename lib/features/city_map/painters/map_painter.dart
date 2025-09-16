import 'package:flutter/material.dart';
import '../models/building.dart';
import '../models/drag_preview.dart';

class MapPainter extends CustomPainter {
  final List<List<int>> terrain;
  final List<Building> buildings;
  final double cellSize;
  final double borderThickness;
  final DragPreview? dragPreview;
  final int version;

  MapPainter({
    required this.terrain,
    required this.buildings,
    required this.cellSize,
    required this.borderThickness,
    required this.dragPreview,
    required this.version,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = terrain.length;
    final cols = terrain.first.length;

    final Paint p = Paint()..style = PaintingStyle.fill;

    // 1) клетки по типу
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        switch (terrain[y][x]) {
          case 0:
            p.color = Colors.white;
            break;
          case 1:
            p.color = Colors.black12;
            break;
          case 2:
            p.color = const Color(0xFF5DA9E9);
            break;
        }
        canvas.drawRect(Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize), p);
      }
    }

    // 2) сетка
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.black12;

    for (int i = 0; i <= cols; i++) {
      final dx = i * cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, rows * cellSize), gridPaint);
    }
    for (int j = 0; j <= rows; j++) {
      final dy = j * cellSize;
      canvas.drawLine(Offset(0, dy), Offset(cols * cellSize, dy), gridPaint);
    }

    // 3) чёрные борта
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness
      ..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, cols * cellSize, rows * cellSize), borderPaint);

    // 4) здания
    for (final b in buildings) {
      final rect = Rect.fromLTWH(b.x * cellSize, b.y * cellSize, b.w * cellSize, b.h * cellSize);
      canvas.drawRect(rect, Paint()..color = b.fill);
      canvas.drawRect(rect, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = b.border);
    }

    // 5) превью при переносе
    if (dragPreview != null) {
      final r = dragPreview!.rect;
      final rect = Rect.fromLTWH(r.left * cellSize, r.top * cellSize, r.width * cellSize, r.height * cellSize);
      final ok = dragPreview!.isValid;
      canvas.drawRect(rect, Paint()..color = (ok ? Colors.green : Colors.red).withOpacity(0.35));
      canvas.drawRect(rect, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = (ok ? Colors.green : Colors.red));
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter old) {
    return old.version != version ||
        old.terrain != terrain ||
        old.buildings != buildings ||
        old.cellSize != cellSize ||
        old.dragPreview != dragPreview ||
        old.borderThickness != borderThickness;
  }
}
