import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/auth/auth_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/auth_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class AuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);
  @override
  Future<Either<AppError, AuthModel>> login({
    required String email,
    required String password,
  }) {
    return apiService.makeRequest(
      url: '/auth/login',
      method: HttpMethod.post,
      data: {"email": email, "password": password},
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }

  @override
  Future<Either<AppError, AuthModel>> signUp({
    required String email,
    required String password,
    required String username,
  }) {
    return apiService.makeRequest(
      url: '/auth/register',
      method: HttpMethod.post,
      data: {"email": email, "password": password, "username": username},
      fromJson: (json) => AuthModel.fromJson(json),
    );
  }
}
