import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/tutorial_step.dart';
import 'misha_face.dart';

typedef TutorialActionCallback = Future<void> Function(String action);

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onAction,
    this.highlightRect,
    this.onFinished,
  });

  final List<TutorialStep> steps;
  final TutorialActionCallback onAction;
  final Rect? highlightRect;
  final VoidCallback? onFinished;

  @override
  TutorialOverlayState createState() => TutorialOverlayState();
}

class TutorialOverlayState extends State<TutorialOverlay> {
  int _index = 0;
  String _visibleText = '';
  Timer? _typer;
  bool _typing = false;

  TutorialStep get _step => widget.steps[_index];

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void dispose() {
    _typer?.cancel();
    super.dispose();
  }

  void _startTyping() {
    _typer?.cancel();
    _visibleText = '';
    _typing = true;

    final full = _step.text;
    const speed = Duration(milliseconds: 18);

    int i = 0;
    _typer = Timer.periodic(speed, (t) {
      if (i >= full.length) {
        t.cancel();
        setState(() => _typing = false);
        return;
      }
      setState(() => _visibleText = full.substring(0, ++i));
    });
  }

  Future<void> _next() async {
    if (_typing) {
      _typer?.cancel();
      setState(() {
        _visibleText = _step.text;
        _typing = false;
      });
      return;
    }
    if (_step.action != null) {
      await widget.onAction(_step.action!);
      return;
    }
    _advance();
  }

  void _advance() {
    if (_index < widget.steps.length - 1) {
      setState(() {
        _index++;
        _startTyping();
      });
    } else {
      widget.onFinished?.call();
      Navigator.of(context).pop(); // закрыть оверлей
    }
  }

  void completeCurrentAction() => _advance();

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    final showHole =
        widget.highlightRect != null && _step.action == 'open_shop';
    final hole = widget.highlightRect ?? const Rect.fromLTWH(-1, -1, 0, 0);

    // размеры диалога — «внутри» рамки приложения (см. AppViewSize/стили)
    final double minDialogW = 280.0;
    final double maxDialogW = 420.0;
    final double dialogW = (screen.width * 0.70).clamp(minDialogW, maxDialogW);

    final double minDialogH = 220.0;
    final double maxDialogH = 420.0;
    final double dialogH = (screen.height * 0.45).clamp(minDialogH, maxDialogH);

    return Stack(
      children: [
        if (showHole) ..._buildDimBlocksAroundHole(hole, screen) else
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: Container(color: const Color.fromRGBO(0, 0, 0, 0.55)),
            ),
          ),

        // карточка по центру
        Positioned.fill(
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: _next,
                behavior: HitTestBehavior.deferToChild,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: minDialogW,
                    maxWidth: dialogW,
                    minHeight: minDialogH,
                    maxHeight: dialogH,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _DialogCard(
                      text: _visibleText,
                      mishaAsset: _step.mishaAsset,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDimBlocksAroundHole(Rect hole, Size screen) {
    const color = Color.fromRGBO(0, 0, 0, 0.55);
    final top = Rect.fromLTWH(0, 0, screen.width, hole.top);
    final left = Rect.fromLTWH(0, hole.top, hole.left, hole.height);
    final right =
    Rect.fromLTWH(hole.right, hole.top, screen.width - hole.right, hole.height);
    final bottom =
    Rect.fromLTWH(0, hole.bottom, screen.width, screen.height - hole.bottom);

    Rect r(Rect rr) => Rect.fromLTWH(
      rr.left.clamp(0.0, screen.width),
      rr.top.clamp(0.0, screen.height),
      max(0.0, rr.width),
      max(0.0, rr.height),
    );

    Widget block(Rect rr) => Positioned.fromRect(
      rect: r(rr),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Container(color: color),
      ),
    );

    final holeBorder = Positioned.fromRect(
      rect: r(hole.inflate(4)),
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ),
    );

    return [block(top), block(left), block(right), block(bottom), holeBorder];
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({required this.text, required this.mishaAsset});

  final String text;
  final String mishaAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // цвета/шрифты из AppTheme
    return LayoutBuilder(
      builder: (_, c) {
        final mishaSize = (c.maxWidth * 0.28).clamp(100.0, 160.0);
        return Stack(
          clipBehavior: Clip.none, // не обрезать Мишу
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface, // = AppColors.iris
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Миша',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 120),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Тапни по окну, чтобы продолжить',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: -mishaSize * 0.55, // поднят на ~55% высоты, не обрезается
              child: MishaFace(asset: mishaAsset, size: mishaSize),
            ),

          ],
        );
      },
    );
  }
}
