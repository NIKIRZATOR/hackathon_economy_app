import 'dart:convert';
import 'read_local_storage.dart';

class LocalInventory {
  static Future<int> addCoins(int userId, int delta) async {
    final key = LsKeys.userInventory(userId);
    final list = await LS.I.readJsonList(key) ?? <dynamic>[];

    int? coinsIndex;
    int coins = 0;

    for (var i = 0; i < list.length; i++) {
      final it = list[i];
      if (it is Map && it['resource'] is Map) {
        final res = it['resource'] as Map;
        if (res['idResource'] == 1) {
          coinsIndex = i;
          final amt = it['amount'];
          coins = (amt is int) ? amt : int.tryParse('$amt') ?? 0;
          break;
        }
      }
    }

    final newAmount = coins + delta;

    if (coinsIndex != null) {
      final it = (list[coinsIndex] as Map).cast<String, dynamic>();
      it['amount'] = newAmount;
      list[coinsIndex!] = it;
    } else {
      // если записи нет — создаём минимально совместимую
      list.add({
        "idUserResource": 0,
        "userId": userId,
        "amount": newAmount,
        "resource": {
          "idResource": 1,
          "title": "Монета",
          "resourceCost": 1,
          "code": "coins",
          "isCurrency": true,
          "isStorable": true,
          "imagePath": "assets/images/resources/coin.png"
        }
      });
    }

    await LS.I.write(key, jsonEncode(list));
    return newAmount;
  }
}
