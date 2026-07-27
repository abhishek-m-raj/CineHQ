import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineui/cineui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device/device.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/entities/tv_show_detail.dart';
import '../../domain/entities/episode.dart';
import '../../../movies/domain/entities/genre.dart';
import '../../domain/usecases/get_season_episodes.dart';
import '../../domain/usecases/get_tv_show_recommendations.dart';
import '../widgets/tv_show_horizontal_list.dart';
import '../cubits/tv_show_detail_cubit.dart';
import '../cubits/tv_favorites_cubit.dart';

class TVShowDetailPage extends StatefulWidget {
  final int tvShowId;

  const TVShowDetailPage({super.key, required this.tvShowId});

  @override
  State<TVShowDetailPage> createState() => _TVShowDetailPageState();
}

class _TVShowDetailPageState extends State<TVShowDetailPage> {
  late final TVShowDetailCubit _cubit;
  List<TVShow> _recommendations = [];
  bool _loadingRecommendations = true;
  bool _hasFetchedRecommendations = false;

  int _selectedSeason = 1;
  List<Episode> _episodes = [];
  bool _loadingEpisodes = false;
  int? _lastFetchedSeason;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TVShowDetailCubit>()..loadTVShowDetails(widget.tvShowId);
    _loadSeasonEpisodes(1);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadSeasonEpisodes(int seasonNumber) async {
    if (_lastFetchedSeason == seasonNumber && _episodes.isNotEmpty) return;
    setState(() {
      _selectedSeason = seasonNumber;
      _loadingEpisodes = true;
    });
    try {
      final episodes =
          await sl<GetSeasonEpisodes>().call(widget.tvShowId, seasonNumber);
      if (mounted) {
        setState(() {
          _episodes = episodes;
          _loadingEpisodes = false;
          _lastFetchedSeason = seasonNumber;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingEpisodes = false);
      }
    }
  }

  Future<void> _loadRecommendations(List<Genre> genres) async {
    if (_hasFetchedRecommendations) return;
    _hasFetchedRecommendations = true;
    try {
      final results = await sl<GetTVShowRecommendations>().call(widget.tvShowId);
      if (mounted) {
        setState(() {
          _recommendations = results;
          _loadingRecommendations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingRecommendations = false);
      }
    }
  }

  Widget _buildGlassIconButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.6),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildTVMetadataRow(
    ThemeData theme,
    String year,
    int? seasons,
    int? episodes,
    double voteAverage,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _badge(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  voteAverage.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            color: Colors.amber.withValues(alpha: 0.1),
            borderColor: Colors.amber.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 8),
          _badge(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text(year,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
            color: theme.colorScheme.surfaceBright,
            borderColor: theme.colorScheme.outline,
          ),
          if (seasons != null) ...[
            const SizedBox(width: 8),
            _badge(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.layers_rounded,
                      size: 12, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    '$seasons ${seasons == 1 ? 'Season' : 'Seasons'}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              color: theme.colorScheme.surfaceBright,
              borderColor: theme.colorScheme.outline,
            ),
          ],
          if (episodes != null) ...[
            const SizedBox(width: 8),
            _badge(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_library_rounded,
                      size: 12, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(
                    '$episodes ${episodes == 1 ? 'Episode' : 'Episodes'}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              color: theme.colorScheme.surfaceBright,
              borderColor: theme.colorScheme.outline,
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge({
    required Widget child,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  Widget _sectionHeading(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ─────────────────── EPISODES LIST SECTION ─────────────────────────────────

  Widget _buildEpisodesSection(
      ThemeData theme, TVShowDetail tvShow, bool isTvOrDesktop) {
    final totalSeasons = tvShow.numberOfSeasons ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(theme, 'EPISODES'),
        const SizedBox(height: 14),
        // Seasons Selector Row — focusable season tabs
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalSeasons,
            itemBuilder: (context, index) {
              final seasonNum = index + 1;
              final isSelected = _selectedSeason == seasonNum;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _SeasonTabTile(
                  seasonNum: seasonNum,
                  isSelected: isSelected,
                  onTap: () => _loadSeasonEpisodes(seasonNum),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Episodes Vertical Column (No nested Scrollable boundary to ensure smooth TV focus traversal)
        if (_loadingEpisodes)
          Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const ShimmerLoading(width: 160, height: 90, borderRadius: 8),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoading(width: 180, height: 16, borderRadius: 4),
                          SizedBox(height: 8),
                          ShimmerLoading(width: 120, height: 12, borderRadius: 4),
                          SizedBox(height: 8),
                          ShimmerLoading(width: double.infinity, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_episodes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No episode information available for Season $_selectedSeason.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < _episodes.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _EpisodeItemCard(
                  key: ValueKey('ep_${tvShow.id}_${_selectedSeason}_${_episodes[i].episodeNumber}'),
                  episode: _episodes[i],
                  tvShow: tvShow,
                  selectedSeason: _selectedSeason,
                  isTvOrDesktop: isTvOrDesktop,
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildRecommendationsSection(ThemeData theme, bool isTvOrDesktop) {
    if (_loadingRecommendations) {
      return TVShowHorizontalListSkeleton(title: 'RECOMMENDATIONS');
    }
    if (_recommendations.isEmpty) return const SizedBox.shrink();
    return TVShowHorizontalList(
      tvShows: _recommendations,
      title: 'RECOMMENDATIONS',
      padding: EdgeInsets.symmetric(horizontal: isTvOrDesktop ? 48.0 : 20.0),
      showBarIndicator: true,
      onTVShowTap: (show) => context.push('/tv/${show.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTvOrDesktop = Device.isTv || screenWidth > 900;

    return Scaffold(
      body: BlocBuilder<TVShowDetailCubit, TVShowDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is TVShowDetailLoading) {
            return const _DetailLoadingWidget();
          } else if (state is TVShowDetailLoaded) {
            final tvShow = state.tvShow;
            _loadRecommendations(tvShow.genres);
            final year =
                tvShow.firstAirDate != null && tvShow.firstAirDate!.length >= 4
                    ? tvShow.firstAirDate!.substring(0, 4)
                    : '—';
            if (isTvOrDesktop) {
              return _buildLargeScreenLayout(context, theme, tvShow, year);
            } else {
              return _buildMobileLayout(context, theme, tvShow, year);
            }
          } else if (state is TVShowDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FAILED TO LOAD TV SHOW',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontSize: 12)),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () =>
                          _cubit.loadTVShowDetails(widget.tvShowId),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ──────────────────────── MOBILE LAYOUT ──────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeData theme,
    TVShowDetail tvShow,
    String year,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          stretch: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Center(
              child: _buildGlassIconButton(
                theme: theme,
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => context.pop(),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<TvFavoritesCubit, List<int>>(
                bloc: sl<TvFavoritesCubit>(),
                builder: (context, favoriteIds) {
                  final isFavorite = favoriteIds.contains(tvShow.id);
                  return _buildGlassIconButton(
                    theme: theme,
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: isFavorite ? Colors.redAccent : null,
                    onPressed: () =>
                        sl<TvFavoritesCubit>().toggleFavorite(tvShow.id),
                  );
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                tvShow.backdropPath != null && tvShow.backdropPath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: tvShow.fullBackdropPath,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .scale(
                          begin: const Offset(1.05, 1.05),
                          end: const Offset(1.0, 1.0),
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                          theme.scaffoldBackgroundColor,
                        ],
                        stops: const [0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tvShow.tagline != null && tvShow.tagline!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          tvShow.tagline!.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                    if (tvShow.fullLogoPath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CineImage.cachedNetwork(
                          showLoading: false,
                          src: tvShow.fullLogoPath,
                          height: 60,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomLeft,
                        ),
                      ).animate().fadeIn(delay: 100.ms)
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          tvShow.name,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    _buildTVMetadataRow(theme, year, tvShow.numberOfSeasons,
                            tvShow.numberOfEpisodes, tvShow.voteAverage)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    const SizedBox(height: 20),
                    CinePrimaryBtn(
                      height: 52,
                      text: 'WATCH TV SHOW',
                      icon: CineIcons.play,
                      scrollTillTop: true,
                      onTap: () => _showEpisodeSelector(context, tvShow, theme),
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _sectionHeading(theme, 'SYNOPSIS'),
                    const SizedBox(height: 10),
                    Text(
                      tvShow.overview.isNotEmpty
                          ? tvShow.overview
                          : 'No synopsis is currently available.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        height: 1.6,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (tvShow.genres.isNotEmpty) ...[
                      _sectionHeading(theme, 'GENRES'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tvShow.genres.map<Widget>((genre) {
                          return CineChip(text: genre.name.toUpperCase());
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildEpisodesSection(theme, tvShow, false),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _buildRecommendationsSection(theme, false),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────── DESKTOP / TV LAYOUT ─────────────────────────────────

  Widget _buildLargeScreenLayout(
    BuildContext context,
    ThemeData theme,
    TVShowDetail tvShow,
    String year,
  ) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final mediaQueryPadding = MediaQuery.of(context).padding;
    final contentWidth = (sw * 0.50).clamp(320.0, 720.0);
    final firstFoldHeight = (sh - mediaQueryPadding.top - mediaQueryPadding.bottom)
        .clamp(550.0, 1400.0);

    return Stack(
      children: [
        // Backdrop — covers the whole screen
        Positioned.fill(
          child: tvShow.backdropPath != null && tvShow.backdropPath!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: tvShow.fullBackdropPath,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const SizedBox(),
                )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .scale(
                    begin: const Offset(1.03, 1.03),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  )
              : Container(color: theme.scaffoldBackgroundColor),
        ),
        // Left-side fade: solid bg → transparent on the right edge
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.90),
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.38, 0.56, 0.84],
              ),
            ),
          ),
        ),
        // Top vignette
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 90,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Scrollable content
        SafeArea(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. FIRST FOLD (Visible initially without scrolling) ──
                  SizedBox(
                    height: firstFoldHeight,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(48.0, 24.0, 48.0, 40.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGlassIconButton(
                            theme: theme,
                            icon: Icons.arrow_back_ios_new_rounded,
                            onPressed: () => context.pop(),
                          ),
                          const Spacer(),
                          if (tvShow.tagline != null &&
                              tvShow.tagline!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                tvShow.tagline!.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 11,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: contentWidth,
                            child: tvShow.fullLogoPath.isNotEmpty
                                ? CineImage.cachedNetwork(
                                    showLoading: false,
                                    src: tvShow.fullLogoPath,
                                    height: 110,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                  )
                                : Text(
                                    tvShow.name,
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _buildTVMetadataRow(
                                theme,
                                year,
                                tvShow.numberOfSeasons,
                                tvShow.numberOfEpisodes,
                                tvShow.voteAverage,
                              ),
                              const SizedBox(width: 16),
                              BlocBuilder<TvFavoritesCubit, List<int>>(
                                bloc: sl<TvFavoritesCubit>(),
                                builder: (context, favoriteIds) {
                                  final isFavorite =
                                      favoriteIds.contains(tvShow.id);
                                  return _buildGlassIconButton(
                                    theme: theme,
                                    icon: isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    iconColor: isFavorite
                                        ? Colors.redAccent
                                        : null,
                                    onPressed: () => sl<TvFavoritesCubit>()
                                        .toggleFavorite(tvShow.id),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // WATCH BUTTON
                          SizedBox(
                            width: contentWidth.clamp(0.0, 400.0),
                            child: CinePrimaryBtn(
                              height: 54,
                              text: 'WATCH TV SHOW',
                              icon: CineIcons.play,
                              scrollTillTop: true,
                              onTap: () =>
                                  _showEpisodeSelector(context, tvShow, theme),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 2. BELOW THE FOLD (Seen only when scrolling) ───────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _sectionHeading(theme, 'SYNOPSIS'),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: contentWidth,
                          child: Text(
                            tvShow.overview.isNotEmpty
                                ? tvShow.overview
                                : 'No synopsis is currently available.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 15,
                              height: 1.65,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (tvShow.genres.isNotEmpty) ...[
                          _sectionHeading(theme, 'GENRES'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tvShow.genres.map<Widget>((genre) {
                              return CineChip(
                                  text: genre.name.toUpperCase());
                            }).toList(),
                          ),
                          const SizedBox(height: 28),
                        ],
                        _buildEpisodesSection(theme, tvShow, true),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationsSection(theme, true),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEpisodeSelector(
    BuildContext context,
    TVShowDetail tvShow,
    ThemeData theme,
  ) {
    int modalSeason = _selectedSeason;
    int selectedEpisode = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final totalEpisodes = tvShow.numberOfEpisodes ?? 10;
              final totalSeasons = tvShow.numberOfSeasons ?? 1;
              final episodesInSeason =
                  (totalEpisodes / totalSeasons).ceil().clamp(1, 50);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Episode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SEASONS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tvShow.numberOfSeasons ?? 1,
                      itemBuilder: (context, index) {
                        final seasonNum = index + 1;
                        final isSelected = modalSeason == seasonNum;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                modalSeason = seasonNum;
                                selectedEpisode = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surfaceBright,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : theme.colorScheme.outline,
                                ),
                              ),
                              child: Text(
                                'Season $seasonNum',
                                style: TextStyle(
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'EPISODES',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: episodesInSeason,
                      itemBuilder: (context, index) {
                        final epNum = index + 1;
                        final isSelected = selectedEpisode == epNum;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() => selectedEpisode = epNum);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surfaceBright,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : theme.colorScheme.outline,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$epNum',
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  CinePrimaryBtn(
                    height: 52,
                    text: 'PLAY EPISODE $selectedEpisode',
                    icon: CineIcons.play,
                    scrollTillTop: true,
                    onTap: () {
                      Navigator.pop(context);
                      final title = Uri.encodeComponent(tvShow.name);
                      final firstAirDate =
                          Uri.encodeComponent(tvShow.firstAirDate ?? '');
                      context.push(
                        '/play/tv/${tvShow.id}/$modalSeason/$selectedEpisode?title=$title&firstAirDate=$firstAirDate',
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────── FOCUSABLE & HOVERABLE SEASON TAB TILE ──────────────────

class _SeasonTabTile extends StatefulWidget {
  final int seasonNum;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeasonTabTile({
    required this.seasonNum,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SeasonTabTile> createState() => _SeasonTabTileState();
}

class _SeasonTabTileState extends State<_SeasonTabTile> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'SeasonTab_${widget.seasonNum}');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : (isActive
                      ? theme.colorScheme.surfaceBright
                      : theme.colorScheme.surfaceBright.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : (widget.isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline.withValues(alpha: 0.5)),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              'Season ${widget.seasonNum}',
              style: TextStyle(
                color: widget.isSelected
                    ? theme.colorScheme.onPrimary
                    : (isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
                fontWeight: widget.isSelected || isActive
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── FOCUSABLE & HOVERABLE EPISODE CARD TILE ─────────────────

class _EpisodeItemCard extends StatefulWidget {
  final Episode episode;
  final TVShowDetail tvShow;
  final int selectedSeason;
  final bool isTvOrDesktop;

  const _EpisodeItemCard({
    super.key,
    required this.episode,
    required this.tvShow,
    required this.selectedSeason,
    required this.isTvOrDesktop,
  });

  @override
  State<_EpisodeItemCard> createState() => _EpisodeItemCardState();
}

class _EpisodeItemCardState extends State<_EpisodeItemCard> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode =
        FocusNode(debugLabel: 'EpisodeCard_${widget.episode.episodeNumber}');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _playEpisode() {
    final title = Uri.encodeComponent(widget.tvShow.name);
    final firstAirDate = Uri.encodeComponent(
      widget.tvShow.firstAirDate ?? '',
    );
    context.push(
      '/play/tv/${widget.tvShow.id}/${widget.selectedSeason}/${widget.episode.episodeNumber}?title=$title&firstAirDate=$firstAirDate',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;
    final stillUrl = widget.episode.fullStillPath.isNotEmpty
        ? widget.episode.fullStillPath
        : widget.tvShow.fullBackdropPath;

    final thumbWidth = widget.isTvOrDesktop ? 220.0 : 130.0;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA ||
              event.logicalKey == LogicalKeyboardKey.space) {
            _playEpisode();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            _playEpisode();
          },
          child: AnimatedScale(
            scale: isActive ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.surfaceBright
                    : theme.colorScheme.surfaceBright.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isActive ? 10 : 11),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Episode Thumbnail Image — NO PADDING (Clipped to left corners)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: SizedBox(
                          width: thumbWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            fit: StackFit.expand,
                            children: [
                              stillUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: stillUrl,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => Container(
                                        color: theme
                                            .colorScheme.surfaceContainerHighest,
                                        child:
                                            const Icon(Icons.movie_rounded, size: 28),
                                      ),
                                    )
                                  : Container(
                                      color:
                                          theme.colorScheme.surfaceContainerHighest,
                                      child:
                                          const Icon(Icons.movie_rounded, size: 28),
                                    ),
                              // Dark overlay gradient (only active when hovered/focused)
                              if (isActive)
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.25),
                                        Colors.black.withValues(alpha: 0.45),
                                      ],
                                    ),
                                  ),
                                ),
                              // Play Icon Overlay — shown ONLY on hover or focus
                              if (isActive)
                                Center(
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.primary,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 26,
                                    ),
                                  ),
                                ).animate().scale(duration: 150.ms, curve: Curves.easeOutCubic).fadeIn(duration: 150.ms),
                            ],
                          ),
                        ),
                      ),

                      // Episode Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.episode.episodeNumber}. ${widget.episode.name.isNotEmpty ? widget.episode.name : "Episode ${widget.episode.episodeNumber}"}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      isActive ? theme.colorScheme.primary : null,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (widget.episode.voteAverage > 0) ...[
                                    const Icon(Icons.star_rounded,
                                        size: 13, color: Colors.amber),
                                    const SizedBox(width: 3),
                                    Text(
                                      widget.episode.voteAverage
                                          .toStringAsFixed(1),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  if (widget.episode.airDate != null &&
                                      widget.episode.airDate!.isNotEmpty) ...[
                                    Icon(Icons.calendar_today_rounded,
                                        size: 11,
                                        color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.episode.airDate!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  if (widget.episode.runtime != null &&
                                      widget.episode.runtime! > 0) ...[
                                    Icon(Icons.access_time_rounded,
                                        size: 11,
                                        color: theme.colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.episode.runtime}m',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.episode.overview.isNotEmpty
                                    ? widget.episode.overview
                                    : 'No episode overview is currently available.',
                                maxLines: widget.isTvOrDesktop ? 3 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailLoadingWidget extends StatelessWidget {
  const _DetailLoadingWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
              width: double.infinity, height: 300, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 120, height: 12, borderRadius: 2),
                const SizedBox(height: 12),
                const ShimmerLoading(width: 250, height: 28, borderRadius: 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const ShimmerLoading(
                        width: 40, height: 16, borderRadius: 2),
                    _dot(theme),
                    const ShimmerLoading(
                        width: 60, height: 16, borderRadius: 2),
                    _dot(theme),
                    const ShimmerLoading(
                        width: 50, height: 16, borderRadius: 2),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const ShimmerLoading(width: 80, height: 14, borderRadius: 2),
                const SizedBox(height: 12),
                const ShimmerLoading(
                    width: double.infinity, height: 14, borderRadius: 2),
                const SizedBox(height: 8),
                const ShimmerLoading(
                    width: double.infinity, height: 14, borderRadius: 2),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 200, height: 14, borderRadius: 2),
                const SizedBox(height: 24),
                const ShimmerLoading(width: 80, height: 14, borderRadius: 2),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    3,
                    (i) => const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: ShimmerLoading(
                          width: 70, height: 24, borderRadius: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
