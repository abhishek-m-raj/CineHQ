class EpisodeItem {
  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final String? airDate;
  final int? runtime;
  final double voteAverage;

  const EpisodeItem({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    this.stillPath,
    this.airDate,
    this.runtime,
    this.voteAverage = 0.0,
  });

  String get fullStillPath => stillPath != null && stillPath!.isNotEmpty
      ? (stillPath!.startsWith('http') ? stillPath! : 'https://image.tmdb.org/t/p/w500$stillPath')
      : '';
}

class EpisodeData {
  final int playingSeason;
  final int playingEpisode;
  final int selectedSeason;
  final int totalSeasons;
  final List<EpisodeItem> episodes;
  final bool isLoadingEpisodes;
  final void Function(int season, int episode) onSelectEpisode;
  final void Function(int season) onSelectSeason;

  const EpisodeData({
    required this.playingSeason,
    required this.playingEpisode,
    required this.selectedSeason,
    required this.totalSeasons,
    required this.episodes,
    this.isLoadingEpisodes = false,
    required this.onSelectEpisode,
    required this.onSelectSeason,
  });

  int get currentSeason => selectedSeason;
  int get currentEpisode => playingEpisode;
}
