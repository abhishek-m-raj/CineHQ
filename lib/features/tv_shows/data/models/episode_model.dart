import '../../domain/entities/episode.dart';

class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.episodeNumber,
    required super.name,
    required super.overview,
    super.stillPath,
    super.airDate,
    super.runtime,
    required super.voteAverage,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      episodeNumber: json['episode_number'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] as String?,
      runtime: json['runtime'] as int?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
