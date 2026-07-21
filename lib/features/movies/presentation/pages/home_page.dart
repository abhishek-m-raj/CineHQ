import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../blocs/movies_bloc.dart';
import '../cubits/movies_list_state.dart';
import '../widgets/movie_hero_banner.dart';
import '../widgets/movie_horizontal_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MoviesBloc _moviesBloc;

  @override
  void initState() {
    super.initState();
    _moviesBloc = sl<MoviesBloc>();

    if (_moviesBloc.state.nowPlayingState is MoviesListInitial) {
      _moviesBloc.add(const LoadNowPlayingMoviesEvent());
    }
    if (_moviesBloc.state.popularState is MoviesListInitial) {
      _moviesBloc.add(const LoadPopularMoviesEvent());
    }
    if (_moviesBloc.state.topRatedState is MoviesListInitial) {
      _moviesBloc.add(const LoadTopRatedMoviesEvent());
    }
  }

  Future<void> _onRefresh() async {
    _moviesBloc.add(const LoadNowPlayingMoviesEvent());
    _moviesBloc.add(const LoadPopularMoviesEvent());
    _moviesBloc.add(const LoadTopRatedMoviesEvent());
    
    // Allow standard delay
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apiKey = dotenv.env['TMDB_API_KEY'];
    final isMock = apiKey == null || apiKey.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CINEHQ.',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          if (isMock)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'DEMO MODE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Featured Section
              BlocBuilder<MoviesBloc, MoviesState>(
                bloc: _moviesBloc,
                buildWhen: (previous, current) => previous.nowPlayingState != current.nowPlayingState,
                builder: (context, state) {
                  final nowPlayingState = state.nowPlayingState;
                  if (nowPlayingState is MoviesListLoading) {
                    return _buildHeroSkeleton(theme);
                  } else if (nowPlayingState is MoviesListLoaded) {
                    final movies = nowPlayingState.movies;
                    if (movies.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'FEATURED',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: movies.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final movie = movies[index];
                              return MovieHeroBanner(
                                movie: movie,
                                onTap: () => context.push('/movie/${movie.id}'),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (nowPlayingState is MoviesListError) {
                    return _buildErrorWidget(theme, nowPlayingState.message, () {
                      _moviesBloc.add(const LoadNowPlayingMoviesEvent());
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 32),
              // Popular Section
              BlocBuilder<MoviesBloc, MoviesState>(
                bloc: _moviesBloc,
                buildWhen: (previous, current) => previous.popularState != current.popularState,
                builder: (context, state) {
                  final popularState = state.popularState;
                  if (popularState is MoviesListLoading) {
                    return const MovieHorizontalListSkeleton(title: 'POPULAR');
                  } else if (popularState is MoviesListLoaded) {
                    return MovieHorizontalList(
                      movies: popularState.movies,
                      title: 'POPULAR',
                      onMovieTap: (movie) => context.push('/movie/${movie.id}'),
                    );
                  } else if (popularState is MoviesListError) {
                    return _buildErrorWidget(theme, popularState.message, () {
                      _moviesBloc.add(const LoadPopularMoviesEvent());
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 32),
              // Top Rated Section
              BlocBuilder<MoviesBloc, MoviesState>(
                bloc: _moviesBloc,
                buildWhen: (previous, current) => previous.topRatedState != current.topRatedState,
                builder: (context, state) {
                  final topRatedState = state.topRatedState;
                  if (topRatedState is MoviesListLoading) {
                    return const MovieHorizontalListSkeleton(title: 'TOP RATED');
                  } else if (topRatedState is MoviesListLoaded) {
                    return MovieHorizontalList(
                      movies: topRatedState.movies,
                      title: 'TOP RATED',
                      onMovieTap: (movie) => context.push('/movie/${movie.id}'),
                    );
                  } else if (topRatedState is MoviesListError) {
                    return _buildErrorWidget(theme, topRatedState.message, () {
                      _moviesBloc.add(const LoadTopRatedMoviesEvent());
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSkeleton(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'FEATURED',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.colorScheme.outline, width: 1),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              child: ShimmerLoading(width: double.infinity, height: 200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ERROR LOADING CONTENT',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                side: BorderSide(color: theme.colorScheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'RETRY',
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
