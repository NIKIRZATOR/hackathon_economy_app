import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';

/// Открыть экран/диалог уровня (пока заглушка)
void openLevelInfo(BuildContext context, {required int userId, required int level}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Открыть уровень: userId=$userId, lvl=$level')),
  );
}

/// Открыть настройки
Future<void> openSettings(BuildContext context, {required int userId}) async {
  final audio = AudioManager();
  double musicVol = audio.musicVolume;
  double sfxVol = audio.sfxVolume;

  await showDialogWithSound(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Настройки'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Громкость музыки'),
                Slider(
                  value: musicVol,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: musicVol.toStringAsFixed(1),
                  onChanged: (v) {
                    setState(() => musicVol = v);
                    audio.setMusicVolume(v);
                  },
                ),
                const Text('Громкость эффектов'),
                Slider(
                  value: sfxVol,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: sfxVol.toStringAsFixed(1),
                  onChanged: (v) {
                    setState(() => sfxVol = v);
                    audio.setSfxVolume(v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          );
        },
      );
    },
  );
}
