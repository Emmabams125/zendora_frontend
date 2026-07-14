import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/core/constants/models/search_result_model.dart';
import 'package:zendora_app/core/constants/models/sport_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class SportsRemoteDataSourceImpl extends SportsRemoteDataSource {
  final ApiService apiService;

  SportsRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, List<SportModel>>> getSports() {
    return apiService.makeRequest(
      url: '/sports',
      method: HttpMethod.get,
      fromJson: (json) => SportModel.listFromJson(json),
    );
  }

  @override
  Future<Either<AppError, List<CategoryModel>>> getCategories(String sportKey) {
    return apiService.makeRequest(
      url: '/sports/$sportKey/categories',
      method: HttpMethod.get,
      fromJson: (json) => CategoryModel.listFromJson(json),
    );
  }

  @override
  Future<Either<AppError, EntitiesPageModel>> getEntities(
    String sportKey,
    String type, {
    String? q,
    int page = 1,
    int pageSize = 20,
  }) {
    return apiService.makeRequest(
      url: '/sports/$sportKey/categories/$type/entities',
      method: HttpMethod.get,
      queryParams: {
        if (q != null && q.isNotEmpty) 'q': q,
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (json) => EntitiesPageModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, EntityDetailModel>> getEntity(String slug) {
    return apiService.makeRequest(
      url: '/entities/$slug',
      method: HttpMethod.get,
      fromJson: (json) => EntityDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, SearchResultModel>> search(String q) {
    return apiService.makeRequest(
      url: '/search',
      method: HttpMethod.get,
      queryParams: {'q': q},
      fromJson: (json) => SearchResultModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
