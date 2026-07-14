import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<AppError, AuthModel>> login({
    required String email,
    required String password,
  });

  Future<Either<AppError, AuthModel>> signUp({
    required String email,
    required String password,
    required String username,
  });
}
