import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/core/utils/show_dialog_with_sound.dart';
import 'package:hackathon_economy_app/core/services/audio_manager.dart';
import 'package:hackathon_economy_app/features/profile/profile_dialog.dart';

import '../../app/sync/sync_service.dart';

// открыть профиль
Future<void> openLevelInfo(
    BuildContext context, {
      required int userId,
      required int level,
      String? username,
      String? cityTitle,
      double? hostWidth,
      double? hostHeight,
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
      maxWidthHint: hostWidth,    // ограничим ширину рамкой телефона
      maxHeightHint: hostHeight,  // высоту
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
          final theme = Theme.of(context);

          return AlertDialog(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Настройки'),
                const SizedBox(width: 8),
                ValueListenableBuilder<SyncStatus>(
                  valueListenable: SyncService.I.status,
                  builder: (context, st, __) {
                    Color color;
                    IconData icon;
                    String tip;
                    switch (st) {
                      case SyncStatus.syncing:
                        color = theme.colorScheme.outline;        // жёлтый — идёт синк
                        icon = Icons.sync;
                        tip = 'Синхронизация…';
                        break;
                      case SyncStatus.error:
                        color = Colors.red;          // красный — ошибка
                        icon = Icons.error_outline;
                        tip = 'Ошибка синхронизации';
                        break;
                      case SyncStatus.idle:
                      default:
                        color = theme.colorScheme.outline;        // зелёный — всё ок или простой
                        icon = Icons.check_circle;
                        tip = 'Синхронизация завершена';
                    }
                    return Tooltip(
                      message: SyncService.I.lastSyncAt.value == null
                          ? tip
                          : '$tip • ${SyncService.I.lastSyncAt.value}',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Icon(icon, key: ValueKey(st), size: 20, color: color),
                      ),
                    );
                  },
                ),
              ],
            ),
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
