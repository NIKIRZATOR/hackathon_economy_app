// import 'package:flutter/material.dart';

// // слегка прозрачная блокировка с плашкой по центру.
// class LevelLockOverlay extends StatelessWidget {
//   const LevelLockOverlay({
//     super.key,
//     required this.child,
//     required this.locked,
//     required this.requiredLevel,
//     this.borderRadius = const BorderRadius.all(Radius.circular(10)),
//     this.message,
//     this.onTapLocked,
//     this.darkOpacity = .38,
//     this.cardOpacity = .95,
//   });

//   final Widget child;
//   final bool locked;
//   final int requiredLevel;

//   final BorderRadius borderRadius;
//   final String? message;
//   final VoidCallback? onTapLocked;
//   final double darkOpacity;
//   final double cardOpacity;

//   @override
//   Widget build(BuildContext context) {
//     if (!locked) return child;

//     final theme = Theme.of(context);
//     final text = message ?? 'Доступно с $requiredLevel уровня';

//     return Stack(
//       children: [
//         child,
//         // затемнение + перехват тапа
//         Positioned.fill(
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTap: onTapLocked,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: darkOpacity),
//                 borderRadius: borderRadius,
//               ),
//             ),
//           ),
//         ),
//         // центральная плашка
//         Positioned.fill(
//           child: Center(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha:cardOpacity),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.black.withValues(alpha:.08)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.lock, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     text,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/ui/StarButton.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';



// слегка прозрачная блокировка с плашкой по центру.
class LevelLockOverlay extends StatelessWidget {
  const LevelLockOverlay({
    super.key,
    required this.child,
    required this.locked,
    required this.requiredLevel,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.message,
    this.onTapLocked,
    this.darkOpacity = .38,
    this.cardOpacity = .95,
  });

  final Widget child;
  final bool locked;
  final int requiredLevel;

  final BorderRadius borderRadius;
  final String? message;
  final VoidCallback? onTapLocked;
  final double darkOpacity;
  final double cardOpacity;

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;

    final theme = Theme.of(context);
    final text = message ?? 'Доступно с $requiredLevel уровня';

    return Stack(
      children: [
        child,
        // затемнение + перехват тапа
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapLocked,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: darkOpacity),
                borderRadius: borderRadius,
              ),
              child: 
               StarButton(
                  text: '$requiredLevel',
                  assetPath: 'assets/images/star.svg',
                  size: 100,
                  onPressed: () => {AudioManager().playSfx('error.mp3')},
                ),
            ),
          ),
        ),
      ],
    );
  }
}
