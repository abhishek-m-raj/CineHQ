import 'package:flutter/material.dart';
import '../../domain/entities/tv_show.dart';
import 'tv_show_card.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class TVShowHorizontalList extends StatelessWidget {
  final List<TVShow> tvShows;
  final String title;
  final Function(TVShow) onTVShowTap;

  const TVShowHorizontalList({
    super.key,
    required this.tvShows,
    required this.title,
    required this.onTVShowTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (tvShows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tvShows.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final tvShow = tvShows[index];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 14),
                child: TVShowCard(
                  tvShow: tvShow,
                  onTap: () => onTVShowTap(tvShow),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TVShowHorizontalListSkeleton extends StatelessWidget {
  final String title;

  const TVShowHorizontalListSkeleton({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 1,
                          ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
