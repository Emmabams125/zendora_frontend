import 'package:dartz/dartz.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source.dart';
import 'package:zendora_app/core/constants/enums/http_method.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/gtq_model.dart';
import 'package:zendora_app/core/constants/models/learn_model.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';

class LearnRemoteDataSourceImpl extends LearnRemoteDataSource {
  final ApiService apiService;

  LearnRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<AppError, List<LearnTrackModel>>> getTracks({String sport = 'football'}) {
    return apiService.makeRequest(
      url: '/learn/tracks',
      method: HttpMethod.get,
      queryParams: {'sport': sport},
      fromJson: (json) => LearnTrackModel.listFromJson(json),
    );
  }

  @override
  Future<Either<AppError, LearnTrackDetailModel>> getTrackDetail(int id) {
    return apiService.makeRequest(
      url: '/learn/tracks/$id',
      method: HttpMethod.get,
      fromJson: (json) => LearnTrackDetailModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<AppError, TrackProgressModel>> updateProgress(int id, int completedSets) {
    return apiService.makeRequest(
      url: '/learn/tracks/$id/progress',
      method: HttpMethod.post,
      data: {'completedSets': completedSets},
      fromJson: (json) => TrackProgressModel.fromJson(
        (json as Map<String, dynamic>)['progress'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<AppError, List<GtqQuestionModel>>> getSetQuestions(int setId) {
    return apiService.makeRequest(
      url: '/learn/sets/$setId/questions',
      method: HttpMethod.get,
      fromJson: (json) => GtqQuestionModel.listFromJson(json),
    );
  }
}
