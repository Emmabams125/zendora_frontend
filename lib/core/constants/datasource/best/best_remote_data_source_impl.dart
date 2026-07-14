import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/best_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class BestRemoteDataSourceImpl extends BestRemoteDataSource {
  final ApiService apiService;

  BestRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, BestLeaderboardModel>> getLeaderboard({
    String scope = 'GLOBAL',
    int page = 1,
    int pageSize = 20,
  }) {
    return apiService.makeRequest(
      url: '/best/leaderboard',
      method: HttpMethod.get,
      queryParams: {'scope': scope, 'page': page, 'pageSize': pageSize},
      fromJson: (json) => BestLeaderboardModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, List<BestCategoryModel>>> getCategories() {
    return apiService.makeRequest(
      url: '/best/categories',
      method: HttpMethod.get,
      fromJson: (json) => BestCategoryModel.listFromJson(json),
    );
  }

  @override
  Future<Either<AppError, void>> pickCategory(String type, int entityId) {
    return apiService.makeRequest(
      url: '/best/categories/$type/pick',
      method: HttpMethod.post,
      data: {'entityId': entityId},
      fromJson: (json) {},
    );
  }

  @override
  Future<Either<AppError, EntityLeaderboardModel>> getEntityLeaderboard(
    int entityId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return apiService.makeRequest(
      url: '/best/entities/$entityId/leaderboard',
      method: HttpMethod.get,
      queryParams: {'page': page, 'pageSize': pageSize},
      fromJson: (json) => EntityLeaderboardModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
