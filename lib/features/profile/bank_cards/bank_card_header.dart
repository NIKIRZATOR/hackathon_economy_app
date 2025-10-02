import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'bank_cards_mock.dart';

class BankCardHeader extends StatelessWidget {
  final BankCardInfo data;
  const BankCardHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    switch (data.id) {
      case 2:
        return Row(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/svg/gazprombank_logo.svg',
              width: 26, height: 26,
              colorFilter: ColorFilter.mode(data.textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 5),
            Text(
              'ГАЗПРОМБАНК',
              style: TextStyle(
                color: data.textColor, fontSize: 16, fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/images/svg/gazpromneft_logo.svg',
              height: 30,
              colorFilter: ColorFilter.mode(data.textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Icon(Icons.info, color: data.infoColor),
          ],
        );
      case 3:
        return Row(
          children: [
            Text(
              'SUPREME',
              style: TextStyle(
                color: data.infoColor, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 4,
              ),
            ),
            const Spacer(),
            Icon(Icons.info, color: data.infoColor),
          ],
        );
      default:
        return Row(
          children: [
            SvgPicture.asset(
              'assets/images/svg/gazprombank_logo.svg',
              width: 26, height: 26,
              colorFilter: ColorFilter.mode(data.textColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 5),
            Text(
              'ГАЗПРОМБАНК',
              style: TextStyle(
                color: data.textColor, fontSize: 16, fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Icon(Icons.info, color: data.infoColor),
          ],
        );
    }
  }
}
