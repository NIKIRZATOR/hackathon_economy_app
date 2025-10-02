import 'dart:convert';
import 'package:hackathon_economy_app/features/tasks/service/read_local_storage.dart';

import '../service/level_cache.dart';
import '../model/user_events.dart';

class UserLite {
  final int id;
  final int level;
  final int xp;
  final String rawKey;

  UserLite({required this.id, required this.level, required this.xp, required this.rawKey});

  UserLite copy({int? level, int? xp}) =>
      UserLite(id: id, level: level ?? this.level, xp: xp ?? this.xp, rawKey: rawKey);
}

class UserService {
  UserService._();
  static final UserService I = UserService._();

  //  Первая валидную запись auth
  Future<UserLite?> readUserLite() async {
    for (final key in LsKeys.authCandidates) {
      final map = await LS.I.readJson(key);
      if (map == null) continue;

      final lvl = map['user_lvl'];
      final xp  = map['user_xp'];
      final id  = map['user_id'];
      final uId = (id is int) ? id : int.tryParse('$id');
      if (uId == null) continue;

      final userLvl = (lvl is int) ? lvl : int.tryParse('$lvl') ?? 1;
      final userXp  = (xp  is int) ? xp  : int.tryParse('$xp')  ?? 0;

      return UserLite(id: uId, level: userLvl, xp: userXp, rawKey: key);
    }
    return null;
  }

  // перезапись только поля уровня/опыта в исходный JSON
  Future<void> writeUserLevelXp(UserLite u) async {
    final map = await LS.I.readJson(u.rawKey) ?? {};
    map['user_lvl'] = u.level;
    map['user_xp']  = u.xp;
    await LS.I.write(u.rawKey, jsonEncode(map));
  }

  // Обновить XP и переход уровня.
  // при достижении/перерасходе — уровень +1, XP в 0.
  Future<UserLite?> addXpAndMaybeLevelUp(int add) async {
    final u = await readUserLite();
    if (u == null) return null;

    final reqNow = await LevelsCache.I.requiredXpFor(u.level);

    int newXp = (u.xp + add).clamp(0, 1<<30);
    int newLvl = u.level;

    if (newXp >= reqNow) {
      newLvl += 1;
      newXp = 0;
    }

    final updated = u.copy(level: newLvl, xp: newXp);
    await writeUserLevelXp(updated);

    // для эмита  requiredXp на !АКТУАЛЬНЫЙ! уровень
    final reqEmit = await LevelsCache.I.requiredXpFor(updated.level);
    UserEvents.I.emitXpLevel(UserXpLevel(updated.level, updated.xp, reqEmit));
    return updated;
  }

  // пинг текущих значений (для отрисовки топбара)
  Future<void> pingXpLevel() async {
    final u = await readUserLite();
    if (u != null) {
      final req = await LevelsCache.I.requiredXpFor(u.level);
      UserEvents.I.emitXpLevel(UserXpLevel(u.level, u.xp, req));
    }
  }




}
