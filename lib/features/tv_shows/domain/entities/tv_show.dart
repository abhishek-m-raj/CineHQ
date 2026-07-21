class TVShow {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? firstAirDate;
  final double voteAverage;
  final List<int> genreIds;

  const TVShow({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.firstAirDate,
    required this.voteAverage,
    required this.genreIds,
  });

  String get fullPosterPath => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : '';

  String get fullBackdropPath => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w1280$backdropPath'
      : '';
}
