import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/stats_model.dart';

abstract class StatsRemoteDataSource {
  Future<Either<AppError, StatsTodayModel>> getToday();

  Future<Either<AppError, StatsMeModel>> getMe();
}
