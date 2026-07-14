class SportModel {
  final int id;
  final String key;
  final String name;
  final String status;
  final int order;

  SportModel({
    required this.id,
    required this.key,
    required this.name,
    required this.status,
    required this.order,
  });

  bool get isActive => status == 'ACTIVE';

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] as int,
      key: json['key'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'SOON',
      order: json['order'] as int? ?? 0,
    );
  }

  static List<SportModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['sports'] as List? ?? [];
    return list.map((e) => SportModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class CategoryModel {
  final int id;
  final String type;
  final String name;
  final int setCount;
  final int entityCount;

  CategoryModel({
    required this.id,
    required this.type,
    required this.name,
    required this.setCount,
    required this.entityCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      setCount: json['setCount'] as int? ?? 0,
      entityCount: json['entityCount'] as int? ?? 0,
    );
  }

  static List<CategoryModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['categories'] as List? ?? [];
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
