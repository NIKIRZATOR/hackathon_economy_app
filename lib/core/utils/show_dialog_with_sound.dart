import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';

Future<T?> showDialogWithSound<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  // Играть звук один раз при открытии
  AudioManager().playSfx('open_dialog.mp3');

  // Открывать обычный диалог
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: builder,
  );
}
