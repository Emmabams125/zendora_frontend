import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/gtq_model.dart';
import 'package:zendora_app/core/constants/models/learn_model.dart';

abstract class LearnRemoteDataSource {
  Future<Either<AppError, List<LearnTrackModel>>> getTracks({String sport = 'football'});

  Future<Either<AppError, LearnTrackDetailModel>> getTrackDetail(int id);

  Future<Either<AppError, TrackProgressModel>> updateProgress(int id, int completedSets);

  Future<Either<AppError, List<GtqQuestionModel>>> getSetQuestions(int setId);
}
