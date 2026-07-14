import 'package:zendora_app/core/constants/models/stats_model.dart';

class HubDailyChallengeModel {
  final int id;
  final String title;
  final String? imageUrl;
  final String difficulty;
  final int questionCount;
  final int xpReward;
  final bool completed;

  HubDailyChallengeModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.difficulty,
    required this.questionCount,
    required this.xpReward,
    required this.completed,
  });

  factory HubDailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return HubDailyChallengeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      questionCount: json['questionCount'] as int? ?? 0,
      xpReward: json['xpReward'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class HubContinueLearningItem {
  final int? trackId;
  final String title;
  final String? tag;
  final double progress;

  HubContinueLearningItem({
    this.trackId,
    required this.title,
    this.tag,
    required this.progress,
  });

  factory HubContinueLearningItem.fromJson(Map<String, dynamic> json) {
    final percent = json['percent'] ?? json['progressPercent'];
    return HubContinueLearningItem(
      trackId: json['trackId'] as int? ?? json['id'] as int?,
      title: (json['title'] ?? json['trackTitle'] ?? '') as String,
      tag: json['tag'] as String? ?? json['subtitle'] as String?,
      progress: percent is num ? (percent / 100).clamp(0, 1).toDouble() : 0,
    );
  }
}

class HubBestModeModel {
  final int? globalRank;
  final int? topPercent;

  HubBestModeModel({this.globalRank, this.topPercent});

  factory HubBestModeModel.fromJson(Map<String, dynamic> json) {
    return HubBestModeModel(
      globalRank: json['globalRank'] as int?,
      topPercent: json['topPercent'] as int?,
    );
  }
}

class HubModel {
  final String username;
  final int currentStreak;
  final ProgressionModel progression;
  final HubDailyChallengeModel? dailyChallenge;
  final List<HubContinueLearningItem> continueLearning;
  final StatsTodayModel today;
  final HubBestModeModel bestMode;

  HubModel({
    required this.username,
    required this.currentStreak,
    required this.progression,
    this.dailyChallenge,
    required this.continueLearning,
    required this.today,
    required this.bestMode,
  });

  factory HubModel.fromJson(Map<String, dynamic> json) {
    return HubModel(
      username: json['username'] as String? ?? '',
      currentStreak: json['currentStreak'] as int? ?? 0,
      progression: ProgressionModel.fromJson(
        json['progression'] as Map<String, dynamic>? ?? {},
      ),
      dailyChallenge: json['dailyChallenge'] != null
          ? HubDailyChallengeModel.fromJson(json['dailyChallenge'] as Map<String, dynamic>)
          : null,
      continueLearning: ((json['continueLearning'] as List?) ?? [])
          .map((e) => HubContinueLearningItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      today: StatsTodayModel.fromJson(json['today'] as Map<String, dynamic>? ?? {}),
      bestMode: HubBestModeModel.fromJson(json['bestMode'] as Map<String, dynamic>? ?? {}),
    );
  }
}
