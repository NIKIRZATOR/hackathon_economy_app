class ResourceItem {
  final int? idItem;
  final String code;
  final String title;
  final bool isCurrency;
  final bool isStorable;

  ResourceItem({
    this.idItem,
    required this.code,
    required this.title,
    required this.isCurrency,
    required this.isStorable,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) => ResourceItem(
    idItem: json['id_item'],
    code: json['code'] ?? '',
    title: json['title'] ?? '',
    isCurrency: json['is_currency'] ?? false,
    isStorable: json['is_storable'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    if (idItem != null) 'id_item': idItem,
    'code': code,
    'title': title,
    'is_currency': isCurrency,
    'is_storable': isStorable,
  };
}
