import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/core/constants/models/learn_model.dart';

class SearchResultModel {
  final List<EntitySummaryModel> entities;
  final List<LearnTrackModel> tracks;

  SearchResultModel({required this.entities, required this.tracks});

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      entities: ((json['entities'] as List?) ?? [])
          .map((e) => EntitySummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tracks: ((json['tracks'] as List?) ?? [])
          .map((e) => LearnTrackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
