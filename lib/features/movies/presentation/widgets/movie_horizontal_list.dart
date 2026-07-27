import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import 'movie_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<Movie> movies;
  final String title;
  final Function(Movie) onMovieTap;
  final EdgeInsetsGeometry? padding;
  final bool showBarIndicator;

  const MovieHorizontalList({
    super.key,
    required this.movies,
    required this.title,
    required this.onMovieTap,
    this.padding,
    this.showBarIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0);
    
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: effectivePadding,
          child: showBarIndicator
              ? Row(
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
                      title.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                )
              : Text(
                  title.toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.0,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 255,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            padding: effectivePadding,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 14),
                child: MovieCard(
                  movie: movie,
                  onTap: () => onMovieTap(movie),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MovieHorizontalListSkeleton extends StatelessWidget {
  final String title;
  final EdgeInsets? padding;

  const MovieHorizontalListSkeleton({
    super.key,
    required this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: effectivePadding.left),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 255,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            physics: const NeverScrollableScrollPhysics(),
            padding: effectivePadding,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(9)),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
