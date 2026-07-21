import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../blocs/movies_bloc.dart';
import '../widgets/movie_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final MoviesBloc _moviesBloc;

  @override
  void initState() {
    super.initState();
    _moviesBloc = sl<MoviesBloc>();
    _searchController.text = '';
    _moviesBloc.add(const ClearSearchEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<String> _suggestions = const [
    'Inception',
    'Dark Knight',
    'Godfather',
    'Pulp Fiction',
    'Interstellar',
    'Whiplash',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SEARCH',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  _moviesBloc.add(SearchMoviesEvent(val));
                },
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                  prefixIcon: Icon(Icons.search_sharp, color: theme.colorScheme.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_sharp, color: theme.colorScheme.primary),
                          onPressed: () {
                            _searchController.clear();
                            _moviesBloc.add(const ClearSearchEvent());
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
          // Search results or Suggestions
          Expanded(
            child: BlocBuilder<MoviesBloc, MoviesState>(
              bloc: _moviesBloc,
              buildWhen: (previous, current) => previous.searchState != current.searchState,
              builder: (context, state) {
                final searchState = state.searchState;
                if (searchState is MovieSearchInitial) {
                  return _buildSuggestions(theme);
                } else if (searchState is MovieSearchLoading) {
                  return _buildGridSkeleton(theme);
                } else if (searchState is MovieSearchLoaded) {
                  final movies = searchState.movies;
                  if (movies.isEmpty) {
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
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        searchState.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
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
            'Discover black and white classics, award-winning dramas, and modern space epics.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestions.map((s) {
              return ActionChip(
                label: Text(s.toUpperCase()),
                onPressed: () {
                  _searchController.text = s;
                  _moviesBloc.add(SearchMoviesEvent(s));
                  setState(() {});
                },
                backgroundColor: theme.colorScheme.surface,
                side: BorderSide(color: theme.colorScheme.outline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
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
      },
    );
  }
}
