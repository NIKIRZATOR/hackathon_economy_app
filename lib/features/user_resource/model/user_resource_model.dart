
import '../../resource/model/resource_model.dart';

class UserResource {
  final int idUserResource;
  final int userId;
  final ResourceItem resource;
  final double amount;

  const UserResource({
    required this.idUserResource,
    required this.userId,
    required this.resource,
    required this.amount,
  });

  UserResource copyWith({double? amount}) =>
      UserResource(idUserResource: idUserResource, userId: userId, resource: resource, amount: amount ?? this.amount);

  // Формат «как с сервера» (joined user/resource)
  factory UserResource.fromApiJson(Map<String, dynamic> j) => UserResource(
    idUserResource: j['idUserResource'] as int,
    userId: (j['user'] as Map)['userId'] as int,
    resource: ResourceItem.fromApiJson(j['resource'] as Map<String, dynamic>),
    amount: (j['amount'] as num).toDouble(),
  );

  // Формат для локального кэша
  Map<String, dynamic> toCacheJson() => {
    'idUserResource': idUserResource,
    'userId': userId,
    'amount': amount,
    'resource': resource.toJson(),
  };

  factory UserResource.fromCacheJson(Map<String, dynamic> j) => UserResource(
    idUserResource: j['idUserResource'] as int,
    userId: j['userId'] as int,
    amount: (j['amount'] as num).toDouble(),
    resource: ResourceItem.fromApiJson(j['resource'] as Map<String, dynamic>),
  );
}
