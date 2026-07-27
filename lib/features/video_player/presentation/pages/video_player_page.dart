import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video/style/enums.dart';
import 'package:video/video.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/vidking_scraper.dart';

class VideoPlayerPage extends StatefulWidget {
  final int tmdbId;
  final String title;
  final String releaseDate;
  final String mediaType; // 'movie' or 'tv'
  final int? seasonId;
  final int? episodeId;

  const VideoPlayerPage({
    super.key,
    required this.tmdbId,
    required this.title,
    required this.releaseDate,
    required this.mediaType,
    this.seasonId,
    this.episodeId,
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

  bool _isLoading = true;
  String _loadingStatus = 'Initializing player...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    vidController = Controller(
      player: Video.createPlayer(),
    );

    vidController.setOnBack(() {
      if (mounted) {
        context.pop();
      }
    });

    _startScrapingAndPlay();
  }

  Future<void> _startScrapingAndPlay() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _loadingStatus = 'Connecting to Vidking API...';
    });

    try {
      Map<String, dynamic> result;
      if (widget.mediaType == 'movie') {
        setState(() => _loadingStatus = 'Searching sources for "${widget.title}"...');
        result = await scraper.scrapeMovie(
          tmdbId: widget.tmdbId,
          title: widget.title,
          releaseDate: widget.releaseDate,
        );
      } else {
        setState(() => _loadingStatus =
            'Searching sources for "${widget.title}" S${widget.seasonId}E${widget.episodeId}...');
        result = await scraper.scrapeTVShow(
          tmdbId: widget.tmdbId,
          title: widget.title,
          seasonId: widget.seasonId ?? 1,
          episodeId: widget.episodeId ?? 1,
          firstAirDate: widget.releaseDate,
        );
      }

      final sourcesList = result['sources'] as List<dynamic>? ?? [];
      final subtitlesList = result['subtitles'] as List<dynamic>? ?? [];

      if (sourcesList.isEmpty) {
        throw Exception("No video streams returned by the scraper.");
      }

      final sources = sourcesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final subtitles = subtitlesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      List<VidTrack> tracks = [];
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

      final String episodeSubtitle = widget.mediaType == 'tv'
          ? 'S${widget.seasonId ?? 1} E${widget.episodeId ?? 1}'
          : widget.releaseDate;

      // Build quality map if multiple sources exist
      Map<int, String> qualityMap = {};
      for (final src in sources) {
        final qStr = (src['quality'] ?? '').toString();
        final url = (src['url'] ?? '').toString();
        if (url.isNotEmpty) {
          final digits = RegExp(r'\d+').firstMatch(qStr)?.group(0);
          final int qInt = digits != null ? int.parse(digits) : (qualityMap.length + 1) * 360;
          qualityMap[qInt] = url;
        }
      }

      Datasource datasource;
      if (qualityMap.length > 1) {
        datasource = MultiDatasource(
          title: widget.title,
          subtitle: episodeSubtitle,
          server: 'Vidking',
          links: qualityMap,
          headers: _playerHeaders,
          tracks: tracks,
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
        );
      }

      setState(() => _loadingStatus = 'Loading stream into player...');

      await vidController.loadVideo(data: datasource);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
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
            if (!_isLoading && _errorMessage == null)
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
            if (_isLoading)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _loadingStatus,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This might take a moment. Please wait.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                ),
              ),
            if (_errorMessage != null)
              Container(
                color: Colors.black.withValues(alpha: 0.90),
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_sharp,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to Stream Video',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              if (mounted) {
                                context.pop();
                              }
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            label: const Text('Go Back', style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _startScrapingAndPlay,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
