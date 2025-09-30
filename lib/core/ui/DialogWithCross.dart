import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/ui/MainIconButton.dart';

class DialogWithCross extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String title;
  final Widget content;

  const DialogWithCross({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: screenWidth - 20,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.8,
          ),
            child: Padding(
            padding: const EdgeInsets.all(9),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 9),
                    child: Stack(
                    alignment: Alignment.center,
                    children: [
                        Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 45, 0),
                        child: Text(
                            title,
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
                ),
                Container(
                    decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: BorderRadius.circular(10),
                    ),
                    child: content,
                ),
                ],
            ),
            ),
        ),
      ),
    );
  }
}

