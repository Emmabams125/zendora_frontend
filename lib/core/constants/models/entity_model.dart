class EntitySummaryModel {
  final int id;
  final int? sportId;
  final int? categoryId;
  final String name;
  final String slug;
  final String? country;
  final String? imageUrl;
  final dynamic meta;

  EntitySummaryModel({
    required this.id,
    this.sportId,
    this.categoryId,
    required this.name,
    required this.slug,
    this.country,
    this.imageUrl,
    this.meta,
  });

  factory EntitySummaryModel.fromJson(Map<String, dynamic> json) {
    return EntitySummaryModel(
      id: json['id'] as int,
      sportId: json['sportId'] as int?,
      categoryId: json['categoryId'] as int?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      country: json['country'] as String?,
      imageUrl: json['imageUrl'] as String?,
      meta: json['meta'],
    );
  }

  static List<EntitySummaryModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['entities'] as List? ?? [];
    return list.map((e) => EntitySummaryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class EntitiesPageModel {
  final int page;
  final int pageSize;
  final int total;
  final List<EntitySummaryModel> entities;

  EntitiesPageModel({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.entities,
  });

  factory EntitiesPageModel.fromJson(Map<String, dynamic> json) {
    return EntitiesPageModel(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      entities: ((json['entities'] as List?) ?? [])
          .map((e) => EntitySummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EntityDetailModel {
  final EntitySummaryModel entity;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? sport;

  EntityDetailModel({required this.entity, this.category, this.sport});

  factory EntityDetailModel.fromJson(Map<String, dynamic> json) {
    final e = json['entity'] as Map<String, dynamic>;
    return EntityDetailModel(
      entity: EntitySummaryModel.fromJson(e),
      category: e['category'] as Map<String, dynamic>?,
      sport: e['sport'] as Map<String, dynamic>?,
    );
  }
}
