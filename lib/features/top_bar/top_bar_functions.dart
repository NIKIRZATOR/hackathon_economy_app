import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';
import 'package:hackathon_economy_app/features/profile/profile_dialog.dart';

/// Открыть «Профиль»
Future<void> openLevelInfo(
    BuildContext context, {
      required int userId,
      required int level,
      String? username,
      String? cityTitle,
      double? hostWidth,     // ← добавлено
      double? hostHeight,    // ← добавлено
    }) async {
  final name = (username == null || username.trim().isEmpty) ? '—' : username;
  final city = (cityTitle == null || cityTitle.trim().isEmpty) ? '—' : cityTitle;

  await showDialogWithSound(
    context: context,
    barrierDismissible: true,
    builder: (_) => ProfileDialog(
      username: name,
      cityTitle: city,
      level: level,
      maxWidthHint: hostWidth,    // ← ограничим ширину рамкой телефона
      maxHeightHint: hostHeight,  // ← и высоту
      onOpenMapInfo: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Открыть раздел: «Всё о карте»')),
        );
      },
    ),
  );
}

/// Открыть настройки (без изменений)
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
