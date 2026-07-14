import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/best_model.dart';

abstract class BestRemoteDataSource {
  Future<Either<AppError, BestLeaderboardModel>> getLeaderboard({
    String scope = 'GLOBAL',
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<AppError, List<BestCategoryModel>>> getCategories();

  Future<Either<AppError, void>> pickCategory(String type, int entityId);

  Future<Either<AppError, EntityLeaderboardModel>> getEntityLeaderboard(
    int entityId, {
    int page = 1,
    int pageSize = 20,
  });
}
