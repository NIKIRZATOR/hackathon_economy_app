import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StarButton extends StatefulWidget {
  final String text;
  final double size;
  final String assetPath;
  final VoidCallback onPressed;

  const StarButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onPressed,
    this.size = 60,
  });

  @override
  State<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapUp() {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final startColors = [theme.colorScheme.primary, theme.colorScheme.secondary];
    final endColors = [theme.colorScheme.secondary, theme.colorScheme.primary];

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: TweenAnimationBuilder<List<Color>>(
          tween: ColorTweenSequence(_isPressed ? endColors : startColors),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          builder: (context, colors, child) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _isHovered ? 0.6 : 0.28,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: _isHovered ? 8 : 4,
                        sigmaY: _isHovered ? 8 : 4,
                      ),
                      child: SvgPicture.asset(
                        widget.assetPath,
                        width: widget.size,
                        height: widget.size,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: SvgPicture.asset(
                      widget.assetPath,
                      width: widget.size,
                      height: widget.size,
                      color: Colors.white,
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, 2),
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ColorTweenSequence extends Tween<List<Color>> {
  ColorTweenSequence(List<Color> target) : super(begin: target, end: target);

  @override
  List<Color> lerp(double t) {
    return List.generate(
      begin!.length,
      (i) => Color.lerp(begin![i], end![i], t)!,
    );
  }
}
