class GtqOptionModel {
  final int id;
  final String label;
  final String text;

  GtqOptionModel({required this.id, required this.label, required this.text});

  factory GtqOptionModel.fromJson(Map<String, dynamic> json) {
    return GtqOptionModel(
      id: json['id'] as int,
      label: json['label'] as String,
      text: json['text'] as String,
    );
  }
}

class GtqQuestionModel {
  final int id;
  final int? sportId;
  final int? categoryId;
  final int? entityId;
  final int? trackSetId;
  final String text;
  final String difficulty;
  final int xpReward;
  final String? hintText;
  final int hintCost;
  final String? explanation;
  final int order;
  final List<GtqOptionModel> options;

  GtqQuestionModel({
    required this.id,
    this.sportId,
    this.categoryId,
    this.entityId,
    this.trackSetId,
    required this.text,
    required this.difficulty,
    required this.xpReward,
    this.hintText,
    required this.hintCost,
    this.explanation,
    required this.order,
    required this.options,
  });

  factory GtqQuestionModel.fromJson(Map<String, dynamic> json) {
    return GtqQuestionModel(
      id: json['id'] as int,
      sportId: json['sportId'] as int?,
      categoryId: json['categoryId'] as int?,
      entityId: json['entityId'] as int?,
      trackSetId: json['trackSetId'] as int?,
      text: json['text'] as String,
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      xpReward: json['xpReward'] as int? ?? 0,
      hintText: json['hintText'] as String?,
      hintCost: json['hintCost'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      order: json['order'] as int? ?? 0,
      options: ((json['options'] as List?) ?? [])
          .map((e) => GtqOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static List<GtqQuestionModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['questions'] as List? ?? [];
    return list.map((e) => GtqQuestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class GtqStreakInfo {
  final int currentStreak;
  final int longestStreak;

  GtqStreakInfo({required this.currentStreak, required this.longestStreak});

  factory GtqStreakInfo.fromJson(Map<String, dynamic> json) {
    return GtqStreakInfo(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
    );
  }
}

class GtqAnswerResultModel {
  final bool isCorrect;
  final int correctOptionId;
  final String? explanation;
  final int xpAwarded;
  final int combo;
  final GtqStreakInfo streak;
  final int profileXp;

  GtqAnswerResultModel({
    required this.isCorrect,
    required this.correctOptionId,
    this.explanation,
    required this.xpAwarded,
    required this.combo,
    required this.streak,
    required this.profileXp,
  });

  factory GtqAnswerResultModel.fromJson(Map<String, dynamic> json) {
    return GtqAnswerResultModel(
      isCorrect: json['isCorrect'] as bool? ?? false,
      correctOptionId: json['correctOptionId'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      xpAwarded: json['xpAwarded'] as int? ?? 0,
      combo: json['combo'] as int? ?? 0,
      streak: GtqStreakInfo.fromJson(json['streak'] as Map<String, dynamic>? ?? {}),
      profileXp: json['profileXp'] as int? ?? 0,
    );
  }
}

class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final int comboCount;
  final String? lastActiveDate;

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.comboCount,
    this.lastActiveDate,
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      comboCount: json['comboCount'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
    );
  }
}

class DailyChallengeProgress {
  final bool completed;
  final int correctCount;
  final int xpEarned;

  DailyChallengeProgress({
    required this.completed,
    required this.correctCount,
    required this.xpEarned,
  });

  factory DailyChallengeProgress.fromJson(Map<String, dynamic> json) {
    return DailyChallengeProgress(
      completed: json['completed'] as bool? ?? false,
      correctCount: json['correctCount'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }
}

class DailyChallengeModel {
  final int id;
  final String? date;
  final String title;
  final String? description;
  final String? imageUrl;
  final String difficulty;
  final int xpReward;
  final int questionCount;
  final DailyChallengeProgress progress;
  final List<GtqQuestionModel> questions;

  DailyChallengeModel({
    required this.id,
    this.date,
    required this.title,
    this.description,
    this.imageUrl,
    required this.difficulty,
    required this.xpReward,
    required this.questionCount,
    required this.progress,
    required this.questions,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as int,
      date: json['date'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      difficulty: json['difficulty'] as String? ?? 'MEDIUM',
      xpReward: json['xpReward'] as int? ?? 0,
      questionCount: json['questionCount'] as int? ?? 0,
      progress: DailyChallengeProgress.fromJson(
        json['progress'] as Map<String, dynamic>? ?? {},
      ),
      questions: ((json['questions'] as List?) ?? [])
          .map((e) => GtqQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
