import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/features/user/model/user_model.dart';
import 'top_bar_functions.dart';

class CityTopBar extends StatelessWidget {
  const CityTopBar({
    super.key,
    this.user, // теперь необязательный
    required this.userId,
    required this.userLvl,
    required this.xpCount,
    required this.coinsCount,
    required this.screenHeight,
    required this.screenWidth,
  });

  final UserModel? user; // nullable
  final int userId;
  final int userLvl;
  final int xpCount;
  final int coinsCount;

  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final barHeight = screenHeight * 0.08;

    if (user == null) {
      // показываем лоадер на месте топ-бара
      return SizedBox(
        height: barHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isNarrow = screenWidth < 420;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: barHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(0.25), width: 1),
          ),
        ),
        child: Row(
          children: [
            _LevelButton(
              level: userLvl,
              onTap: () => openLevelInfo(context, userId: userId, level: userLvl),
            ),
            SizedBox(width: screenHeight * 0.12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  direction: Axis.vertical,
                  children: [
                    _SmallInfoPill(label: 'опыт', value: '$xpCount', width: isNarrow ? 92 : 120, height: 20),
                    _SmallInfoPill(label: 'монеты', value: '$coinsCount', width: isNarrow ? 92 : 120, height: 20),
                  ],
                ),
              ),
            ),
            _SettingsButton(onTap: () => openSettings(context, userId: userId)),
          ],
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({required this.level, required this.onTap});

  final int level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = 40.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(diameter / 2),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          child: Text(
            "$levelур" ,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: .9),
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallInfoPill extends StatelessWidget {
  const _SmallInfoPill({
    required this.label,
    required this.value,
    required this.width,
    required this.height,
  });

  final String label;
  final String value;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.centerLeft,
        child: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(
            '$label  $value',
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const side = 44.0;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4),
        child: const FittedBox(
          child: Text(
            'нас\nстро\nйки',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
