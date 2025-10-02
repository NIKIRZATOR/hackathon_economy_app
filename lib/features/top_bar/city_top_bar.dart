import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/app/models/user_model.dart';
import 'package:hackathon_economy_app/core/ui/MainIconButton.dart';
import 'package:hackathon_economy_app/core/ui/StarButton.dart';
import '../../core/ui/OvalFOrCoins.dart';
import '../../core/ui/xp_progress_oval.dart';
import '../tasks/model/user_events.dart';
import 'top_bar_functions.dart';

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
    this.xpLevelStream,
    this.requiredXp = 1250,
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
  final Stream<UserXpLevel>? xpLevelStream;
  final int requiredXp;

  @override
  Widget build(BuildContext context) {

    // если стрима нет — рисуем по старым пропсам
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            StarButton(
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
            const SizedBox(width: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  XpProgressOval(
                    currentXP: xpCount,
                    totalNeedXP: requiredXp,
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
        MainIconButton(
          icon: Icons.settings,
          onPressed: () => openSettings(context, userId: userId),
        ),
      ],
    );

    if (xpLevelStream == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 22, left: 60, right: 60),
        child: SizedBox(height: screenHeight * 0.09 + 10, child: content),
      );
    }

    //  перекрашиваем только значения уровня/опыта
    return Padding(
      padding: const EdgeInsets.only(top: 22, left: 60, right: 60),
      child: SizedBox(
        height: screenHeight * 0.09 + 10,
        child: StreamBuilder<UserXpLevel>(
          stream: xpLevelStream,
          initialData: UserXpLevel(userLvl, xpCount, requiredXp),
          builder: (context, snap) {
            final v = snap.data ?? UserXpLevel(userLvl, xpCount, requiredXp);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    StarButton(
                      text: '${v.level}',
                      assetPath: 'assets/images/svg/star.svg',
                      size: 70,
                      onPressed: () => openLevelInfo(
                        context,
                        userId: userId,
                        level: v.level,
                        username: user?.username,
                        cityTitle: cityTitle,
                        hostWidth: screenWidth,
                        hostHeight: screenHeight,
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
                            currentXP: v.xp,
                            totalNeedXP: v.required,
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
                MainIconButton(
                  icon: Icons.settings,
                  onPressed: () => openSettings(context, userId: userId),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
