import 'package:flutter/material.dart';

class MainTextButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback onPressed;

  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const MainTextButton({
    Key? key,
    this.text,
    this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    this.borderRadius = 18,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w600,
  })  : assert(
          (text != null) ^ (child != null),
          'Укажи либо text, либо child (но не оба).',
        ),
        super(key: key);

  @override
  State<MainTextButton> createState() => _MainTextButtonState();
}

class _MainTextButtonState extends State<MainTextButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget content = widget.child ??
        Text(
          widget.text!,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
          ),
        );

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
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [theme.colorScheme.primary, theme.colorScheme.tertiary]
                  : [theme.colorScheme.tertiary, theme.colorScheme.primary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.6 : 0.28),
                offset: const Offset(2, 4),
                blurRadius: _isHovered ? 8 : 4,
              ),
            ],
          ),
          child: Padding(
            padding: widget.padding,
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
