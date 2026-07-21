import '../../../movies/domain/entities/genre.dart';

class TVShowDetail {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? firstAirDate;
  final double voteAverage;
  final int? numberOfEpisodes;
  final int? numberOfSeasons;
  final List<Genre> genres;
  final String? tagline;
  final String? logoPath;

  const TVShowDetail({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    required this.voteAverage,
    this.numberOfEpisodes,
    this.numberOfSeasons,
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
