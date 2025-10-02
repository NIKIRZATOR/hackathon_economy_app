import 'package:flutter/material.dart';
import 'almanac_article_dialog.dart';

// Данные (продукты сгруппированы по главам/уровням)
import '../data/almanac_lessons.dart';
import 'dart:math' as math;

/// Окно "Альманах": список уроков + розовые таблетки "Читать"
class AlmanacDialog extends StatelessWidget {
  final double targetH;
  final double targetW;

  const AlmanacDialog({
    super.key,
    required this.targetH,
    required this.targetW,
  });

  @override
  Widget build(BuildContext context) {
    // Формируем список виджетов (главы + уроки) динамически из данных
    final List<Widget> children = [];

    for (final level in kAlmanacLevelsOrder) {
      final lessons = kAlmanacLessonsByLevel[level];
      if (lessons == null || lessons.isEmpty) continue;

      // Заголовок главы
      children.addAll([
        _SectionLabel(text: '$level глава'),
        const SizedBox(height: 8),
      ]);

      // Список уроков
      for (int i = 0; i < lessons.length; i++) {
        final l = lessons[i];
        children.add(
          _LessonTile(
            title: l.title,
            onRead: () => _openArticle(context, l.imageAsset),
          ),
        );
        if (i != lessons.length - 1) {
          children.add(const SizedBox(height: 8));
        }
      }

      // После 1-й главы — блок «Награда» (как в исходном макете)
      if (level == 1) {
        children.addAll([
          const SizedBox(height: 12),
          const _SectionLabel(text: 'Награда'),
          const SizedBox(height: 8),
          const _RewardsRow(),
        ]);
      }

      // Отступ между главами
      children.add(const SizedBox(height: 12));
    }

    // КЛЮЧ: аккуратно берём доступные constraints.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Если высота конечная — используем её.
        // Если бесконечная — берём безопасную величину относительно экрана.
        final bool hasFiniteHeight = constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final bool hasFiniteWidth  = constraints.hasBoundedWidth  && constraints.maxWidth.isFinite;

        final double availH = hasFiniteHeight
            ? constraints.maxHeight
            : targetH * 0.66; // fallback при unbounded

        final double availW = hasFiniteWidth
            ? constraints.maxWidth
            : math.min(targetW * 0.89, targetW); // fallback при unbounded

        return SizedBox(
          height: availH,
          width:  availW,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,     // ⬅️ скрываем скроллбар
                overscroll: false,     // ⬅️ убираем «свечения» на iOS/Android
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                children: children,
              ),
            ),
          ),
        );

      },
    );
  }

  void _openArticle(BuildContext context, String asset) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.background,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: AlmanacArticleDialog(
              articleAsset: asset,
              screenH: targetH,
              screenW: targetW,
            ),
          ),
        );
      },
    );
  }
}

/// ----- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ (без изменений стиля) -----

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onBackground.withOpacity(.95),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final String title;
  final VoidCallback onRead;

  const _LessonTile({required this.title, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 8),
          _ReadPinkPill(text: 'Читать', onTap: onRead),
        ],
      ),
    );
  }
}

/// Маленькая розовая таблетка "Читать"
class _ReadPinkPill extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ReadPinkPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF82BE), Color(0xFFDD41DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: const Text(
            'Читать',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _BlueCenterCard extends StatelessWidget {
  final String title;

  const _BlueCenterCard({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      alignment: Alignment.center,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Widget leftWidget;
  final String title;

  const _RewardCard({required this.leftWidget, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
      child: Row(
        children: [
          leftWidget,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardsRow extends StatelessWidget {
  const _RewardsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _BlueCenterCard(title: 'Награда')),
        SizedBox(width: 10),
        Expanded(
          child: _RewardCard(
            leftWidget: Icon(Icons.trending_up, size: 38, color: Colors.white),
            title: '4-ой уровень',
          ),
        ),
      ],
    );
  }
}
