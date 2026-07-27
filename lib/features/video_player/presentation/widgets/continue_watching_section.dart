import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/continue_watching_item.dart';
import '../cubits/continue_watching_cubit.dart';

class ContinueWatchingSection extends StatelessWidget {
  final String? filterMediaType; // 'movie', 'tv', or null for all

  const ContinueWatchingSection({
    super.key,
    this.filterMediaType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ContinueWatchingCubit, ContinueWatchingState>(
      builder: (context, state) {
        final items = filterMediaType == null
            ? state.items
            : state.items.where((i) => i.mediaType == filterMediaType).toList();

        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                        'CONTINUE WATCHING',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${items.length} ${items.length == 1 ? 'ITEM' : 'ITEMS'}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 195,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: ContinueWatchingCard(
                      item: item,
                      onTap: () => _onResumeItem(context, item),
                      onRemove: () => context.read<ContinueWatchingCubit>().removeItem(item.key),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _onResumeItem(BuildContext context, ContinueWatchingItem item) {
    final title = Uri.encodeComponent(item.title);
    final releaseDate = Uri.encodeComponent(item.releaseDate);
    final posterPath = Uri.encodeComponent(item.posterPath ?? '');
    final backdropPath = Uri.encodeComponent(item.backdropPath ?? '');

    if (item.mediaType == 'movie') {
      context.push(
        '/play/movie/${item.tmdbId}?title=$title&releaseDate=$releaseDate&posterPath=$posterPath&backdropPath=$backdropPath',
      );
    } else {
      final season = item.seasonNumber ?? 1;
      final episode = item.episodeNumber ?? 1;
      context.push(
        '/play/tv/${item.tmdbId}/$season/$episode?title=$title&firstAirDate=$releaseDate&posterPath=$posterPath&backdropPath=$backdropPath',
      );
    }
  }
}

class ContinueWatchingCard extends StatefulWidget {
  final ContinueWatchingItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<ContinueWatchingCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
    if (isFocused) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;
    final item = widget.item;

    final badgeText = item.mediaType == 'tv'
        ? 'S${item.seasonNumber ?? 1}:E${item.episodeNumber ?? 1}'
        : 'MOVIE';

    final imagePath = item.fullBackdropPath.isNotEmpty
        ? item.fullBackdropPath
        : item.fullPosterPath;

    return Focus(
      focusNode: _focusNode,
      onFocusChange: _onFocusChanged,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: isActive ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Thumbnail Container
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: isActive ? 2.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isActive ? 7.5 : 9),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imagePath.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imagePath,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const ShimmerLoading(
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  errorWidget: (context, url, error) => _buildPlaceholder(theme),
                                )
                              : _buildPlaceholder(theme),

                          // Dark Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                          ),

                          // Media Type / Episode Badge (Top Left)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          // Remove Button (Top Right)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: widget.onRemove,
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Center Play Icon Button
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? theme.colorScheme.primary
                                    : Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                          blurRadius: 10,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                size: 24,
                                color: isActive ? theme.colorScheme.onPrimary : Colors.white,
                              ),
                            ),
                          ),

                          // Progress Bar at Bottom of Thumbnail
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 4,
                              color: Colors.white24,
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: item.progressPercentage,
                                child: Container(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 12.5,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Time Left & Position Subtitle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.formattedTimeLeft,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: theme.colorScheme.primary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(item.progressPercentage * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          widget.item.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
