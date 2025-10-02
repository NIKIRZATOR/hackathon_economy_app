import 'dart:convert';
import 'package:hackathon_economy_app/features/tasks/service/read_local_storage.dart';

import '../service/coin_ledger.dart';
import '../service/level_cache.dart';
import '../model/user_events.dart';
import '../service/local_coins_inventory.dart';


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

  Future<UserLite?> readUserLite() async {
    for (final key in LsKeys.authCandidates) {
      final map = await LS.I.readJson(key);
      if (map == null) continue;
      final id  = map['user_id'];
      final uId = (id is int) ? id : int.tryParse('$id');
      if (uId == null) continue;

      final lvl = map['user_lvl'];
      final xp  = map['user_xp'];
      final userLvl = (lvl is int) ? lvl : int.tryParse('$lvl') ?? 1;
      final userXp  = (xp  is int) ? xp  : int.tryParse('$xp')  ?? 0;
      return UserLite(id: uId, level: userLvl, xp: userXp, rawKey: key);
    }
    return null;
  }

  Future<void> _writeUserLevelXp(UserLite u) async {
    final map = await LS.I.readJson(u.rawKey) ?? {};
    map['user_lvl'] = u.level;
    map['user_xp']  = u.xp;
    await LS.I.write(u.rawKey, jsonEncode(map));
  }

  Future<void> pingXpLevel() async {
    final u = await readUserLite();
    if (u != null) {
      final req = await LevelsCache.I.requiredXpFor(u.level);
      UserEvents.I.emitXpLevel(UserXpLevel(u.level, u.xp, req));
    }
  }

  /// Начисляет XP и, если достигнут порог, повышает уровень.
  /// При повышении уровня начисляет монеты за завершённый уровень (reward.coins).
  Future<UserLite?> addXpAndMaybeLevelUp(int add) async {
    final u = await readUserLite();
    if (u == null) return null;

    final reqNow = await LevelsCache.I.requiredXpFor(u.level);

    int newXp = (u.xp + add);
    int newLvl = u.level;
    bool leveledUp = false;

    if (newXp >= reqNow) {
      // уровень повышен — сначала запомним «завершённый уровень»
      final completedLevel = u.level;
      newLvl += 1;
      newXp = 0;
      leveledUp = true;

      // Награда за завершённый уровень
      final infoCompleted = await LevelsCache.I.levelInfo(completedLevel);
      final rewardCoins = infoCompleted.rewardCoins;
      if (rewardCoins > 0) {
        // обновим инвентарь и сообщим дельту
        await CoinLedger.I.add(u.id, rewardCoins);
      }
    }

    final updated = u.copy(level: newLvl, xp: newXp);
    await _writeUserLevelXp(updated);

    // эмитим актуальные requiredXp (для нового уровня, если апнулись)
    final reqEmit = await LevelsCache.I.requiredXpFor(updated.level);
    UserEvents.I.emitXpLevel(UserXpLevel(updated.level, updated.xp, reqEmit));
    return updated;
  }
}
