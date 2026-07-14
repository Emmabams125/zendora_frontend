import 'package:zendora_app/core/constants/models/stats_model.dart';

class ProfileRanksModel {
  final int? global;
  final int? country;
  final int? club;

  ProfileRanksModel({this.global, this.country, this.club});

  factory ProfileRanksModel.fromJson(Map<String, dynamic> json) {
    return ProfileRanksModel(
      global: json['global'] as int?,
      country: json['country'] as int?,
      club: json['club'] as int?,
    );
  }
}

class MasteryInfoModel {
  final int unlocked;
  final int total;

  MasteryInfoModel({required this.unlocked, required this.total});

  factory MasteryInfoModel.fromJson(Map<String, dynamic> json) {
    return MasteryInfoModel(
      unlocked: json['unlocked'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class ProfilePerformanceModel {
  final num accuracy;
  final int answered;
  final int currentStreak;
  final int longestStreak;
  final MasteryInfoModel mastery;

  ProfilePerformanceModel({
    required this.accuracy,
    required this.answered,
    required this.currentStreak,
    required this.longestStreak,
    required this.mastery,
  });

  factory ProfilePerformanceModel.fromJson(Map<String, dynamic> json) {
    return ProfilePerformanceModel(
      accuracy: json['accuracy'] as num? ?? 0,
      answered: json['answered'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      mastery: MasteryInfoModel.fromJson(json['mastery'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MasteryCategoryModel {
  final String title;
  final String level;
  final double progress;

  MasteryCategoryModel({required this.title, required this.level, required this.progress});

  factory MasteryCategoryModel.fromJson(Map<String, dynamic> json) {
    final percent = json['progress'] ?? json['percent'];
    return MasteryCategoryModel(
      title: (json['title'] ?? json['category'] ?? json['name'] ?? '') as String,
      level: (json['level'] ?? json['tier'] ?? '') as String,
      progress: percent is num
          ? (percent > 1 ? (percent / 100) : percent).clamp(0, 1).toDouble()
          : 0,
    );
  }
}

class AchievementsInfoModel {
  final int unlocked;
  final int total;

  AchievementsInfoModel({required this.unlocked, required this.total});

  factory AchievementsInfoModel.fromJson(Map<String, dynamic> json) {
    return AchievementsInfoModel(
      unlocked: json['unlocked'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class ZcpProfileModel {
  final String znd;
  final String username;
  final String? title;
  final String? country;
  final String? bio;
  final String? avatarUrl;
  final String joinedAt;
  final Map<String, dynamic>? favoriteSport;
  final Map<String, dynamic>? favoriteClub;
  final ProgressionModel progression;
  final ProfileRanksModel ranks;
  final ProfilePerformanceModel? performance;
  final List<MasteryCategoryModel> masteryCategories;
  final AchievementsInfoModel? achievements;
  final int? currentStreak;

  ZcpProfileModel({
    required this.znd,
    required this.username,
    this.title,
    this.country,
    this.bio,
    this.avatarUrl,
    required this.joinedAt,
    this.favoriteSport,
    this.favoriteClub,
    required this.progression,
    required this.ranks,
    this.performance,
    required this.masteryCategories,
    this.achievements,
    this.currentStreak,
  });

  factory ZcpProfileModel.fromJson(Map<String, dynamic> json) {
    return ZcpProfileModel(
      znd: json['znd'] as String? ?? '',
      username: json['username'] as String? ?? '',
      title: json['title'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: json['joinedAt'] as String? ?? '',
      favoriteSport: json['favoriteSport'] as Map<String, dynamic>?,
      favoriteClub: json['favoriteClub'] as Map<String, dynamic>?,
      progression: ProgressionModel.fromJson(
        json['progression'] as Map<String, dynamic>? ?? {},
      ),
      ranks: ProfileRanksModel.fromJson(json['ranks'] as Map<String, dynamic>? ?? {}),
      performance: json['performance'] != null
          ? ProfilePerformanceModel.fromJson(json['performance'] as Map<String, dynamic>)
          : null,
      masteryCategories: ((json['masteryCategories'] as List?) ?? [])
          .map((e) => MasteryCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      achievements: json['achievements'] != null
          ? AchievementsInfoModel.fromJson(json['achievements'] as Map<String, dynamic>)
          : null,
      currentStreak: json['currentStreak'] as int?,
    );
  }
}
