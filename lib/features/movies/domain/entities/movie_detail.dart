import 'genre.dart';

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final int? runtime;
  final List<Genre> genres;
  final String? tagline;
  final String? logoPath;

  const MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.voteAverage,
    this.runtime,
    required this.genres,
    this.tagline,
    this.logoPath,
  });

  String get fullPosterPath => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get fullBackdropPath => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';

  String get fullLogoPath => logoPath != null
      ? 'https://image.tmdb.org/t/p/w500$logoPath'
      : '';
}
