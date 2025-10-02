import 'dart:convert';
import 'read_local_storage.dart';
import '../model/user_events.dart';

class CoinLedger {
  CoinLedger._();

  static final CoinLedger I = CoinLedger._();

  Future<void> _chain = Future.value();

  Future<int> add(int userId, int delta) {
    int resultingAmount = 0; // сюда запишем новое значение баланса

    _chain = _chain.then((_) async {
      final key = LsKeys.userInventory(userId);
      final list = await LS.I.readJsonList(key) ?? <dynamic>[];

      int? idx;
      int coins = 0;

      for (var i = 0; i < list.length; i++) {
        final it = list[i];
        if (it is Map && it['resource'] is Map) {
          final res = it['resource'] as Map;
          if (res['idResource'] == 1) {
            idx = i;
            final amt = it['amount'];
            coins = (amt is int) ? amt : int.tryParse('$amt') ?? 0;
            break;
          }
        }
      }

      final newAmount = (coins + delta).clamp(0, 1 << 31);
      resultingAmount = newAmount;

      if (idx != null) {
        final it = (list[idx!] as Map).cast<String, dynamic>();
        it['amount'] = newAmount;
        list[idx!] = it;
      } else {
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
            "imagePath": "assets/images/resources/coin.png",
          },
        });
      }

      await LS.I.write(key, jsonEncode(list));
      UserEvents.I.emitCoinsDelta(delta);
    });
    return _chain.then((_) => resultingAmount);
  }
}
