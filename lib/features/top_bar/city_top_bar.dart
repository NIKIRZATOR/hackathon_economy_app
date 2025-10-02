import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/app/models/user_model.dart';
import 'package:hackathon_economy_app/core/ui/MainIconButton.dart';
import 'package:hackathon_economy_app/core/ui/StarButton.dart';
import '../../core/ui/OvalFOrCoins.dart';
import '../../core/ui/xp_progress_oval.dart';
import 'top_bar_functions.dart';

// Ключи для обзора интерфейса (профиль и настройки)
final profileButtonKey = GlobalKey();
final settingsButtonKey = GlobalKey();

class CityTopBar extends StatelessWidget {
  const CityTopBar({
    super.key,
    this.user,
    required this.userId,
    required this.userLvl,
    required this.xpCount,
    required this.coinsCount,
    required this.screenHeight,
    required this.screenWidth,
    required this.cityTitle,
    this.coinsDeltaStream,
  });

  final UserModel? user;
  final int userId;
  final String cityTitle;
  final int userLvl;
  final int xpCount;
  final int coinsCount;

  final double screenHeight;
  final double screenWidth;

  final Stream<double>? coinsDeltaStream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 22, left: 60, right: 60),
      child: SizedBox(
        height: screenHeight * 0.09 + 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                // Профиль (звезда/уровень) с ключом
                KeyedSubtree(
                  key: profileButtonKey,
                  child: StarButton(
                    text: '$userLvl',
                    assetPath: 'assets/images/svg/star.svg',
                    size: 70,
                    onPressed: () => openLevelInfo(
                      context,
                      userId: userId,
                      level: userLvl,
                      username: user?.username,
                      cityTitle: cityTitle,
                      hostWidth: screenWidth,
                      hostHeight: screenHeight,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      XpProgressOval(
                        currentXP: xpCount,
                        totalNeedXP: 1250,
                        iconPath: 'assets/images/resources/star.png',
                      ),
                      CoinsOval(
                        amount: coinsCount,
                        iconPath: 'assets/images/resources/coin.png',
                        deltaStream: coinsDeltaStream,
                      )
                    ],
                  ),
                ),
              ],
            ),
            // Настройки с ключом
            KeyedSubtree(
              key: settingsButtonKey,
              child: MainIconButton(
                icon: Icons.settings,
                onPressed: () => openSettings(context, userId: userId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
