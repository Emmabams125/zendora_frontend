class TrackProgressModel {
  final int completedSets;
  final int percent;

  TrackProgressModel({required this.completedSets, required this.percent});

  factory TrackProgressModel.fromJson(Map<String, dynamic> json) {
    return TrackProgressModel(
      completedSets: json['completedSets'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
    );
  }
}

class LearnTrackModel {
  final int id;
  final String title;
  final String? subtitle;
  final String level;
  final String? imageUrl;
  final int estimatedMinutes;
  final int totalSets;
  final TrackProgressModel? progress;

  LearnTrackModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.level,
    this.imageUrl,
    required this.estimatedMinutes,
    required this.totalSets,
    this.progress,
  });

  factory LearnTrackModel.fromJson(Map<String, dynamic> json) {
    return LearnTrackModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      level: json['level'] as String? ?? 'ALL',
      imageUrl: json['imageUrl'] as String?,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      totalSets: json['totalSets'] as int? ?? 0,
      progress: json['progress'] != null
          ? TrackProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
    );
  }

  static List<LearnTrackModel> listFromJson(dynamic json) {
    final list = (json as Map<String, dynamic>)['tracks'] as List? ?? [];
    return list.map((e) => LearnTrackModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class LearnSetSummary {
  final int id;
  final String title;
  final int order;
  final int questionCount;

  LearnSetSummary({
    required this.id,
    required this.title,
    required this.order,
    required this.questionCount,
  });

  factory LearnSetSummary.fromJson(Map<String, dynamic> json) {
    return LearnSetSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      questionCount: json['questionCount'] as int? ?? 0,
    );
  }
}

class LearnTrackDetailModel {
  final int id;
  final String title;
  final String? subtitle;
  final String level;
  final String? imageUrl;
  final int estimatedMinutes;
  final TrackProgressModel? progress;
  final List<LearnSetSummary> sets;

  LearnTrackDetailModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.level,
    this.imageUrl,
    required this.estimatedMinutes,
    this.progress,
    required this.sets,
  });

  factory LearnTrackDetailModel.fromJson(Map<String, dynamic> json) {
    return LearnTrackDetailModel(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      level: json['level'] as String? ?? 'ALL',
      imageUrl: json['imageUrl'] as String?,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
      progress: json['progress'] != null
          ? TrackProgressModel.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      sets: ((json['sets'] as List?) ?? [])
          .map((e) => LearnSetSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
