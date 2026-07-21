import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/tv_show.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class TVShowCard extends StatelessWidget {
  final TVShow tvShow;
  final VoidCallback onTap;

  const TVShowCard({
    super.key,
    required this.tvShow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = tvShow.firstAirDate != null && tvShow.firstAirDate!.length >= 4
        ? tvShow.firstAirDate!.substring(0, 4)
        : '—';

    return GestureDetector(
      onTap: onTap,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: tvShow.posterPath != null && tvShow.posterPath!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: tvShow.fullPosterPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => const ShimmerLoading(
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholder(theme),
                      )
                    : _buildPlaceholder(theme),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tvShow.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 14,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                year,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star_sharp,
                    size: 13,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    tvShow.voteAverage.toStringAsFixed(1),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          tvShow.name,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
