class ContinueWatchingItem {
  final int tmdbId;
  final String mediaType; // 'movie' or 'tv'
  final String title;
  final String releaseDate;
  final String? posterPath;
  final String? backdropPath;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeTitle;
  final int positionInSeconds;
  final int durationInSeconds;
  final DateTime lastUpdated;

  const ContinueWatchingItem({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.releaseDate,
    this.posterPath,
    this.backdropPath,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeTitle,
    required this.positionInSeconds,
    required this.durationInSeconds,
    required this.lastUpdated,
  });

  double get progressPercentage {
    if (durationInSeconds <= 0) return 0.0;
    return (positionInSeconds / durationInSeconds).clamp(0.0, 1.0);
  }

  bool get isCompleted => progressPercentage >= 0.95;

  String get key => mediaType == 'tv'
      ? 'tv_${tmdbId}_s${seasonNumber ?? 1}_e${episodeNumber ?? 1}'
      : 'movie_$tmdbId';

  String get showKey => '${mediaType}_$tmdbId';

  String get fullPosterPath {
    if (posterPath == null || posterPath!.isEmpty) return '';
    return posterPath!.startsWith('http')
        ? posterPath!
        : 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get fullBackdropPath {
    if (backdropPath != null && backdropPath!.isNotEmpty) {
      return backdropPath!.startsWith('http')
          ? backdropPath!
          : 'https://image.tmdb.org/t/p/w780$backdropPath';
    }
    return fullPosterPath;
  }

  String get formattedTimeLeft {
    final remainingSeconds = (durationInSeconds - positionInSeconds).clamp(0, durationInSeconds);
    final remainingDuration = Duration(seconds: remainingSeconds);
    if (remainingDuration.inHours > 0) {
      final hours = remainingDuration.inHours;
      final minutes = remainingDuration.inMinutes.remainder(60);
      return '${hours}h ${minutes}m left';
    } else if (remainingDuration.inMinutes > 0) {
      return '${remainingDuration.inMinutes}m left';
    } else {
      return '${remainingDuration.inSeconds}s left';
    }
  }

  String get formattedPosition {
    final posDuration = Duration(seconds: positionInSeconds);
    final durDuration = Duration(seconds: durationInSeconds);

    String formatDuration(Duration d) {
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      if (hours > 0) {
        return '$hours:$minutes:$seconds';
      }
      return '$minutes:$seconds';
    }

    return '${formatDuration(posDuration)} / ${formatDuration(durDuration)}';
  }

  ContinueWatchingItem copyWith({
    int? tmdbId,
    String? mediaType,
    String? title,
    String? releaseDate,
    String? posterPath,
    String? backdropPath,
    int? seasonNumber,
    int? episodeNumber,
    String? episodeTitle,
    int? positionInSeconds,
    int? durationInSeconds,
    DateTime? lastUpdated,
  }) {
    return ContinueWatchingItem(
      tmdbId: tmdbId ?? this.tmdbId,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      releaseDate: releaseDate ?? this.releaseDate,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      episodeTitle: episodeTitle ?? this.episodeTitle,
      positionInSeconds: positionInSeconds ?? this.positionInSeconds,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tmdbId': tmdbId,
      'mediaType': mediaType,
      'title': title,
      'releaseDate': releaseDate,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'episodeTitle': episodeTitle,
      'positionInSeconds': positionInSeconds,
      'durationInSeconds': durationInSeconds,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ContinueWatchingItem.fromJson(Map<String, dynamic> json) {
    return ContinueWatchingItem(
      tmdbId: json['tmdbId'] as int,
      mediaType: json['mediaType'] as String,
      title: json['title'] as String? ?? '',
      releaseDate: json['releaseDate'] as String? ?? '',
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      seasonNumber: json['seasonNumber'] as int?,
      episodeNumber: json['episodeNumber'] as int?,
      episodeTitle: json['episodeTitle'] as String?,
      positionInSeconds: json['positionInSeconds'] as int? ?? 0,
      durationInSeconds: json['durationInSeconds'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
