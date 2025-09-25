import 'api_service.dart';
import '../models/user_model.dart';

class ApiUser {
  final _dio = ApiClient.I.dio;
  static const _base = '/user';

  Future<UserModel> login(String username, String password) async {
    final r = await _dio.post(
      '$_base/login',
      data: {'username': username, 'password': password},
    );
    return UserModel.fromApiJson(r.data as Map<String, dynamic>);
  }

  Future<UserModel> register({
    required String username,
    required String password,
    required String cityTitle,
  }) async {
    final r = await _dio.post(
      '$_base/register',
      data: {
        'username': username,
        'password': password,
        'cityTitle': cityTitle,
      },
    );
    return UserModel.fromApiJson(r.data as Map<String, dynamic>);
  }

  Future<List<UserModel>> getAllUsers() async {
    final r = await _dio.get(_base);
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map(UserModel.fromApiJson).toList();
  }

  Future<UserModel> getUserById(int id) async {
    final r = await _dio.get('$_base/$id');
    return UserModel.fromApiJson(r.data as Map<String, dynamic>);
  }

  Future<void> updateUser({
    required int id,
    int? userLvl,
    int? userXp,
    DateTime? lastClaimAt,
  }) async {
    final body = <String, dynamic>{
      if (userLvl != null) 'user_lvl': userLvl,
      if (userXp != null) 'user_xp': userXp,
      if (lastClaimAt != null) 'last_claim_at': lastClaimAt.toIso8601String(),
    };
    await _dio.put('$_base/$id', data: body);
  }
}
