import 'package:flutter/material.dart';


/// Содержимое окна "Читать": голубой контейнер, заголовок, картинка, текст,
/// вопрос с красной строки, две розовые таблетки ПРАВДА/ЛОЖЬ.
/// Текст прокручивается, скроллбар скрыт.
class AlmanacArticleDialog extends StatelessWidget {
  final String articleAsset;
  final double screenH;
  final double screenW;

  const AlmanacArticleDialog({
    super.key,
    required this.articleAsset,
    required this.screenH,
    required this.screenW,
  });

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
          // Заголовок по центру
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

          // Картинка продукта
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              articleAsset,
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(
                height: 150,
                child: Center(child: Text('Нет изображения')),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Прокручиваемая область без видимого скроллбара
          Expanded(
            child: ScrollConfiguration(
              behavior: const _NoScrollbar(),
              child: const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _ArticleBody(),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ПРАВДА / ЛОЖЬ (розовые таблетки)
          Row(
            children: [
              Expanded(
                child: _PinkPillButton(
                  text: 'ПРАВДА',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Выбрано: ПРАВДА')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PinkPillButton(
                  text: 'ЛОЖЬ',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Выбрано: ЛОЖЬ')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Тело текста статьи + вопрос с «красной строки»
class _ArticleBody extends StatelessWidget {
  const _ArticleBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Преимущества карты:\n'
          'Переводы без комиссии\n'
          'Бесплатное снятие наличных\n'
          'До 20% кэшбэк у партнеров\n'
          'Оплата смартфоном с Gazprom Pay\n'
          'Оплата услуг ЖКХ без комиссии\n'
          'Сервис «Антиспам»\n'
          'Успейте получить 100% кэшбэк в супермаркетах',
          style: TextStyle(
            color: theme.colorScheme.onBackground,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),

        // «Красная строка» — отступ первой строки
        Text(
          '   Умная карта предоставляет кэшбек у партнеров?',
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

/// Розовая большая таблетка-кнопка (тот же стиль, что "Читать")
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

/// Убираем системный скроллбар
class _NoScrollbar extends ScrollBehavior {
  const _NoScrollbar();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
