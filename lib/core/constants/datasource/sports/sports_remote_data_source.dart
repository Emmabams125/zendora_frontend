import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/core/constants/models/search_result_model.dart';
import 'package:zendora_app/core/constants/models/sport_model.dart';

abstract class SportsRemoteDataSource {
  Future<Either<AppError, List<SportModel>>> getSports();

  Future<Either<AppError, List<CategoryModel>>> getCategories(String sportKey);

  Future<Either<AppError, EntitiesPageModel>> getEntities(
    String sportKey,
    String type, {
    String? q,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<AppError, EntityDetailModel>> getEntity(String slug);

  Future<Either<AppError, SearchResultModel>> search(String q);
}
