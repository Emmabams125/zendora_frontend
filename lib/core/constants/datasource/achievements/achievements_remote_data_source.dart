import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/achievement_model.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';

abstract class AchievementsRemoteDataSource {
  Future<Either<AppError, AchievementsListModel>> getAll();

  Future<Either<AppError, List<AchievementModel>>> getMine();
}
