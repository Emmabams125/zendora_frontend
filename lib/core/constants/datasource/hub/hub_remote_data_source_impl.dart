import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/hub/hub_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/hub_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class HubRemoteDataSourceImpl extends HubRemoteDataSource {
  final ApiService apiService;

  HubRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, HubModel>> getHub() {
    return apiService.makeRequest(
      url: '/hub',
      method: HttpMethod.get,
      fromJson: (json) => HubModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
