import 'package:flutter/material.dart';

class Building {
  final String id;
  String name;
  int level;
  int x; // левый верхний (колонка)
  int y; // левый верхний (строка)
  int w; // ширина в клетках
  int h; // высота в клетках
  final Color fill;
  final Color border;

  Building({
    required this.id,
    required this.name,
    required this.level,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.fill,
    required this.border,
  });

  Rect cellRect() => Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());

  void rotateTranspose() {
    final t = w;
    w = h;
    h = t;
  }
}
