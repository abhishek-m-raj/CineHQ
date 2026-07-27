class Episode {
  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final String? airDate;
  final int? runtime;
  final double voteAverage;

  const Episode({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    this.stillPath,
    this.airDate,
    this.runtime,
    required this.voteAverage,
  });

  String get fullStillPath => stillPath != null && stillPath!.isNotEmpty
      ? 'https://image.tmdb.org/t/p/w500$stillPath'
      : '';
}
