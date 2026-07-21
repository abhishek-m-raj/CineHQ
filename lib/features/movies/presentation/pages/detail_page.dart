import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../cubits/movie_detail_cubit.dart';
import '../cubits/favorites_cubit.dart';

class DetailPage extends StatefulWidget {
  final int movieId;

  const DetailPage({
    super.key,
    required this.movieId,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final MovieDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<MovieDetailCubit>()..loadMovieDetails(widget.movieId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatRuntime(int? minutes) {
    if (minutes == null || minutes == 0) return '—';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<MovieDetailCubit, MovieDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const _DetailLoadingWidget();
          } else if (state is MovieDetailLoaded) {
            final movie = state.movie;
            final year = movie.releaseDate != null && movie.releaseDate!.length >= 4
                ? movie.releaseDate!.substring(0, 4)
                : '—';

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Large Backdrop AppBar
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  stretch: true,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: theme.brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.8),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_sharp,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: BlocBuilder<FavoritesCubit, List<int>>(
                        bloc: sl<FavoritesCubit>(),
                        builder: (context, favoriteIds) {
                          final isFavorite = favoriteIds.contains(movie.id);
                          return CircleAvatar(
                            backgroundColor: theme.brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.8),
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite_sharp : Icons.favorite_border_sharp,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              onPressed: () {
                                sl<FavoritesCubit>().toggleFavorite(movie.id);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                    ],
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
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                              ),
                        // Gradient overlay for visual aesthetics
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
                                stops: const [0.4, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Movie Info Box
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (movie.tagline != null && movie.tagline!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              movie.tagline!.toUpperCase(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        Text(
                          movie.title,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 26,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.colorScheme.primary, width: 1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                year,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildDotDivider(theme),
                            Text(
                              _formatRuntime(movie.runtime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            _buildDotDivider(theme),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_sharp,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '/10',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        Text(
                          'SYNOPSIS',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          movie.overview.isNotEmpty ? movie.overview : 'No synopsis is currently available.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            height: 1.6,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (movie.genres.isNotEmpty) ...[
                          Text(
                            'GENRES',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: movie.genres.map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.colorScheme.outline),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  genre.name.toUpperCase(),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is MovieDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FAILED TO LOAD MOVIE DETAILS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        _cubit.loadMovieDetails(widget.movieId);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
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

  Widget _buildDotDivider(ThemeData theme) {
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
          const ShimmerLoading(width: double.infinity, height: 300, borderRadius: 0),
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
                    const ShimmerLoading(width: 40, height: 16, borderRadius: 2),
                    _buildDot(theme),
                    const ShimmerLoading(width: 60, height: 16, borderRadius: 2),
                    _buildDot(theme),
                    const ShimmerLoading(width: 50, height: 16, borderRadius: 2),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const ShimmerLoading(width: 80, height: 14, borderRadius: 2),
                const SizedBox(height: 12),
                const ShimmerLoading(width: double.infinity, height: 14, borderRadius: 2),
                const SizedBox(height: 8),
                const ShimmerLoading(width: double.infinity, height: 14, borderRadius: 2),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 200, height: 14, borderRadius: 2),
                const SizedBox(height: 24),
                const ShimmerLoading(width: 80, height: 14, borderRadius: 2),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    3,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: ShimmerLoading(width: 70, height: 24, borderRadius: 4),
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

  Widget _buildDot(ThemeData theme) {
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
