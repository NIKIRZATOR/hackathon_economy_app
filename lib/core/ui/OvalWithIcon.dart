import 'package:flutter/material.dart';

class OvalWithIcon extends StatelessWidget {
  final int current;
  final int? total;
  final String iconPath;
  final double width;
  final double height;
  final double iconSize;

  const OvalWithIcon({
    super.key,
    required this.current,
    this.total,
    required this.iconPath,
    this.width = 75,
    this.height = 23,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasProgress = total != null;
    final double progress =
        hasProgress ? (current / total!).clamp(0.0, 1.0) : 0;

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
        if (hasProgress)
          Container(
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
            '$current',
            style: const TextStyle(color: Colors.white, fontSize: 9),
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
