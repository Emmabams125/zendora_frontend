import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/gtq_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class GtqRemoteDataSourceImpl extends GtqRemoteDataSource {
  final ApiService apiService;

  GtqRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, List<GtqQuestionModel>>> getQuestions({
    String sport = 'football',
    String? categoryType,
    int? entityId,
    int? trackSetId,
    int count = 15,
  }) {
    return apiService.makeRequest(
      url: '/gtq/questions',
      method: HttpMethod.get,
      queryParams: {
        'sport': sport,
        if (categoryType != null) 'categoryType': categoryType,
        if (entityId != null) 'entityId': entityId,
        if (trackSetId != null) 'trackSetId': trackSetId,
        'count': count,
      },
      fromJson: (json) => GtqQuestionModel.listFromJson(json),
    );
  }

  @override
  Future<Either<AppError, GtqAnswerResultModel>> submitAnswer({
    required int questionId,
    required int optionId,
    bool usedHint = false,
    String source = 'GTQ',
  }) {
    return apiService.makeRequest(
      url: '/gtq/answers',
      method: HttpMethod.post,
      data: {
        'questionId': questionId,
        'optionId': optionId,
        'usedHint': usedHint,
        'source': source,
      },
      fromJson: (json) => GtqAnswerResultModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, StreakModel>> getStreak() {
    return apiService.makeRequest(
      url: '/gtq/streak',
      method: HttpMethod.get,
      fromJson: (json) => StreakModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, DailyChallengeModel>> getDailyChallenge() {
    return apiService.makeRequest(
      url: '/gtq/daily-challenge',
      method: HttpMethod.get,
      fromJson: (json) => DailyChallengeModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
