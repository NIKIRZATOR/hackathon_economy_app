import 'package:flutter/material.dart';

class XpProgressOval extends StatelessWidget {
  final int currentXP;
  final int totalNeedXP;
  final String iconPath;
  final double width;
  final double height;
  final double iconSize;
  final Duration animate;
  final bool showFraction;    // показывать "current/total" вместо одного числа

  const XpProgressOval({
    super.key,
    required this.currentXP,
    required this.totalNeedXP,
    required this.iconPath,
    this.width = 75,
    this.height = 23,
    this.iconSize = 32,
    this.animate = const Duration(milliseconds: 350),
    this.showFraction = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double safeTotal = totalNeedXP <= 0 ? 1 : totalNeedXP.toDouble();
    final double progress = (currentXP / safeTotal).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.47),
            borderRadius: BorderRadius.circular(50),
          ),
        ),

        // заполнение прогресса с анимацией ширины
        AnimatedContainer(
          duration: animate,
          curve: Curves.easeOut,
          width: width * progress,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.tertiary,
                theme.colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(50),
          ),
        ),

        Container(
          width: width,
          height: height,
          padding: const EdgeInsets.only(left: 25),
          alignment: Alignment.centerLeft,
          child: Text(
            showFraction ? '$currentXP/$totalNeedXP' : '$currentXP',
            style: const TextStyle(color: Colors.white, fontSize: 7),
          ),
        ),

        Positioned(
          left: -10,
          top: -6,
          child: Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ],
    );
  }
}
