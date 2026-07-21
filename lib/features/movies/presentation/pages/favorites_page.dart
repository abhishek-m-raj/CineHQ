import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/movie_detail_cubit.dart';
import '../widgets/movie_card.dart';
import '../../domain/entities/movie.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

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
      body: BlocBuilder<FavoritesCubit, List<int>>(
        bloc: sl<FavoritesCubit>(),
        builder: (context, favoriteIds) {
          if (favoriteIds.isEmpty) {
            return _buildEmptyState(theme);
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
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
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
              'Your curated list of must-watch cinema will appear here.',
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
        } else if (state is MovieDetailError) {
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
        return const SizedBox.shrink();
      },
    );
  }
}
