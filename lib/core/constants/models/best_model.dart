import 'package:zendora_app/core/constants/models/entity_model.dart';

class LeaderboardEntryModel {
  final int rank;
  final int id;
  final String username;
  final String? avatarUrl;
  final String? country;
  final int xp;

  LeaderboardEntryModel({
    required this.rank,
    required this.id,
    required this.username,
    this.avatarUrl,
    this.country,
    required this.xp,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      country: json['country'] as String?,
      xp: json['xp'] as int? ?? 0,
    );
  }
}

class YourPositionModel {
  final int rank;
  final int xp;
  final int? totalPlayers;

  YourPositionModel({required this.rank, required this.xp, this.totalPlayers});

  factory YourPositionModel.fromJson(Map<String, dynamic> json) {
    return YourPositionModel(
      rank: json['rank'] as int,
      xp: json['xp'] as int? ?? 0,
      totalPlayers: json['totalPlayers'] as int?,
    );
  }
}

class BestLeaderboardModel {
  final String scope;
  final int page;
  final int pageSize;
  final int total;
  final YourPositionModel? yourPosition;
  final List<LeaderboardEntryModel> leaderboard;

  BestLeaderboardModel({
    required this.scope,
    required this.page,
    required this.pageSize,
    required this.total,
    this.yourPosition,
    required this.leaderboard,
  });

  factory BestLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return BestLeaderboardModel(
      scope: json['scope'] as String? ?? 'GLOBAL',
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      yourPosition: json['yourPosition'] != null
          ? YourPositionModel.fromJson(json['yourPosition'] as Map<String, dynamic>)
          : null,
      leaderboard: ((json['leaderboard'] as List?) ?? [])
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BestCategoryModel {
  final String type;
  final bool picked;
  final EntitySummaryModel? entity;

  BestCategoryModel({required this.type, required this.picked, this.entity});

  factory BestCategoryModel.fromJson(Map<String, dynamic> json) {
    return BestCategoryModel(
      type: json['type'] as String,
      picked: json['picked'] as bool? ?? false,
      entity: json['entity'] != null
          ? EntitySummaryModel.fromJson(json['entity'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<BestCategoryModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['categories'] as List? ?? [];
    return list.map((e) => BestCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class EntityLeaderboardEntityModel {
  final int id;
  final String name;
  final String slug;

  EntityLeaderboardEntityModel({required this.id, required this.name, required this.slug});

  factory EntityLeaderboardEntityModel.fromJson(Map<String, dynamic> json) {
    return EntityLeaderboardEntityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}

class EntityLeaderboardModel {
  final EntityLeaderboardEntityModel entity;
  final int page;
  final int pageSize;
  final int total;
  final YourPositionModel? yourPosition;
  final List<LeaderboardEntryModel> leaderboard;

  EntityLeaderboardModel({
    required this.entity,
    required this.page,
    required this.pageSize,
    required this.total,
    this.yourPosition,
    required this.leaderboard,
  });

  factory EntityLeaderboardModel.fromJson(Map<String, dynamic> json) {
    return EntityLeaderboardModel(
      entity: EntityLeaderboardEntityModel.fromJson(json['entity'] as Map<String, dynamic>),
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      yourPosition: json['yourPosition'] != null
          ? YourPositionModel.fromJson(json['yourPosition'] as Map<String, dynamic>)
          : null,
      leaderboard: ((json['leaderboard'] as List?) ?? [])
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
