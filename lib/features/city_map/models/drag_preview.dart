import 'package:flutter/material.dart';

class DragPreview {
  final Rect rect; // в координатах клеток
  final bool isValid;
  const DragPreview(this.rect, this.isValid);
}
