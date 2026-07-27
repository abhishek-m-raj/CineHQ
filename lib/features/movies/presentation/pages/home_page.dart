import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/media_type_switcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../blocs/movies_bloc.dart';
import '../cubits/movies_list_state.dart';
import '../widgets/movie_spotlights.dart';
import '../widgets/movie_horizontal_list.dart';

// TV Shows imports
import '../../../tv_shows/presentation/blocs/tv_shows_bloc.dart';
import '../../../tv_shows/presentation/cubits/tv_shows_list_state.dart';
import '../../../tv_shows/presentation/widgets/tv_show_spotlights.dart';
import '../../../tv_shows/presentation/widgets/tv_show_horizontal_list.dart';
import '../../../video_player/presentation/widgets/continue_watching_section.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final MoviesBloc _moviesBloc;
  late final TVShowsBloc _tvShowsBloc;
  bool _isMoviesActive = true;

  @override
  void initState() {
    super.initState();
    _moviesBloc = sl<MoviesBloc>();
    _tvShowsBloc = sl<TVShowsBloc>();

    // Load Movies
    if (_moviesBloc.state.nowPlayingState is MoviesListInitial) {
      _moviesBloc.add(const LoadNowPlayingMoviesEvent());
    }
    if (_moviesBloc.state.popularState is MoviesListInitial) {
      _moviesBloc.add(const LoadPopularMoviesEvent());
    }
    if (_moviesBloc.state.topRatedState is MoviesListInitial) {
      _moviesBloc.add(const LoadTopRatedMoviesEvent());
    }

    // Load TV Shows
    if (_tvShowsBloc.state.airingTodayState is TVShowsListInitial) {
      _tvShowsBloc.add(const LoadAiringTodayTVShowsEvent());
    }
    if (_tvShowsBloc.state.popularState is TVShowsListInitial) {
      _tvShowsBloc.add(const LoadPopularTVShowsEvent());
    }
    if (_tvShowsBloc.state.topRatedState is TVShowsListInitial) {
      _tvShowsBloc.add(const LoadTopRatedTVShowsEvent());
    }
  }

  Future<void> _onRefresh() async {
    if (_isMoviesActive) {
      _moviesBloc.add(const LoadNowPlayingMoviesEvent());
      _moviesBloc.add(const LoadPopularMoviesEvent());
      _moviesBloc.add(const LoadTopRatedMoviesEvent());
    } else {
      _tvShowsBloc.add(const LoadAiringTodayTVShowsEvent());
      _tvShowsBloc.add(const LoadPopularTVShowsEvent());
      _tvShowsBloc.add(const LoadTopRatedTVShowsEvent());
    }
    
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CINEHQ',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 12),
            MediaTypeSwitcher(
              isMoviesActive: _isMoviesActive,
              onChanged: (isMovies) {
                setState(() {
                  _isMoviesActive = isMovies;
                });
              },
            ),
          ],
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
              // Conditional Display depending on selection
              if (_isMoviesActive) ..._buildMoviesContent(theme) else ..._buildTVShowsContent(theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMoviesContent(ThemeData theme) {
    return [
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
            return MovieSpotlights(movies: movies.take(10).toList());
          } else if (nowPlayingState is MoviesListError) {
            return _buildErrorWidget(theme, nowPlayingState.message, () {
              _moviesBloc.add(const LoadNowPlayingMoviesEvent());
            });
          }
          return const SizedBox.shrink();
        },
      ),
      const SizedBox(height: 28),
      const ContinueWatchingSection(filterMediaType: 'movie'),
      const SizedBox(height: 28),
      // Popular Section
      BlocBuilder<MoviesBloc, MoviesState>(
        bloc: _moviesBloc,
        buildWhen: (previous, current) => previous.popularState != current.popularState,
        builder: (context, state) {
          final popularState = state.popularState;
          if (popularState is MoviesListLoading) {
            return const MovieHorizontalListSkeleton(title: 'POPULAR MOVIES');
          } else if (popularState is MoviesListLoaded) {
            return MovieHorizontalList(
              movies: popularState.movies,
              title: 'POPULAR MOVIES',
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
            return const MovieHorizontalListSkeleton(title: 'TOP RATED MOVIES');
          } else if (topRatedState is MoviesListLoaded) {
            return MovieHorizontalList(
              movies: topRatedState.movies,
              title: 'TOP RATED MOVIES',
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
    ];
  }

  List<Widget> _buildTVShowsContent(ThemeData theme) {
    return [
      // Featured TV Shows
      BlocBuilder<TVShowsBloc, TVShowsState>(
        bloc: _tvShowsBloc,
        buildWhen: (previous, current) => previous.airingTodayState != current.airingTodayState,
        builder: (context, state) {
          final airingTodayState = state.airingTodayState;
          if (airingTodayState is TVShowsListLoading) {
            return _buildHeroSkeleton(theme);
          } else if (airingTodayState is TVShowsListLoaded) {
            final tvShows = airingTodayState.tvShows;
            if (tvShows.isEmpty) return const SizedBox.shrink();
            return TVShowSpotlights(tvShows: tvShows.take(10).toList());
          } else if (airingTodayState is TVShowsListError) {
            return _buildErrorWidget(theme, airingTodayState.message, () {
              _tvShowsBloc.add(const LoadAiringTodayTVShowsEvent());
            });
          }
          return const SizedBox.shrink();
        },
      ),
      const SizedBox(height: 28),
      const ContinueWatchingSection(filterMediaType: 'tv'),
      const SizedBox(height: 28),
      // Popular TV Shows
      BlocBuilder<TVShowsBloc, TVShowsState>(
        bloc: _tvShowsBloc,
        buildWhen: (previous, current) => previous.popularState != current.popularState,
        builder: (context, state) {
          final popularState = state.popularState;
          if (popularState is TVShowsListLoading) {
            return const TVShowHorizontalListSkeleton(title: 'POPULAR TV SHOWS');
          } else if (popularState is TVShowsListLoaded) {
            return TVShowHorizontalList(
              tvShows: popularState.tvShows,
              title: 'POPULAR TV SHOWS',
              onTVShowTap: (tvShow) => context.push('/tv/${tvShow.id}'),
            );
          } else if (popularState is TVShowsListError) {
            return _buildErrorWidget(theme, popularState.message, () {
              _tvShowsBloc.add(const LoadPopularTVShowsEvent());
            });
          }
          return const SizedBox.shrink();
        },
      ),
      const SizedBox(height: 32),
      // Top Rated TV Shows
      BlocBuilder<TVShowsBloc, TVShowsState>(
        bloc: _tvShowsBloc,
        buildWhen: (previous, current) => previous.topRatedState != current.topRatedState,
        builder: (context, state) {
          final topRatedState = state.topRatedState;
          if (topRatedState is TVShowsListLoading) {
            return const TVShowHorizontalListSkeleton(title: 'TOP RATED TV SHOWS');
          } else if (topRatedState is TVShowsListLoaded) {
            return TVShowHorizontalList(
              tvShows: topRatedState.tvShows,
              title: 'TOP RATED TV SHOWS',
              onTVShowTap: (tvShow) => context.push('/tv/${tvShow.id}'),
            );
          } else if (topRatedState is TVShowsListError) {
            return _buildErrorWidget(theme, topRatedState.message, () {
              _tvShowsBloc.add(const LoadTopRatedTVShowsEvent());
            });
          }
          return const SizedBox.shrink();
        },
      ),
      const SizedBox(height: 32),
    ];
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
