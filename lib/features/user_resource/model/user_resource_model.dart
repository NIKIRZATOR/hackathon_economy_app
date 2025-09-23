class UserResource { //  склад/кошелек
  final int idUser;
  final int idResource;
  final num amount;

  UserResource({
    required this.idUser,
    required this.idResource,
    required this.amount,
  });

  factory UserResource.fromJson(Map<String, dynamic> json) => UserResource(
    idUser: json['id_user'],
    idResource: json['id_resource'],
    amount: (json['amount'] ?? 0),
  );

  Map<String, dynamic> toJson() => {
    'id_user': idUser,
    'id_resource': idResource,
    'amount': amount,
  };
}
