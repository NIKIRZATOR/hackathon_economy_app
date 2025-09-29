import '../../../app/services/api_service.dart';
import '../../features/user_resource/model/user_resource_model.dart';

class ApiUserResource {
  final _dio = ApiClient.I.dio;
  static const _base = '/user-resource/by-user';

  // GET /user-resource/by-user/:idUser
  Future<List<UserResource>> getByUser(int userId) async {
    final r = await _dio.get('$_base/$userId');
    final list = (r.data as List).cast<Map<String, dynamic>>();
    return list.map(UserResource.fromApiJson).toList();
  }

  // PUT /user-resource  (по паре userId + resourceId)
  Future<void> updateByPair({
    required int userId,
    required int resourceId,
    required double amount,
  }) async {
    await _dio.put(_base, data: {
      'user': {'userId': userId},
      'resource': {'idResource': resourceId},
      'amount': amount,
    });
  }

  // POST /user-resource
  Future<void> create({
    required int userId,
    required int resourceId,
    required double amount,
  }) async {
    await _dio.post(_base, data: {
      'user': {'userId': userId},
      'resource': {'idResource': resourceId},
      'amount': amount,
    });
  }
}
