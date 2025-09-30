import 'package:flutter/material.dart';

class MainIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isPink;

  const MainIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 56,
    this.isPink = false,
  }) : super(key: key);

  @override
  State<MainIconButton> createState() => _MainIconButtonState();
}

class _MainIconButtonState extends State<MainIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  List<Color> _getGradientColors(ThemeData theme) {
    if (widget.isPink) {
      return [theme.colorScheme.tertiary, theme.colorScheme.primary];
    } else {
      return [theme.colorScheme.primary, theme.colorScheme.secondary];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colors = _getGradientColors(theme);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed ? colors.reversed.toList() : colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(
              widget.isPink ? 10 : 15,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.6 : 0.28),
                offset: const Offset(2, 4),
                blurRadius: _isHovered ? 8 : 4,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 30,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
