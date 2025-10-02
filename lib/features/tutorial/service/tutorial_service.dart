import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/tutorial_overlay.dart';
import '../model/tutorial_step.dart';
import '../data/tutorial_steps_welcome.dart'; // kWelcomeSteps

class TutorialService {
  TutorialService._();
  static final TutorialService I = TutorialService._();

  Future<void> showWelcomeTutorial(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true, // можно закрыть тапом мимо
      barrierColor: Colors.transparent, // затемнение делаю внутри оверлея
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => true,
          child: Material(
            type: MaterialType.transparency,
            child: TutorialOverlay(
              steps: kWelcomeSteps,
              onAction: _noopAction,
              onFinished: () {},
            ),
          ),
        );
      },
    );
  }

  /// --- НОВОЕ: обзор интерфейса города по шагам ---
  Future<void> showCityUiTour(
      BuildContext context, {
        required GlobalKey profileKey,
        required GlobalKey settingsKey,
        required GlobalKey tasksKey,
        required GlobalKey shopKey,
        required GlobalKey almanacKey,
      }) async {
    // ждать, пока всё отрисуется
    await Future.delayed(const Duration(milliseconds: 50));

    final steps = [
      _UiStep(
        rect: _rectFromKey(profileKey),
        text: 'Это твой профиль. Здесь можно посмотреть информацию о городе,\nвключая данные по дебетовой карте.',
        misha: 'assets/images/Misha/Misha_like.png',
        arrowDir: _ArrowDir.left,   // ← раньше было right, перевернули
      ),
      _UiStep(
        rect: _rectFromKey(settingsKey),
        text: 'Настройки. Тут регулируем громкость эффектов и музыки.',
        misha: 'assets/images/Misha/Misha_neutral.png',
        arrowDir: _ArrowDir.right,  // ← раньше было left, перевернули
      ),
      _UiStep(
        rect: _rectFromKey(tasksKey),
        text: 'Список заданий. Выполняй задачи, чтобы повышать уровень.',
        misha: 'assets/images/Misha/Misha_points.png',
        arrowDir: _ArrowDir.down,   // ← было up, теперь над иконкой
      ),
      _UiStep(
        rect: _rectFromKey(shopKey),
        text: 'Магазин. Здесь ты можешь покупать здания,\nкоторые будут приносить тебе монеты или ресурсы',
        misha: 'assets/images/Misha/Misha_happy.png',
        arrowDir: _ArrowDir.down,   // ← было up
      ),
      _UiStep(
        rect: _rectFromKey(almanacKey),
        text: 'Альманах знаний. Изучай продукты Газпромбанка и получай награды.',
        misha: 'assets/images/Misha/Misha_gift.png',
        arrowDir: _ArrowDir.down,   // ← было up
      ),

    ];

    for (final s in steps) {
      if (s.rect == null) continue; // на всякий
      await showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        builder: (_) {
          return Stack(
            children: [
              // сам оверлей с 1 шагом (никаких правок в TutorialOverlay!)
              Material(
                type: MaterialType.transparency,
                child: TutorialOverlay(
                  steps: [
                    TutorialStep(
                      id: 'city_ui',
                      text: s.text,
                      mishaAsset: s.misha,
                    ),
                  ],
                  onAction: (_) async {},
                  highlightRect: s.rect,
                ),
              ),
              // простая стрелка поверх, рядом с дырой
              _ArrowHint(rect: s.rect!, dir: s.arrowDir),
            ],
          );
        },
      );
    }
  }

  Rect? _rectFromKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final rb = ctx.findRenderObject() as RenderBox?;
    if (rb == null || !rb.attached) return null;
    final offset = rb.localToGlobal(Offset.zero);
    return offset & rb.size;
  }

  // ← добавили пустой обработчик action'ов для welcome-тура
  Future<void> _noopAction(String _) async {}
}

/// Внутреннее описание шага UI-тура
class _UiStep {
  _UiStep({
    required this.rect,
    required this.text,
    required this.misha,
    required this.arrowDir,
  });

  final Rect? rect;
  final String text;
  final String misha;
  final _ArrowDir arrowDir;
}

enum _ArrowDir { up, down, left, right }

/// Простая «стрелочка» рядом с подсвеченной областью.
class _ArrowHint extends StatelessWidget {
  const _ArrowHint({required this.rect, required this.dir});

  final Rect rect;
  final _ArrowDir dir;

  @override
  Widget build(BuildContext context) {
    const double size = 44;
    late double left, top;
    late double angle;

    switch (dir) {
      case _ArrowDir.up:
        left = rect.center.dx - size / 2;
        top = rect.bottom + 8;        // стрелка ниже иконки, «смотрит вверх»
        angle = math.pi;               // развернём вниз-вверх
        break;
      case _ArrowDir.down:
        left = rect.center.dx - size / 2;
        top = rect.top - size - 8;
        angle = 0;
        break;
      case _ArrowDir.right:
        left = rect.right + 8;
        top = rect.center.dy - size / 2;
        angle =  math.pi / 2;   // было -math.pi/2
        break;
      case _ArrowDir.left:
        left = rect.left - size - 8;
        top = rect.center.dy - size / 2;
        angle = -math.pi / 2;   // было  math.pi/2
        break;
    }

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Icon(
          Icons.arrow_downward,
          size: size,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
        ),
      ),
    );
  }
}
