import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/profile_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class ProfileRemoteDataSourceImpl extends ProfileRemoteDataSource {
  final ApiService apiService;

  ProfileRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, ZcpProfileModel>> getMe() {
    return apiService.makeRequest(
      url: '/profile/me',
      method: HttpMethod.get,
      fromJson: (json) => ZcpProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, void>> updateMe({
    String? username,
    String? avatarUrl,
    String? title,
    String? country,
    String? bio,
    int? favoriteSportId,
    int? favoriteClubId,
  }) {
    return apiService.makeRequest(
      url: '/profile/me',
      method: HttpMethod.patch,
      data: {
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (title != null) 'title': title,
        if (country != null) 'country': country,
        if (bio != null) 'bio': bio,
        if (favoriteSportId != null) 'favoriteSportId': favoriteSportId,
        if (favoriteClubId != null) 'favoriteClubId': favoriteClubId,
      },
      fromJson: (json) {},
    );
  }

  @override
  Future<Either<AppError, void>> uploadAvatar(File avatarFile) {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromFileSync(avatarFile.path),
    });
    return apiService.uploadFile(
      url: '/profile/me/avatar',
      formData: formData,
      fromJson: (json) {},
    );
  }

  @override
  Future<Either<AppError, void>> saveOnboarding({
    required int favoriteSportId,
    required List<int> interestEntityIds,
  }) {
    return apiService.makeRequest(
      url: '/profile/me/onboarding',
      method: HttpMethod.post,
      data: {
        'favoriteSportId': favoriteSportId,
        'interestEntityIds': interestEntityIds,
      },
      fromJson: (json) {},
    );
  }

  @override
  Future<Either<AppError, ZcpProfileModel>> getPublicProfile(String username) {
    return apiService.makeRequest(
      url: '/profile/$username',
      method: HttpMethod.get,
      fromJson: (json) => ZcpProfileModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
