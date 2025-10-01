import 'dart:async';
import 'package:flutter/material.dart';

// если formatCompactNum уже есть в другом месте — убери эту функцию
String formatCompactNum(num v, {int precision = 2}) {
  if (v.abs() < 1000) return v.toStringAsFixed(0);
  const units = ['K', 'M', 'B', 'T'];
  double n = v.toDouble();
  int u = -1;
  while (n.abs() >= 1000 && u < units.length - 1) {
    n /= 1000.0;
    u++;
  }
  String s = n.toStringAsFixed(precision);
  s = s.replaceFirst(RegExp(r'\.?0+$'), '');
  return '$s${units[u]}';
}

class CoinsOval extends StatefulWidget {
  const CoinsOval({
    super.key,
    required this.amount,
    required this.iconPath,
    this.width = 75,
    this.height = 23,
    this.iconSize = 32,
    this.precision = 2,
    this.textStyle,
    this.deltaStream,
  });

  final num amount;
  final String iconPath;
  final double width;
  final double height;
  final double iconSize;
  final int precision;
  final TextStyle? textStyle;
  final Stream<double>? deltaStream;

  @override
  State<CoinsOval> createState() => _CoinsOvalState();
}

class _CoinsOvalState extends State<CoinsOval> with SingleTickerProviderStateMixin {
  double? _delta; // текущая отображаемая дельта
  Timer? _hideTimer; // таймер скрытия дельты
  StreamSubscription<double>? _sub;

  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 220),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.2),
    end: const Offset(0, -0.5),
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));
  late final Animation<double> _fade =
  CurvedAnimation(parent: _ac, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    if (widget.deltaStream != null) {
      _sub = widget.deltaStream!.listen(_onDelta);
    }
  }

  void _onDelta(double d) async {
    if (!mounted) return;
    // агрегируем дельты, если анимация уже идёт
    setState(() => _delta = (_delta ?? 0) + d);
    _hideTimer?.cancel();

    if (!_ac.isAnimating && _ac.value == 0.0) {
      await _ac.forward();
    }
    // длительность ~600мс всплывашки
    _hideTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      await _ac.reverse();
      if (!mounted) return;
      setState(() => _delta = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hideTimer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = formatCompactNum(widget.amount, precision: widget.precision);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.47),
              borderRadius: BorderRadius.circular(50),
            ),
          ),

          Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.only(left: 25),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: widget.textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    //fontWeight: FontWeight.w700,
                    shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
                  ),
            ),
          ),

          Positioned(
            left: -10,
            top: -6,
            child: Image.asset(
              widget.iconPath,
              width: widget.iconSize,
              height: widget.iconSize,
            ),
          ),

          // всплывающая дельта
          if (_delta != null)
            Positioned(
              right: -4,
              top: -12,
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _fade,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+${_delta!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.greenAccent,
                          shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
                        ),
                      ),
                      const SizedBox(width: 3),
                      Image.asset(
                        widget.iconPath,
                        width: 12,
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
