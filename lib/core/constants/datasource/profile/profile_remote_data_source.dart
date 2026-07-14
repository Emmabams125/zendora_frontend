import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<Either<AppError, ZcpProfileModel>> getMe();

  // PATCH /profile/me returns a flat profile shape, not the ZcpProfileModel
  // (progression/ranks/performance) shape returned by GET /profile/me — so
  // this only confirms the write succeeded; callers should re-fetch getMe()
  // to refresh the full ZCP card.
  Future<Either<AppError, void>> updateMe({
    String? username,
    String? avatarUrl,
    String? title,
    String? country,
    String? bio,
    int? favoriteSportId,
    int? favoriteClubId,
  });

  Future<Either<AppError, void>> uploadAvatar(File avatarFile);

  Future<Either<AppError, void>> saveOnboarding({
    required int favoriteSportId,
    required List<int> interestEntityIds,
  });

  Future<Either<AppError, ZcpProfileModel>> getPublicProfile(String username);
}
