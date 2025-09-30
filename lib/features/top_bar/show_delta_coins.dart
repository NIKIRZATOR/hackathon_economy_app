import 'dart:async';
import 'package:flutter/material.dart';

class ShowDeltaCoins extends StatefulWidget {
  const ShowDeltaCoins({super.key, required this.stream, required this.iconPath});

  final Stream<double> stream;
  final String iconPath;

  @override
  State<ShowDeltaCoins> createState() => _ShowDeltaCoinsState();
}

class _ShowDeltaCoinsState extends State<ShowDeltaCoins> with SingleTickerProviderStateMixin {
  double? _lastDelta;
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 250),
  );
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, 0.3), end: const Offset(0, -0.6))
      .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  late final Animation<double> _fade =
  CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((d) async {
      if (!mounted) return;
      setState(() => _lastDelta = d);
      await _ac.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await _ac.reverse();
      if (mounted) setState(() => _lastDelta = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lastDelta == null) return const SizedBox.shrink();
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${_lastDelta!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.green, // TODO ЗАМЕНИТЬ НА БРЕНДБУК ЦВЕТ
                shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
              ),
            ),
            const SizedBox(width: 4),
            Image.asset(widget.iconPath, width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}
