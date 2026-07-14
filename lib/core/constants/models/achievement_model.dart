class AchievementModel {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String? iconKey;
  final bool unlocked;
  final String? unlockedAt;

  AchievementModel({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.iconKey,
    required this.unlocked,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      iconKey: json['iconKey'] as String?,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] as String?,
    );
  }
}

class AchievementsListModel {
  final int unlockedCount;
  final int total;
  final List<AchievementModel> achievements;

  AchievementsListModel({
    required this.unlockedCount,
    required this.total,
    required this.achievements,
  });

  factory AchievementsListModel.fromJson(Map<String, dynamic> json) {
    return AchievementsListModel(
      unlockedCount: json['unlockedCount'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      achievements: ((json['achievements'] as List?) ?? [])
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
