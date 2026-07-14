class ProgressionModel {
  final int level;
  final int xp;
  final int xpIntoLevel;
  final int xpToNextLevel;
  final int percent;

  ProgressionModel({
    required this.level,
    required this.xp,
    required this.xpIntoLevel,
    required this.xpToNextLevel,
    required this.percent,
  });

  factory ProgressionModel.fromJson(Map<String, dynamic> json) {
    return ProgressionModel(
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpIntoLevel: json['xpIntoLevel'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class StatsTodayModel {
  final int answered;
  final num accuracy;
  final int xpGained;

  StatsTodayModel({required this.answered, required this.accuracy, required this.xpGained});

  factory StatsTodayModel.fromJson(Map<String, dynamic> json) {
    return StatsTodayModel(
      answered: json['answered'] as int? ?? 0,
      accuracy: json['accuracy'] as num? ?? 0,
      xpGained: json['xpGained'] as int? ?? 0,
    );
  }
}

class StatsMeModel {
  final int answered;
  final int correct;
  final num accuracy;
  final int currentStreak;
  final int longestStreak;
  final ProgressionModel progression;

  StatsMeModel({
    required this.answered,
    required this.correct,
    required this.accuracy,
    required this.currentStreak,
    required this.longestStreak,
    required this.progression,
  });

  factory StatsMeModel.fromJson(Map<String, dynamic> json) {
    return StatsMeModel(
      answered: json['answered'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      accuracy: json['accuracy'] as num? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      progression: ProgressionModel.fromJson(
        json['progression'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
