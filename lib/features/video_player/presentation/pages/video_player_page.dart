import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:go_router/go_router.dart';

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
  late final Player player;
  VideoController? controller;
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
  
  List<Map<String, dynamic>> _subtitles = [];
  String? _currentSubtitleUrl;
  String? _videoUrl;
  String? _selectedQuality;
  List<Map<String, dynamic>> _sources = [];

  @override
  void initState() {
    super.initState();
    // Enable immersive fullscreen and support standard orientations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    player = Player();
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
        setState(() => _loadingStatus = 'Searching sources for "${widget.title}" S${widget.seasonId}E${widget.episodeId}...');
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

      _sources = sourcesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _subtitles = subtitlesList.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // Pick first source as default
      final defaultSource = _sources.first;
      _videoUrl = defaultSource['url'] as String;
      _selectedQuality = defaultSource['quality'] as String;

      setState(() => _loadingStatus = 'Loading stream into MediaKit player...');

      controller = VideoController(player);

      await player.open(
        Media(_videoUrl!, httpHeaders: _playerHeaders),
      );

      // Auto-load English subtitle if available
      if (_subtitles.isNotEmpty) {
        final englishSub = _subtitles.firstWhere(
          (sub) => (sub['label'] as String? ?? '').toLowerCase().contains('english'),
          orElse: () => _subtitles.first,
        );
        final fileUrl = englishSub['file'] ?? englishSub['url'] ?? '';
        final label = englishSub['label'] ?? englishSub['lang'] ?? 'Default';
        if (fileUrl.isNotEmpty) {
          await player.setSubtitleTrack(
            SubtitleTrack.uri(
              fileUrl,
              title: label,
              language: label.substring(0, 2).toLowerCase(),
            ),
          );
          _currentSubtitleUrl = fileUrl;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _showSubtitleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[950]?.withValues(alpha: 0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Subtitles',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.subtitles_off_outlined,
                        color: _currentSubtitleUrl == null ? Theme.of(context).colorScheme.primary : Colors.white70,
                      ),
                      title: Text(
                        'Off',
                        style: TextStyle(
                          color: _currentSubtitleUrl == null ? Theme.of(context).colorScheme.primary : Colors.white,
                          fontWeight: _currentSubtitleUrl == null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        player.setSubtitleTrack(SubtitleTrack.no());
                        setState(() {
                          _currentSubtitleUrl = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    if (_subtitles.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                        child: Text(
                          'No subtitles available',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    ..._subtitles.map((sub) {
                      final fileUrl = sub['file'] ?? sub['url'] ?? '';
                      final label = sub['label'] ?? sub['lang'] ?? 'Unknown';
                      final isSelected = _currentSubtitleUrl == fileUrl;
                      return ListTile(
                        leading: Icon(
                          Icons.subtitles_outlined,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
                        ),
                        title: Text(
                          label,
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        onTap: () async {
                          if (fileUrl.isNotEmpty) {
                            await player.setSubtitleTrack(
                              SubtitleTrack.uri(
                                fileUrl,
                                title: label,
                                language: label.substring(0, 2).toLowerCase(),
                              ),
                            );
                            setState(() {
                              _currentSubtitleUrl = fileUrl;
                            });
                          }
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[950]?.withValues(alpha: 0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: _sources.map((src) {
                    final quality = src['quality'] as String? ?? 'Auto';
                    final url = src['url'] as String? ?? '';
                    final isSelected = _selectedQuality == quality;
                    return ListTile(
                      leading: Icon(
                        Icons.high_quality_outlined,
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
                      ),
                      title: Text(
                        quality,
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () async {
                        if (url.isNotEmpty && !isSelected) {
                          final currentPosition = player.state.position;
                          setState(() {
                            _selectedQuality = quality;
                            _videoUrl = url;
                          });
                          await player.open(
                            Media(url, httpHeaders: _playerHeaders),
                          );
                          // Seek back to previous position to resume
                          await player.seek(currentPosition);
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          if (controller != null && !_isLoading && _errorMessage == null)
            Center(
              child: MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  topButtonBar: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (mounted) {
                          context.pop();
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.subtitles, color: Colors.white),
                      tooltip: 'Subtitles',
                      onPressed: _showSubtitleSelector,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      tooltip: 'Quality',
                      onPressed: _showQualitySelector,
                    ),
                  ],
                  bottomButtonBar: [
                    const MaterialPlayOrPauseButton(),
                    const MaterialPositionIndicator(
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                ),
                fullscreen: MaterialVideoControlsThemeData(
                  topButtonBar: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (mounted) {
                          context.pop();
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.subtitles, color: Colors.white),
                      tooltip: 'Subtitles',
                      onPressed: _showSubtitleSelector,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      tooltip: 'Quality',
                      onPressed: _showQualitySelector,
                    ),
                  ],
                  bottomButtonBar: [
                    const MaterialPlayOrPauseButton(),
                    const MaterialPositionIndicator(
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                ),
                child: Video(
                  controller: controller!,
                  controls: MaterialVideoControls,
                ),
              ),
            ),

          // Loading Screen
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

          // Error Screen
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
    );
  }
}
