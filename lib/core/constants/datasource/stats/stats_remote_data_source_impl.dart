import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/stats/stats_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/stats_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class StatsRemoteDataSourceImpl extends StatsRemoteDataSource {
  final ApiService apiService;

  StatsRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, StatsTodayModel>> getToday() {
    return apiService.makeRequest(
      url: '/stats/today',
      method: HttpMethod.get,
      fromJson: (json) => StatsTodayModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, StatsMeModel>> getMe() {
    return apiService.makeRequest(
      url: '/stats/me',
      method: HttpMethod.get,
      fromJson: (json) => StatsMeModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
