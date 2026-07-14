import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/hub_model.dart';

abstract class HubRemoteDataSource {
  Future<Either<AppError, HubModel>> getHub();
}
