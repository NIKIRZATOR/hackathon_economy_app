import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/almanac_links.dart';

class AlmanacAnswerDialog extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final double screenH;
  final double screenW;
  final String productTitle; // ← название продукта из окна «Читать»

  const AlmanacAnswerDialog({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.screenH,
    required this.screenW,
    required this.productTitle,
  });

  Future<void> _openProductLink(BuildContext context) async {
    final link = almanacLinkByTitle(productTitle);
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ссылка для этого продукта будет добавлена позже'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

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

          // Узнать больше — ссылка строго из Excel (лист ФЛ → Продукт → Ссылка)
          _PinkPillButton(
            text: 'Узнать больше',
            onTap: () => _openProductLink(context),
          ),

          const SizedBox(height: 10),

          _PinkPillButton(
            text: 'Понятно',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

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

class _NoScrollbar extends ScrollBehavior {
  const _NoScrollbar();
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) => child;
}
