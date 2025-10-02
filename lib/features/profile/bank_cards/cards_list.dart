import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/features/profile/bank_cards/bank_cards_mock.dart';
import 'package:hackathon_economy_app/features/profile/bank_cards/bank_card.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';

class CardsList extends StatefulWidget {
  const CardsList({
    super.key,
    this.useInk = true,
    required this.level,
  });

  final int level;
  final bool useInk;

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  final Set<int> _toggled = <int>{}; 

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: mockCards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final card = mockCards[i];
        final isOpen = _toggled.contains(i);
        final isLocked = widget.level != card.requiredLevel;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isLocked ? null : () {
              setState(() {
                if (isOpen) {
                  _toggled.remove(i);
                } else {
                  AudioManager().playSfx('mission_colmlete.mp3');
                  _toggled.add(i);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: BankCard(
              locked: isLocked,
              data: card,
              isInk: widget.useInk,
              isOpen: isOpen,
            ),
          ),
        );
      },
    );
  }
}
