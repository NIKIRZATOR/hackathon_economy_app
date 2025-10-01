import 'package:flutter/material.dart';

class MainTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const MainTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<MainTextButton> createState() => _MainTextButtonState();
}

class _MainTextButtonState extends State<MainTextButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
                  : [theme.colorScheme.tertiary, theme.colorScheme.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.6 : 0.28),
                offset: const Offset(2, 4),
                blurRadius: _isHovered ? 8 : 4,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Text(
              widget.text,
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
