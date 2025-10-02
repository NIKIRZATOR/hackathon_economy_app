import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/ui/MainIconButton.dart';
import 'package:hackathon_economy_app/features/profile/bank_cards/bank_cards_mock.dart';
import 'package:hackathon_economy_app/features/profile/bank_cards/bank_card.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({
    super.key,
    required this.username,
    required this.cityTitle,
    required this.level,
    this.onOpenCardInfo,
    this.maxWidthHint,
    this.maxHeightHint,
  });

  final String username;
  final String cityTitle;
  final int level;
  final Future<void> Function(BuildContext)? onOpenCardInfo;

  final double? maxWidthHint;
  final double? maxHeightHint;

  @override
  Widget build(BuildContext context) {
    final card = mockCards[level - 1]; 
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    final double maxW = (math.min(
      560,
      math.min(size.width - 48, (maxWidthHint ?? double.infinity) - 24),
    )).clamp(280.0, double.infinity) as double;

    final double maxH = (math.min(
      size.height - 48,
      (maxHeightHint ?? double.infinity) - 24,
    )).clamp(240.0, double.infinity) as double;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surface,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 45, 0),
                    child: Text(
                      'Профиль',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 0.9,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MainIconButton(
                      icon: Icons.close,
                      size: 43,
                      isPink: true,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => onOpenCardInfo?.call(context),
                borderRadius: BorderRadius.circular(16),
                child: BankCard(data: card, isInk: true),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Имя', value: username),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Город', value: cityTitle),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Уровень', value: '$level'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceVariant.withOpacity(0.35);
    final border = theme.colorScheme.outline.withOpacity(0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.85),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Text(
              value.isEmpty ? '—' : value,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
