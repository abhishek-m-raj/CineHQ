import 'dart:async';
import 'package:dio/dio.dart';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video/style/enums.dart';
import 'package:video/video.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/opensubtitles_service.dart';
import '../../../../core/network/vidking_scraper.dart';
import '../../../../core/utils/subtitle_utils.dart';
import '../../../tv_shows/domain/usecases/get_season_episodes.dart';
import '../../../tv_shows/domain/usecases/get_tv_show_details.dart';
import '../cubits/continue_watching_cubit.dart';


class VideoPlayerPage extends StatefulWidget {
  final int tmdbId;
  final String title;
  final String releaseDate;
  final String mediaType; // 'movie' or 'tv'
  final int? seasonId;
  final int? episodeId;
  final String? posterPath;
  final String? backdropPath;

  const VideoPlayerPage({
    super.key,
    required this.tmdbId,
    required this.title,
    required this.releaseDate,
    required this.mediaType,
    this.seasonId,
    this.episodeId,
    this.posterPath,
    this.backdropPath,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final Controller vidController;
  final scraper = sl<VidkingScraper>();

  static const Map<String, String> _playerHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Referer': 'https://www.vidking.net/',
    'Origin': 'https://www.vidking.net',
  };

  late int _currentSeason;
  late int _currentEpisode;
  String? _errorMessage;
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<dynamic>? _errorSub;
  bool _isAutoAdvancing = false;
  int? _lastSavedSecond;


  String _formatYear(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parts = dateStr.split('-');
    if (parts.isNotEmpty && parts.first.length == 4) {
      return parts.first;
    }
    final dt = DateTime.tryParse(dateStr);
    if (dt != null) {
      return dt.year.toString();
    }
    return dateStr;
  }

  String get _subtitleText {
    if (widget.mediaType == 'tv') {
      return 'S$_currentSeason E$_currentEpisode';
    }
    return _formatYear(widget.releaseDate);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _currentSeason = widget.seasonId ?? 1;
    _currentEpisode = widget.episodeId ?? 1;

    vidController = Controller(
      player: Video.createPlayer(),
    );

    vidController.setOnBack(() {
      if (mounted) {
        context.pop();
      }
    });

    vidController.onSearchSubtitles = _searchSubtitles;
    vidController.onDownloadSubtitle = _downloadSubtitle;

    _completedSub = vidController.streams.onCompleted.listen((completed) {
      if (completed && mounted && widget.mediaType == 'tv' && !_isAutoAdvancing) {
        if (sl<LocalStorage>().isAutoNextEnabled()) {
          _playNextEpisode();
        }
      }
    });

    _errorSub = vidController.player.stream.error.listen((err) {
      if (mounted && _errorMessage == null) {
        setState(() {
          _errorMessage = err.toString().replaceAll('Exception: ', '');
        });
        vidController.setVideoInfo(loading: false);
      }
    });

    final coverUrl = _getCoverImageUrl();

    vidController.setVideoInfo(
      title: widget.title,
      subtitle: _subtitleText,
      coverImg: coverUrl,
      loading: true,
    );

    if (widget.mediaType == 'tv') {
      _loadTVShowEpisodes(_currentSeason);
    }

    if (Device.isMobile) {
      vidController.enFullscreen();
    }

    _startScrapingAndPlay();
  }

  Future<void> _playNextEpisode() async {
    if (_isAutoAdvancing) return;
    _isAutoAdvancing = true;

    try {
      final nextEpisode = _currentEpisode + 1;
      final totalEpisodesInCurrentSeason = vidController.episodeData?.episodes.length ?? 0;
      final totalSeasons = vidController.episodeData?.totalSeasons ?? 1;

      if (totalEpisodesInCurrentSeason > 0 && nextEpisode <= totalEpisodesInCurrentSeason) {
        _switchEpisode(_currentSeason, nextEpisode);
      } else if (_currentSeason < totalSeasons) {
        final nextSeason = _currentSeason + 1;
        await _loadTVShowEpisodes(nextSeason);
        _switchEpisode(nextSeason, 1);
      }
    } catch (_) {
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _isAutoAdvancing = false;
        }
      });
    }
  }

  String? _getCoverImageUrl() {
    if (widget.backdropPath != null && widget.backdropPath!.isNotEmpty) {
      return widget.backdropPath!.startsWith('http')
          ? widget.backdropPath
          : 'https://image.tmdb.org/t/p/w1280${widget.backdropPath}';
    }
    if (widget.posterPath != null && widget.posterPath!.isNotEmpty) {
      return widget.posterPath!.startsWith('http')
          ? widget.posterPath
          : 'https://image.tmdb.org/t/p/w500${widget.posterPath}';
    }
    return null;
  }

  Future<void> _loadTVShowEpisodes(int seasonNum) async {
    if (vidController.episodeData != null) {
      vidController.setEpisodeData(EpisodeData(
        playingSeason: _currentSeason,
        playingEpisode: _currentEpisode,
        selectedSeason: seasonNum,
        totalSeasons: vidController.episodeData!.totalSeasons,
        episodes: vidController.episodeData!.episodes,
        isLoadingEpisodes: true,
        onSelectSeason: (s) => _loadTVShowEpisodes(s),
        onSelectEpisode: (s, e) => _switchEpisode(s, e),
      ));
    }
    try {
      final tvDetail = await sl<GetTVShowDetails>().call(widget.tmdbId);
      final episodes = await sl<GetSeasonEpisodes>().call(widget.tmdbId, seasonNum);

      final episodeItems = episodes.map((e) => EpisodeItem(
        episodeNumber: e.episodeNumber,
        name: e.name,
        overview: e.overview,
        stillPath: e.fullStillPath.isNotEmpty ? e.fullStillPath : _getCoverImageUrl(),
        airDate: e.airDate,
        runtime: e.runtime,
        voteAverage: e.voteAverage,
      )).toList();

      if (mounted) {
        vidController.setEpisodeData(EpisodeData(
          playingSeason: _currentSeason,
          playingEpisode: _currentEpisode,
          selectedSeason: seasonNum,
          totalSeasons: tvDetail.numberOfSeasons ?? 1,
          episodes: episodeItems,
          isLoadingEpisodes: false,
          onSelectSeason: (s) => _loadTVShowEpisodes(s),
          onSelectEpisode: (s, e) => _switchEpisode(s, e),
        ));
      }
    } catch (_) {}
  }

  void _switchEpisode(int season, int episode) {
    if (_currentSeason == season && _currentEpisode == episode && vidController.player.state.playing) {
      return;
    }
    _saveCurrentProgress();
    setState(() {
      _currentSeason = season;
      _currentEpisode = episode;
    });

    if (vidController.episodeData != null) {
      vidController.setEpisodeData(EpisodeData(
        playingSeason: season,
        playingEpisode: episode,
        selectedSeason: vidController.episodeData!.selectedSeason,
        totalSeasons: vidController.episodeData!.totalSeasons,
        episodes: vidController.episodeData!.episodes,
        isLoadingEpisodes: vidController.episodeData!.isLoadingEpisodes,
        onSelectSeason: vidController.episodeData!.onSelectSeason,
        onSelectEpisode: vidController.episodeData!.onSelectEpisode,
      ));
    }

    vidController.setVideoInfo(
      title: widget.title,
      subtitle: 'S$season E$episode',
      coverImg: _getCoverImageUrl(),
      loading: true,
    );

    _startScrapingAndPlay();
  }

  String? _cachedImdbId;

  Future<List<Map<String, dynamic>>> _searchSubtitles(String query) async {
    if (!mounted) return [];

    if (_cachedImdbId == null) {
      final service = OpenSubtitlesService(sl<Dio>());
      _cachedImdbId = await service.fetchImdbId(
        tmdbDio: sl<ApiClient>().dio,
        tmdbId: widget.tmdbId,
        mediaType: widget.mediaType,
      );
    }

    if (_cachedImdbId == null) return [];

    final service = OpenSubtitlesService(sl<Dio>());
    final results = await service.search(imdbId: _cachedImdbId!);
    final bool onlyEnglish = sl<LocalStorage>().isOnlyEnglishSubtitlesEnabled();
    final filteredResults = onlyEnglish
        ? results.where((s) => isEnglishSubtitle(s.language) || isEnglishSubtitle(s.display)).toList()
        : results;
    return filteredResults.map((s) => {
      'id': s.id,
      'display': s.display,
      'language': s.language,
      'format': s.format,
      'release': s.release,
      'url': s.url,
      'downloadCount': s.downloadCount,
      'isHearingImpaired': s.isHearingImpaired,
      'isTrusted': s.isTrusted,
      'origin': s.origin,
      'flagUrl': s.flagUrl,
    }).toList();
  }

  Future<String?> _downloadSubtitle(String subtitleId) async {
    final service = OpenSubtitlesService(sl<Dio>());
    return service.downloadSubtitle(subtitleId);
  }

  Future<void> _startScrapingAndPlay() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    vidController.setVideoInfo(loading: true);

    try {
      Map<String, dynamic> result;
      if (widget.mediaType == 'movie') {
        result = await scraper.scrapeMovie(
          tmdbId: widget.tmdbId,
          title: widget.title,
          releaseDate: widget.releaseDate,
        );
      } else {
        result = await scraper.scrapeTVShow(
          tmdbId: widget.tmdbId,
          title: widget.title,
          seasonId: _currentSeason,
          episodeId: _currentEpisode,
          firstAirDate: widget.releaseDate,
        );
      }

      final sourcesList = result['sources'] as List<dynamic>? ?? [];
      final subtitlesList = result['subtitles'] as List<dynamic>? ?? [];

      if (sourcesList.isEmpty) {
        throw Exception("No video streams found for this title.");
      }

      final sources = sourcesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final subtitles = subtitlesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      final bool onlyEnglish = sl<LocalStorage>().isOnlyEnglishSubtitlesEnabled();

      List<VidTrack> tracks = [];
      for (final sub in subtitles) {
        final fileUrl = (sub['file'] ?? sub['url'] ?? '').toString();
        final label = (sub['label'] ?? sub['lang'] ?? 'Unknown').toString();
        final lang = (sub['lang'] ?? sub['label'] ?? '').toString();
        if (fileUrl.isNotEmpty) {
          if (onlyEnglish && !isEnglishSubtitle(label, url: fileUrl) && !isEnglishSubtitle(lang, url: fileUrl)) {
            continue;
          }
          tracks.add(
            VidTrack(
              type: VidTrackType.caption,
              label: label,
              url: fileUrl,
              headers: _playerHeaders,
            ),
          );
        }
      }

      // Fallback 1: If onlyEnglish is enabled and no English subtitles were found from scraper,
      // search OpenSubtitles automatically for an English subtitle.
      if (onlyEnglish && tracks.isEmpty) {
        try {
          final openSubResults = await _searchSubtitles('');
          final englishSubs = openSubResults.where((s) {
            final lang = (s['language'] ?? '').toString();
            final display = (s['display'] ?? '').toString();
            return isEnglishSubtitle(lang) || isEnglishSubtitle(display);
          }).toList();

          if (englishSubs.isNotEmpty) {
            englishSubs.sort((a, b) => ((b['downloadCount'] as int?) ?? 0).compareTo((a['downloadCount'] as int?) ?? 0));
            final bestSub = englishSubs.first;
            final subUrl = (bestSub['url'] ?? '').toString();
            if (subUrl.isNotEmpty) {
              tracks.add(
                VidTrack(
                  type: VidTrackType.caption,
                  label: (bestSub['display'] ?? 'English').toString(),
                  url: subUrl,
                  headers: _playerHeaders,
                ),
              );
            }
          }
        } catch (_) {
          // OpenSubtitles fallback silent catch
        }
      }

      // Fallback 2: If still no tracks found, load all available scraper subtitles
      // so the user is never left without subtitles if subtitles exist.
      if (tracks.isEmpty) {
        for (final sub in subtitles) {
          final fileUrl = (sub['file'] ?? sub['url'] ?? '').toString();
          final label = (sub['label'] ?? sub['lang'] ?? 'Unknown').toString();
          if (fileUrl.isNotEmpty) {
            tracks.add(
              VidTrack(
                type: VidTrackType.caption,
                label: label,
                url: fileUrl,
                headers: _playerHeaders,
              ),
            );
          }
        }
      }

      final String episodeSubtitle = _subtitleText;

      Map<int, String> qualityMap = {};
      for (int i = 0; i < sources.length; i++) {
        final src = sources[i];
        final qStr = (src['quality'] ?? '').toString();
        final url = (src['url'] ?? '').toString();
        if (url.isNotEmpty) {
          final digits = RegExp(r'\d+').firstMatch(qStr)?.group(0);
          int qInt = digits != null ? int.parse(digits) : (1080 - (i * 120));
          while (qualityMap.containsKey(qInt)) {
            qInt -= 1;
          }
          qualityMap[qInt] = url;
        }
      }

      final preferredRes = sl<LocalStorage>().getDefaultResolution();
      int? targetRes;
      if (preferredRes != 'Auto') {
        targetRes = int.tryParse(preferredRes.replaceAll(RegExp(r'\D'), ''));
      }

      final sortedKeys = qualityMap.keys.toList()..sort((a, b) => b.compareTo(a));
      if (targetRes != null && sortedKeys.isNotEmpty) {
        int? matchKey;
        if (qualityMap.containsKey(targetRes)) {
          matchKey = targetRes;
        } else {
          int minDiff = 99999;
          for (final k in sortedKeys) {
            final diff = (k - targetRes).abs();
            if (diff < minDiff) {
              minDiff = diff;
              matchKey = k;
            }
          }
        }
        if (matchKey != null) {
          sortedKeys.remove(matchKey);
          sortedKeys.insert(0, matchKey);
        }
      }

      Map<int, String> sortedQualityMap = {
        for (var k in sortedKeys) k: qualityMap[k]!
      };

      final String? coverUrl = (result['thumbnail'] != null && (result['thumbnail'] as String).isNotEmpty)
          ? result['thumbnail'] as String
          : _getCoverImageUrl();

      Datasource datasource;
      if (sortedQualityMap.length > 1) {
        datasource = MultiDatasource(
          title: widget.title,
          subtitle: episodeSubtitle,
          server: 'Vidking',
          links: sortedQualityMap,
          headers: _playerHeaders,
          tracks: tracks,
          coverImg: coverUrl,
        );
      } else {
        final defaultSource = sources.first;
        final videoUrl = defaultSource['url'] as String;
        datasource = SingleDatasource(
          title: widget.title,
          subtitle: episodeSubtitle,
          server: 'Vidking',
          url: videoUrl,
          headers: _playerHeaders,
          tracks: tracks,
          coverImg: coverUrl,
        );
      }

      await vidController.loadVideo(data: datasource);

      final savedItem = sl<ContinueWatchingCubit>().getItemForShow(widget.tmdbId, widget.mediaType);
      if (savedItem != null && savedItem.positionInSeconds > 5 && !savedItem.isCompleted) {
        final isSameEpisode = widget.mediaType == 'movie' ||
            (savedItem.seasonNumber == _currentSeason && savedItem.episodeNumber == _currentEpisode);
        if (isSameEpisode) {
          final targetDuration = Duration(seconds: savedItem.positionInSeconds);
          await vidController.player.seek(targetDuration);
        }
      }

      _positionSub?.cancel();
      _positionSub = vidController.player.stream.position.listen((pos) {
        _saveCurrentProgress(pos);
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        vidController.setVideoInfo(loading: false);
      }
    }
  }

  void _saveCurrentProgress([Duration? currentPos]) {
    final pos = currentPos ?? vidController.player.state.position;
    final dur = vidController.player.state.duration;

    if (dur.inSeconds > 0 && pos.inSeconds > 0) {
      if (_lastSavedSecond == null || (pos.inSeconds - _lastSavedSecond!).abs() >= 3) {
        _lastSavedSecond = pos.inSeconds;
        sl<ContinueWatchingCubit>().saveProgress(
          tmdbId: widget.tmdbId,
          mediaType: widget.mediaType,
          title: widget.title,
          releaseDate: widget.releaseDate,
          posterPath: widget.posterPath,
          backdropPath: widget.backdropPath,
          seasonNumber: widget.mediaType == 'tv' ? _currentSeason : null,
          episodeNumber: widget.mediaType == 'tv' ? _currentEpisode : null,
          positionInSeconds: pos.inSeconds,
          durationInSeconds: dur.inSeconds,
        );
      }
    }
  }

  @override
  void dispose() {
    _saveCurrentProgress();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _errorSub?.cancel();
    if (vidController.isFullscreen) {
      vidController.exFullscreen();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    vidController.dispose();
    vidController.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: VideoPopScope(
        controller: vidController,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: VideoPlayer(
                controller: vidController,
                style: VidStyle(
                  playerMode: Device.isDesktop || Device.isTv
                      ? VidPlayerMode.desktop
                      : VidPlayerMode.mobile,
                ),
              ),
            ),


            if (_errorMessage != null)
              Container(
                color: Colors.black.withValues(alpha: 0.90),
                alignment: Alignment.center,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Playback Error',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  actions: [
                    ElevatedButton(
                      autofocus: true,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
