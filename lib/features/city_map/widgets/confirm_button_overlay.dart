import 'dart:math';
import 'package:flutter/material.dart';

class ConfirmButtonOverlay extends StatelessWidget {
  final Offset? viewportPos;
  final VoidCallback onConfirm;
  const ConfirmButtonOverlay({super.key, required this.viewportPos, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    if (viewportPos == null) return const SizedBox.shrink();
    final left = max(0.0, viewportPos!.dx);
    final top = max(0.0, viewportPos!.dy);

    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 2,
        shape: const CircleBorder(),
        color: Colors.green,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onConfirm,
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
