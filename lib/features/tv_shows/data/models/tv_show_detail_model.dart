import '../../domain/entities/tv_show_detail.dart';
import '../../../movies/data/models/genre_model.dart';

class TVShowDetailModel extends TVShowDetail {
  const TVShowDetailModel({
    required super.id,
    required super.name,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    super.firstAirDate,
    required super.voteAverage,
    super.numberOfEpisodes,
    super.numberOfSeasons,
    required super.genres,
    super.tagline,
    super.logoPath,
  });

  factory TVShowDetailModel.fromJson(Map<String, dynamic> json) {
    String? logo;
    if (json['images'] != null && json['images']['logos'] != null) {
      final logos = json['images']['logos'] as List<dynamic>;
      if (logos.isNotEmpty) {
        final enLogo = logos.firstWhere(
          (l) => l['iso_639_1'] == 'en',
          orElse: () => logos.first,
        );
        logo = enLogo['file_path'] as String?;
      }
    }

    return TVShowDetailModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      numberOfEpisodes: json['number_of_episodes'] as int?,
      numberOfSeasons: json['number_of_seasons'] as int?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      tagline: json['tagline'] as String?,
      logoPath: logo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'first_air_date': firstAirDate,
      'vote_average': voteAverage,
      'number_of_episodes': numberOfEpisodes,
      'number_of_seasons': numberOfSeasons,
      'genres': genres.map((g) => (g as GenreModel).toJson()).toList(),
      'tagline': tagline,
      'logo_path': logoPath,
    };
  }
}
