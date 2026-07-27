import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/tv_show.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class TVShowCard extends StatefulWidget {
  final TVShow tvShow;
  final VoidCallback onTap;
  final FocusNode? focusNode;
  final bool autoFocus;

  const TVShowCard({
    super.key,
    required this.tvShow,
    required this.onTap,
    this.focusNode,
    this.autoFocus = false,
  });

  @override
  State<TVShowCard> createState() => _TVShowCardState();
}

class _TVShowCardState extends State<TVShowCard> {
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isInternalFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'TVShowCard_${widget.tvShow.id}');
      _isInternalFocusNode = true;
    }
  }

  @override
  void didUpdateWidget(TVShowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _isInternalFocusNode = false;
      } else {
        _focusNode = FocusNode(debugLabel: 'TVShowCard_${widget.tvShow.id}');
        _isInternalFocusNode = true;
      }
    }
  }

  @override
  void dispose() {
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged(bool isFocused) {
    setState(() {
      _isFocused = isFocused;
    });
    if (isFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = widget.tvShow.firstAirDate != null && widget.tvShow.firstAirDate!.length >= 4
        ? widget.tvShow.firstAirDate!.substring(0, 4)
        : '—';
    final isActive = _isFocused || _isHovered;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autoFocus,
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
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: isActive ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.25),
                        width: isActive ? 2.5 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.45),
                                blurRadius: 14,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
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
                          widget.tvShow.posterPath != null && widget.tvShow.posterPath!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.tvShow.fullPosterPath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => const ShimmerLoading(
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  errorWidget: (context, url, error) => _buildPlaceholder(theme),
                                )
                              : _buildPlaceholder(theme),

                          // Gradient dark overlay on focus/hover
                          AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.65),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Rating Badge (Top Right)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: Color(0xFFFFB800),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.tvShow.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.tvShow.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      year,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          widget.tvShow.name,
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
