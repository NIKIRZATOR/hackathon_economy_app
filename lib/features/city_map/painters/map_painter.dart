import 'dart:ui' as ui;
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

  // текстуры
  final ui.Image? roadTexture;
  final ui.Image? grassTexture; // фон-трава

  MapPainter({
    required this.terrain,
    required this.buildings,
    required this.cellSize,
    required this.borderThickness,
    required this.dragPreview,
    required this.version,
    this.roadTexture,
    this.grassTexture,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = terrain.length;
    final cols = terrain.first.length;
    final mapRect = Rect.fromLTWH(0, 0, cols * cellSize, rows * cellSize);

    // ── 0) Фон: затилить травой каждый клеточный прямоугольник
    if (grassTexture != null) {
      for (int y = 0; y < rows; y++) {
        for (int x = 0; x < cols; x++) {
          paintImage(
            canvas: canvas,
            rect: Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
            image: grassTexture!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          );
        }
      }
    } else {
      // запасной фон
      canvas.drawRect(mapRect, Paint()..color = Colors.grey.shade200);
    }

    // ── 1) Спец-клетки поверх фона (0 — пусто, оставляем траву)
    final Paint p = Paint()..style = PaintingStyle.fill;
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final t = terrain[y][x];
        if (t == 0) continue;

        final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
        if (t == 1 && roadTexture != null) {
          paintImage(
            canvas: canvas,
            rect: rect,
            image: roadTexture!,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          );
        } else {
          switch (t) {
            case 1: p.color = Colors.black12; break;           // если нет текстуры дороги
            case 2: p.color = const Color(0xFFBDBDBD); break;  // статик
            case 3: p.color = const Color(0xFF5DA9E9); break;  // вода
            default: continue;
          }
          canvas.drawRect(rect, p);
        }
      }
    }

    // ── 2) Сетка
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

    // ── 3) Периметр
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness
      ..color = Colors.black;
    canvas.drawRect(mapRect, borderPaint);

    // ── 4) Здания
    for (final b in buildings) {
      final rect = Rect.fromLTWH(b.x * cellSize, b.y * cellSize, b.w * cellSize, b.h * cellSize);
      if (b.image != null) {
        paintImage(canvas: canvas, rect: rect, image: b.image!, fit: BoxFit.cover, filterQuality: FilterQuality.medium);
      } else {
        canvas.drawRect(rect, Paint()..color = b.fill);
      }
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = b.border,
      );
    }

    // ── 5) Превью переноса
    if (dragPreview != null) {
      final r = dragPreview!.rect;
      final rect = Rect.fromLTWH(r.left * cellSize, r.top * cellSize, r.width * cellSize, r.height * cellSize);
      final ok = dragPreview!.isValid;
      canvas.drawRect(rect, Paint()..color = (ok ? Colors.green : Colors.red).withValues(alpha: 0.35));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = (ok ? Colors.green : Colors.red),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MapPainter old) {
    return old.version != version ||
        old.terrain != terrain ||
        old.buildings != buildings ||
        old.cellSize != cellSize ||
        old.dragPreview != dragPreview ||
        old.borderThickness != borderThickness ||
        old.roadTexture != roadTexture ||
        old.grassTexture != grassTexture;
  }
}
