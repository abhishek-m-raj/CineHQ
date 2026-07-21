import '../../domain/entities/movie_detail.dart';
import 'genre_model.dart';

class MovieDetailModel extends MovieDetail {
  const MovieDetailModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    required super.voteAverage,
    super.runtime,
    required super.genres,
    super.tagline,
    super.logoPath,
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
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

    return MovieDetailModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int?,
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
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'release_date': releaseDate,
      'vote_average': voteAverage,
      'runtime': runtime,
      'genres': genres.map((g) => (g as GenreModel).toJson()).toList(),
      'tagline': tagline,
      'logo_path': logoPath,
    };
  }
}
