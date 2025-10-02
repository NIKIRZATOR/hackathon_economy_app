import 'package:flutter/material.dart';

/// Всплывающее окно с результатом ответа:
/// — Заголовок «Альманах»,
/// — Крупная плашка «Молодец!» или «Ответ неверный»,
/// — Прокручиваемое пояснение, скрытый скролл,
/// — Кнопка «Понятно».
class AlmanacAnswerDialog extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  /// Для соблюдения размеров 1в1 с окном «Читать»
  final double screenH;
  final double screenW;

  const AlmanacAnswerDialog({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.screenH,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = isCorrect ? 'Молодец!' : 'Ответ неверный';

    return Container(
      height: screenH * 0.74,
      width: screenW * 0.89,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Заголовок окна
          Text(
            'Альманах',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),

          // Крупная метка результата
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              titleText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Прокручиваемое пояснение без видимого скроллбара
          Expanded(
            child: ScrollConfiguration(
              behavior: const _NoScrollbar(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  explanation.isNotEmpty
                      ? explanation
                      : 'Пояснение будет добавлено.',
                  style: TextStyle(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Кнопка закрытия
          _PinkPillButton(
            text: 'Понятно',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Розовая таблетка-кнопка (та же стилистика, что в статье)
class _PinkPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PinkPillButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF82BE), Color(0xFFDD41DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// Локальная версия скрытого скролла
class _NoScrollbar extends ScrollBehavior {
  const _NoScrollbar();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
