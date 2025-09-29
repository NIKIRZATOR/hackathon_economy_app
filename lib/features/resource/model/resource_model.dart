class ResourceItem {
  final int idResource;
  final String title;
  final double resourceCost;
  final String code;
  final bool isCurrency;
  final bool isStorable;
  final String? imagePath;

  const ResourceItem({
    required this.idResource,
    required this.title,
    required this.resourceCost,
    required this.code,
    required this.isCurrency,
    required this.isStorable,
    this.imagePath,
  });

  factory ResourceItem.fromApiJson(Map<String, dynamic> j) => ResourceItem(
    idResource: j['idResource'] as int,
    title: j['title'] as String,
    resourceCost: (j['resourceCost'] as num).toDouble(),
    code: j['code'] as String,
    isCurrency: j['isCurrency'] as bool,
    isStorable: j['isStorable'] as bool,
    imagePath: j['imagePath'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'idResource': idResource,
    'title': title,
    'resourceCost': resourceCost,
    'code': code,
    'isCurrency': isCurrency,
    'isStorable': isStorable,
    'imagePath': imagePath,
  };
}
