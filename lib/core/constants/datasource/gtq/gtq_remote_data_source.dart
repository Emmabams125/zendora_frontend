import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/gtq_model.dart';

abstract class GtqRemoteDataSource {
  Future<Either<AppError, List<GtqQuestionModel>>> getQuestions({
    String sport = 'football',
    String? categoryType,
    int? entityId,
    int? trackSetId,
    int count = 15,
  });

  Future<Either<AppError, GtqAnswerResultModel>> submitAnswer({
    required int questionId,
    required int optionId,
    bool usedHint = false,
    String source = 'GTQ',
  });

  Future<Either<AppError, StreakModel>> getStreak();

  Future<Either<AppError, DailyChallengeModel>> getDailyChallenge();
}
