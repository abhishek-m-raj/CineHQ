import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/movie_detail_cubit.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie.dart';

// TV Shows imports
import '../../../tv_shows/presentation/cubits/tv_favorites_cubit.dart';
import '../../../tv_shows/presentation/cubits/tv_show_detail_cubit.dart';
import '../../../tv_shows/presentation/widgets/tv_show_card.dart';
import '../../../tv_shows/domain/entities/tv_show.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isMoviesActive = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAVORITES',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Movie vs TV Show toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                _buildToggleButton(context, 'MOVIES', _isMoviesActive, () {
                  setState(() {
                    _isMoviesActive = true;
                  });
                }),
                const SizedBox(width: 10),
                _buildToggleButton(context, 'TV SHOWS', !_isMoviesActive, () {
                  setState(() {
                    _isMoviesActive = false;
                  });
                }),
              ],
            ),
          ),

          // Grid list of favorites
          Expanded(
            child: _isMoviesActive ? _buildMoviesFavorites(theme) : _buildTVShowsFavorites(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, String text, bool isActive, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.secondary,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesFavorites(ThemeData theme) {
    return BlocBuilder<FavoritesCubit, List<int>>(
      bloc: sl<FavoritesCubit>(),
      builder: (context, favoriteIds) {
        if (favoriteIds.isEmpty) {
          return _buildEmptyState(theme, 'curated list of must-watch cinema');
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: favoriteIds.length,
          itemBuilder: (context, index) {
            final id = favoriteIds[index];
            return _FavoriteMovieGridItem(movieId: id);
          },
        );
      },
    );
  }

  Widget _buildTVShowsFavorites(ThemeData theme) {
    return BlocBuilder<TvFavoritesCubit, List<int>>(
      bloc: sl<TvFavoritesCubit>(),
      builder: (context, favoriteIds) {
        if (favoriteIds.isEmpty) {
          return _buildEmptyState(theme, 'curated list of binge-worthy series');
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: favoriteIds.length,
          itemBuilder: (context, index) {
            final id = favoriteIds[index];
            return _FavoriteTVShowGridItem(tvShowId: id);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, String typeText) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_sharp,
              size: 40,
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'NO FAVORITES YET',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $typeText will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteMovieGridItem extends StatefulWidget {
  final int movieId;

  const _FavoriteMovieGridItem({required this.movieId});

  @override
  State<_FavoriteMovieGridItem> createState() => _FavoriteMovieGridItemState();
}

class _FavoriteMovieGridItemState extends State<_FavoriteMovieGridItem> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MovieDetailCubit, MovieDetailState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is MovieDetailLoaded) {
          final detail = state.movie;
          final movie = Movie(
            id: detail.id,
            title: detail.title,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            releaseDate: detail.releaseDate,
            voteAverage: detail.voteAverage,
            genreIds: detail.genres.map((g) => g.id).toList(),
          );

          return MovieCard(
            movie: movie,
            onTap: () => context.push('/movie/${detail.id}'),
          );
        } else if (state is MovieDetailLoading) {
          return _buildGridSkeletonItem(theme);
        } else if (state is MovieDetailError) {
          return _buildErrorItem(theme);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FavoriteTVShowGridItem extends StatefulWidget {
  final int tvShowId;

  const _FavoriteTVShowGridItem({required this.tvShowId});

  @override
  State<_FavoriteTVShowGridItem> createState() => _FavoriteTVShowGridItemState();
}

class _FavoriteTVShowGridItemState extends State<_FavoriteTVShowGridItem> {
  late final TVShowDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<TVShowDetailCubit>()..loadTVShowDetails(widget.tvShowId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TVShowDetailCubit, TVShowDetailState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is TVShowDetailLoaded) {
          final detail = state.tvShow;
          final tvShow = TVShow(
            id: detail.id,
            name: detail.name,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            firstAirDate: detail.firstAirDate,
            voteAverage: detail.voteAverage,
            genreIds: detail.genres.map((g) => g.id).toList(),
          );

          return TVShowCard(
            tvShow: tvShow,
            onTap: () => context.push('/tv/${detail.id}'),
          );
        } else if (state is TVShowDetailLoading) {
          return _buildGridSkeletonItem(theme);
        } else if (state is TVShowDetailError) {
          return _buildErrorItem(theme);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

Widget _buildGridSkeletonItem(ThemeData theme) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            child: ShimmerLoading(width: double.infinity, height: double.infinity),
          ),
        ),
      ),
      const SizedBox(height: 8),
      const ShimmerLoading(width: 100, height: 14, borderRadius: 2),
      const SizedBox(height: 6),
      const ShimmerLoading(width: 50, height: 10, borderRadius: 2),
    ],
  );
}

Widget _buildErrorItem(ThemeData theme) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: theme.colorScheme.outline),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ),
    padding: const EdgeInsets.all(12),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_sharp, color: theme.colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            'COULD NOT LOAD',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    ),
  );
}
