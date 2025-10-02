import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:hackathon_economy_app/core/ui/StarButton.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';
import 'bank_cards_mock.dart';
import 'bank_card_header.dart';

class BankCard extends StatelessWidget {
  const BankCard({
    super.key, 
    required this.data,
    this.isInk = false,
    this.isOpen,
    this.locked = false, 
    });
  
  final BankCardInfo data;
  final bool isInk;
  final bool? isOpen;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opened = isOpen == true;

    final layered = Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _CardBody(data: data, opened: opened),
        ),
        if (locked)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: locked,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.60),
                ),
                  child: StarButton(
                  text: '${data.requiredLevel}',
                  
                  assetPath: 'assets/images/svg/star.svg',
                  size: 100,
                  onPressed: () => {},
                  ),
              ),
            ),
          ),
      ],
    );

      return (isInk)
        ? Ink(
          decoration: BoxDecoration(
            color: data.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 185, minWidth: double.infinity),
            child: layered,
          ),
        )
      : Container(
        decoration: BoxDecoration(
          color: data.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 140, minWidth: double.infinity),
        child: layered,
        ),
    );
  }
}


class _CardBody extends StatelessWidget {
  final BankCardInfo data;
  final bool opened;
  const _CardBody({required this.data,  required this.opened,});
  
  @override
  Widget build(BuildContext context) {
    return Stack (
      children: [
        if (data.bgIcon != null)
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  height: 140,
                  data.bgIcon!,
                  alignment: Alignment.bottomCenter,
                ),
            ),
          ),
        ),
        Column(
          children: [
            BankCardHeader(data: data),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
               child: opened
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          color: data.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(), 
                        shrinkWrap: true,                            
                        padding: EdgeInsets.zero,
                        itemCount: data.features.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 3),
                        itemBuilder: (_, i) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('-', style: TextStyle(color: data.textColor, fontSize: 13, fontWeight: FontWeight.w400, height: 1)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data.features[i],
                                style: TextStyle(color: data.textColor, fontSize: 13, fontWeight: FontWeight.w400, height: 1),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]
                  )

                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Text(
                      'КЭШБЭК \n${data.cashbackRate}% НА',
                      style: TextStyle(
                        color: data.textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Image.asset(
                    data.resourceIcon,
                    width: 80,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SvgPicture.asset(
                'assets/images/svg/mir_logo.svg',
                height: 20,
                colorFilter: ColorFilter.mode(data.textColor, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ],
    );
  }
}



