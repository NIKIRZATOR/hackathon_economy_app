import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/tutorial_step.dart';

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

  /// прямоугольник подсветки (например, кнопка «Магазин») в координатах экрана
  final Rect? highlightRect;

  final VoidCallback? onFinished;

  @override
  TutorialOverlayState createState() => TutorialOverlayState();
}

/// публичное состояние — чтобы снаружи можно было вызвать completeCurrentAction()
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
    const speed = Duration(milliseconds: 18); // быстрое «печатание»

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

    // если шаг требует действия — мы НЕ продвигаем дальше, ждём completeCurrentAction()
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
    }
  }

  /// Вызывается С СНАРУЖИ, когда действие реально выполнено (например, здание куплено/поставлено)
  void completeCurrentAction() => _advance();

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // показываем «дыру» только когда шаг — "open_shop"
    final showHole = widget.highlightRect != null && _step.action == 'open_shop';
    final hole = widget.highlightRect ?? const Rect.fromLTWH(-1, -1, 0, 0);

// размеры диалога: НЕ шире области игры и немного выше прежнего
    final double minDialogW = 280.0;
    final double maxDialogW = 420.0;                  // жёстный потолок ширины
    final double dialogW = (screen.width * 0.70)      // ~70% ширины текущего экрана игры
        .clamp(minDialogW, maxDialogW);

    final double minDialogH = 220.0;
    final double maxDialogH = 420.0;                  // чуть выше, но точно влезает
    final double dialogH = (screen.height * 0.45)     // ~45% высоты
        .clamp(minDialogH, maxDialogH);


    return Stack(
      children: [
        // ЗАТЕМНЕНИЕ: 4 прямоугольника вокруг «дыры».
        // ВАЖНО: эти области принимают тапы (чтобы можно было «тапни чтобы продолжить»),
        // а зона «дыры» остаётся ПУСТОЙ -> тапы проходят к нижележащей кнопке.
        if (showHole) ..._buildDimBlocksAroundHole(hole, screen) else
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _next,
              child: Container(color: const Color.fromRGBO(0, 0, 0, 0.55)),
            ),
          ),

        // Сам диалог по центру. Он меньше экрана, не «плывёт».
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
                  child: _DialogCard(
                    text: _visibleText,
                    mishaAsset: _step.mishaAsset,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Строит 4 перекрытия вокруг hole с затемнением и обработкой тапов.
  List<Widget> _buildDimBlocksAroundHole(Rect hole, Size screen) {
    const color = Color.fromRGBO(0, 0, 0, 0.55);
    final top = Rect.fromLTWH(0, 0, screen.width, hole.top);
    final left = Rect.fromLTWH(0, hole.top, hole.left, hole.height);
    final right = Rect.fromLTWH(hole.right, hole.top, screen.width - hole.right, hole.height);
    final bottom = Rect.fromLTWH(0, hole.bottom, screen.width, screen.height - hole.bottom);

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

    // белая обводка вокруг «дыры»
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

/// Отдельная карточка диалога с Мишей
class _DialogCard extends StatelessWidget {
  const _DialogCard({required this.text, required this.mishaAsset});

  final String text;
  final String mishaAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final mishaSize = (c.maxWidth * 0.28).clamp(100.0, 160.0);

        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Текст — аккуратный абзац по центру, без «прыжков»
                  Flexible(
                    child: SingleChildScrollView(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 120),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Тапни по окну, чтобы продолжить',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Миша — в правом нижнем углу карточки
            Positioned(
              right: 8,
              bottom: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  mishaAsset,
                  width: mishaSize,
                  height: mishaSize,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
