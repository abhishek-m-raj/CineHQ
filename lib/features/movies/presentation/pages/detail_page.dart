import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineui/cineui.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:device/device.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/genre.dart';
import '../../domain/usecases/get_movie_recommendations.dart';
import '../widgets/movie_horizontal_list.dart';
import '../../../../core/widgets/focusable_glass_icon_button.dart';
import '../cubits/movie_detail_cubit.dart';

class DetailPage extends StatefulWidget {
  final int movieId;

  const DetailPage({super.key, required this.movieId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final MovieDetailCubit _cubit;
  final FocusNode _watchButtonFocusNode = FocusNode(debugLabel: 'DetailPageWatchBtn');
  List<Movie> _recommendations = [];
  bool _loadingRecommendations = true;
  bool _hasFetchedRecommendations = false;

  @override
  void initState() {
    super.initState();
    _cubit = sl<MovieDetailCubit>()..loadMovieDetails(widget.movieId);
    if (Device.isTv) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _watchButtonFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _watchButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendations(List<Genre> genres) async {
    if (_hasFetchedRecommendations) return;
    _hasFetchedRecommendations = true;
    try {
      final results = await sl<GetMovieRecommendations>().call(widget.movieId);
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

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes == 0) return '—';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }

  Widget _buildGlassIconButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return FocusableGlassIconButton(
      theme: theme,
      icon: icon,
      onPressed: onPressed,
      iconColor: iconColor,
    );
  }

  Widget _buildMetadataRow(
    ThemeData theme,
    String year,
    String runtime,
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
          const SizedBox(width: 8),
          _badge(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded,
                    size: 12, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Text(runtime,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
            color: theme.colorScheme.surfaceBright,
            borderColor: theme.colorScheme.outline,
          ),
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

  Widget _buildRecommendationsSection(ThemeData theme, bool isTvOrDesktop) {
    if (_loadingRecommendations) {
      return MovieHorizontalListSkeleton(title: 'RECOMMENDATIONS');
    }
    if (_recommendations.isEmpty) return const SizedBox.shrink();
    return MovieHorizontalList(
      movies: _recommendations,
      title: 'RECOMMENDATIONS',
      padding: EdgeInsets.symmetric(horizontal: isTvOrDesktop ? 48.0 : 20.0),
      showBarIndicator: true,
      onMovieTap: (movie) => context.push('/movie/${movie.id}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTvOrDesktop = Device.isTv || screenWidth > 900;

    return Scaffold(
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const _DetailLoadingWidget();
          } else if (state is MovieDetailLoaded) {
            final movie = state.movie;
            _loadRecommendations(movie.genres);
            final year =
                movie.releaseDate != null && movie.releaseDate!.length >= 4
                    ? movie.releaseDate!.substring(0, 4)
                    : '—';
            if (isTvOrDesktop) {
              return _buildLargeScreenLayout(context, theme, movie, year);
            } else {
              return _buildMobileLayout(context, theme, movie, year);
            }
          } else if (state is MovieDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FAILED TO LOAD',
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
                          _cubit.loadMovieDetails(widget.movieId),
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
    dynamic movie,
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
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground],
            background: Stack(
              fit: StackFit.expand,
              children: [
                movie.backdropPath != null && movie.backdropPath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.fullBackdropPath,
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
                    if (movie.fullLogoPath.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CineImage.cachedNetwork(
                          showLoading: false,
                          src: movie.fullLogoPath,
                          height: 60,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomLeft,
                        ),
                      ).animate().fadeIn(delay: 100.ms)
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          movie.title,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    _buildMetadataRow(theme, year,
                            _formatRuntime(movie.runtime), movie.voteAverage)
                        .animate()
                        .fadeIn(delay: 200.ms),
                    if (movie.tagline != null && movie.tagline!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                        child: Text(
                          movie.tagline!.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ).animate().fadeIn(delay: 220.ms),
                    const SizedBox(height: 20),
                    CinePrimaryBtn(
                      height: 52,
                      text: 'WATCH MOVIE',
                      icon: CineIcons.play,
                      scrollTillTop: true,
                      onTap: () {
                        final title = Uri.encodeComponent(movie.title);
                        final releaseDate =
                            Uri.encodeComponent(movie.releaseDate ?? '');
                        context.push(
                          '/play/movie/${movie.id}?title=$title&releaseDate=$releaseDate',
                        );
                      },
                    ).animate().fadeIn(delay: 250.ms),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _sectionHeading(theme, 'SYNOPSIS'),
                    const SizedBox(height: 10),
                    Text(
                      movie.overview.isNotEmpty
                          ? movie.overview
                          : 'No synopsis is currently available.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        height: 1.6,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (movie.genres.isNotEmpty) ...[
                      _sectionHeading(theme, 'GENRES'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: movie.genres.map<Widget>((genre) {
                          return CineChip(
                              text: genre.name.toUpperCase());
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
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
    dynamic movie,
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
          child: movie.backdropPath != null && movie.backdropPath!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: movie.fullBackdropPath,
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
                          SizedBox(
                            width: contentWidth,
                            child: movie.fullLogoPath.isNotEmpty
                                ? CineImage.cachedNetwork(
                                    showLoading: false,
                                    src: movie.fullLogoPath,
                                    height: 110,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                  )
                                : Text(
                                    movie.title,
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 18),
                          _buildMetadataRow(
                            theme,
                            year,
                            _formatRuntime(movie.runtime),
                            movie.voteAverage,
                          ),
                          if (movie.tagline != null &&
                              movie.tagline!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 14.0),
                              child: Text(
                                movie.tagline!.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 11,
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          // WATCH BUTTON
                          SizedBox(
                            width: contentWidth.clamp(0.0, 400.0),
                            child: CinePrimaryBtn(
                              height: 54,
                              text: 'WATCH MOVIE',
                              icon: CineIcons.play,
                              focusNode: _watchButtonFocusNode,
                              scrollTillTop: true,
                              onTap: () {
                                final title =
                                    Uri.encodeComponent(movie.title);
                                final releaseDate = Uri.encodeComponent(
                                    movie.releaseDate ?? '');
                                context.push(
                                  '/play/movie/${movie.id}?title=$title&releaseDate=$releaseDate',
                                );
                              },
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
                            movie.overview.isNotEmpty
                                ? movie.overview
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
                        if (movie.genres.isNotEmpty) ...[
                          _sectionHeading(theme, 'GENRES'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie.genres.map<Widget>((genre) {
                              return CineChip(
                                  text: genre.name.toUpperCase());
                            }).toList(),
                          ),
                          const SizedBox(height: 28),
                        ],
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
