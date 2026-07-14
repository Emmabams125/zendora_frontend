import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/achievements/achievements_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/achievement_model.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class AchievementsRemoteDataSourceImpl extends AchievementsRemoteDataSource {
  final ApiService apiService;

  AchievementsRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, AchievementsListModel>> getAll() {
    return apiService.makeRequest(
      url: '/achievements',
      method: HttpMethod.get,
      fromJson: (json) => AchievementsListModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, List<AchievementModel>>> getMine() {
    return apiService.makeRequest(
      url: '/achievements/me',
      method: HttpMethod.get,
      fromJson: (json) {
        final list = (json as Map<String, dynamic>)['achievements'] as List? ?? [];
        return list.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }
}
