// lib/features/almanac/widgets/almanac_article_dialog.dart
import 'package:flutter/material.dart';

import '../data/almanac_answers.dart';
import '../model/almanac_answer.dart';
import 'almanac_answer_dialog.dart';

/// Содержимое окна "Читать": заголовок, картинка (если есть),
/// теория, вопрос; прокрутка включена, скроллбар скрыт.
class AlmanacArticleDialog extends StatelessWidget {
  final String title;
  final String theoryText;
  final String questionText;
  final String? imageAsset; // ← картинка
  final double screenH;
  final double screenW;

  const AlmanacArticleDialog({
    super.key,
    required this.title,
    required this.theoryText,
    required this.questionText,
    this.imageAsset,
    required this.screenH,
    required this.screenW,
  });

  void _openAnswerDialog(BuildContext context, {required bool userChoice}) {
    final AlmanacAnswer? data = kAlmanacAnswersByProduct[title];

    // Если данных нет — подставим заглушку (ничего не падает).
    final bool isCorrect = (data?.correct ?? true) == userChoice;
    final String explanation =
        data?.explanation ?? 'Пояснение будет добавлено.';

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.transparent,
          child: AlmanacAnswerDialog(
            isCorrect: isCorrect,
            explanation: explanation,
            screenH: screenH,
            screenW: screenW,
            productTitle: title, // 👈 пробрасываем название продукта
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

          // Картинка продукта (опционально)
          if (imageAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imageAsset!,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 150,
                  child: Center(child: Text('Нет изображения')),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Прокручиваемая область без видимого скроллбара
          Expanded(
            child: ScrollConfiguration(
              behavior: const _NoScrollbar(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _ArticleBody(
                  title: title,
                  theory: theoryText,
                  question: questionText,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ПРАВДА / ЛОЖЬ
          Row(
            children: [
              Expanded(
                child: _PinkPillButton(
                  text: 'ПРАВДА',
                  onTap: () => _openAnswerDialog(context, userChoice: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PinkPillButton(
                  text: 'ЛОЖЬ',
                  onTap: () => _openAnswerDialog(context, userChoice: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Тело статьи
class _ArticleBody extends StatelessWidget {
  final String title;
  final String theory;
  final String question;

  const _ArticleBody({
    required this.title,
    required this.theory,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          theory,
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '   $question',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

/// Кнопка (розовая таблетка)
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
            ),
          ),
        ),
      ),
    );
  }
}

/// Скрываем системный скроллбар
class _NoScrollbar extends ScrollBehavior {
  const _NoScrollbar();
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) =>
      child;
}
