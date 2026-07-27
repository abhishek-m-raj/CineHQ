import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cineui/cineui.dart';

import '../../../../core/widgets/media_type_switcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../blocs/movies_bloc.dart';
import '../widgets/movie_card.dart';

// TV Shows imports
import '../../../tv_shows/presentation/blocs/tv_shows_bloc.dart';
import '../../../tv_shows/presentation/widgets/tv_show_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final MoviesBloc _moviesBloc;
  late final TVShowsBloc _tvShowsBloc;
  bool _isMoviesActive = true;

  @override
  void initState() {
    super.initState();
    _moviesBloc = sl<MoviesBloc>();
    _tvShowsBloc = sl<TVShowsBloc>();
    _searchController.text = '';
    _moviesBloc.add(const ClearSearchEvent());
    _tvShowsBloc.add(const ClearTVShowSearchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<String> _movieSuggestions = const [
    'Inception',
    'Dark Knight',
    'Godfather',
    'Pulp Fiction',
    'Interstellar',
    'Whiplash',
  ];

  final List<String> _tvShowSuggestions = const [
    'Breaking Bad',
    'Stranger Things',
    'Game of Thrones',
    'Chernobyl',
    'Last of Us',
    'The Bear',
  ];

  void _onSearchChanged(String val) {
    if (_isMoviesActive) {
      _moviesBloc.add(SearchMoviesEvent(val));
    } else {
      _tvShowsBloc.add(SearchTVShowsEvent(val));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    if (_isMoviesActive) {
      _moviesBloc.add(const ClearSearchEvent());
    } else {
      _tvShowsBloc.add(const ClearTVShowSearchEvent());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Image.asset(
          'assets/logo_banner.png',
          height: 50,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MediaTypeSwitcher(
              isMoviesActive: _isMoviesActive,
              onChanged: (isMovies) {
                setState(() {
                  _isMoviesActive = isMovies;
                });
                _clearSearch();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: CineSpacing.s4,
              vertical: CineSpacing.s2,
            ),
            child: CineTextField(
              controller: _searchController,
              onChange: (val) {
                _onSearchChanged(val);
                setState(() {});
              },
              hintText: _isMoviesActive
                  ? 'Search movies...'
                  : 'Search TV shows...',
              icon: CineIcons.search,
            ),
          ),

          // Search results or Suggestions
          Expanded(
            child: _isMoviesActive
                ? _buildMoviesSearchBody(theme)
                : _buildTVShowsSearchBody(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesSearchBody(ThemeData theme) {
    return BlocBuilder<MoviesBloc, MoviesState>(
      bloc: _moviesBloc,
      buildWhen: (previous, current) =>
          previous.searchState != current.searchState,
      builder: (context, state) {
        final searchState = state.searchState;
        if (searchState is MovieSearchInitial) {
          return _buildSuggestions(theme, _movieSuggestions);
        } else if (searchState is MovieSearchLoading) {
          return _buildGridSkeleton(theme);
        } else if (searchState is MovieSearchLoaded) {
          final movies = searchState.movies;
          if (movies.isEmpty) {
            return _buildNoResults(theme);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              childAspectRatio: 130 / 237,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () => context.push('/movie/${movie.id}'),
              );
            },
          );
        } else if (searchState is MovieSearchError) {
          return _buildError(theme, searchState.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTVShowsSearchBody(ThemeData theme) {
    return BlocBuilder<TVShowsBloc, TVShowsState>(
      bloc: _tvShowsBloc,
      buildWhen: (previous, current) =>
          previous.searchState != current.searchState,
      builder: (context, state) {
        final searchState = state.searchState;
        if (searchState is TVShowSearchInitial) {
          return _buildSuggestions(theme, _tvShowSuggestions);
        } else if (searchState is TVShowSearchLoading) {
          return _buildGridSkeleton(theme);
        } else if (searchState is TVShowSearchLoaded) {
          final tvShows = searchState.tvShows;
          if (tvShows.isEmpty) {
            return _buildNoResults(theme);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              childAspectRatio: 130 / 237,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            itemCount: tvShows.length,
            itemBuilder: (context, index) {
              final tvShow = tvShows[index];
              return TVShowCard(
                tvShow: tvShow,
                onTap: () => context.push('/tv/${tvShow.id}'),
              );
            },
          );
        } else if (searchState is TVShowSearchError) {
          return _buildError(theme, searchState.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Text(
        'NO RESULTS FOUND',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.secondary,
          fontSize: 11,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme, List<String> suggestions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'EXPLORE THE ARCHIVES',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isMoviesActive
                ? 'Discover black and white classics, award-winning dramas, and modern space epics.'
                : 'Discover binge-worthy series, critically acclaimed television, and classic shows.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((s) {
              return ActionChip(
                label: Text(s.toUpperCase()),
                onPressed: () {
                  _searchController.text = s;
                  _onSearchChanged(s);
                  setState(() {});
                },
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSkeleton(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        childAspectRatio: 130 / 237,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
      ),
      itemCount: 18,
      itemBuilder: (context, index) {
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
                  child: ShimmerLoading(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 100, height: 14, borderRadius: 2),
            const SizedBox(height: 6),
            const ShimmerLoading(width: 50, height: 10, borderRadius: 2),
          ],
        );
      },
    );
  }
}
