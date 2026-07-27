import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:responsive/responsive.dart';
import 'package:video/controller.dart';
import 'package:video/models/episode_data.dart';
import 'package:video/style/style.dart';

class EpisodesOverlay extends StatefulWidget {
  final Controller controller;
  final VidStyle style;

  const EpisodesOverlay({super.key, required this.controller, required this.style});

  @override
  State<EpisodesOverlay> createState() => _EpisodesOverlayState();
}

class _EpisodesOverlayState extends State<EpisodesOverlay> {
  bool _wasOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.episodeOverlayController.addListener(_handleOverlayStateChange);
  }

  @override
  void dispose() {
    widget.controller.episodeOverlayController.removeListener(_handleOverlayStateChange);
    super.dispose();
  }

  void _handleOverlayStateChange() {
    final isOpen = widget.controller.episodeOverlayController.isOpen;
    if (_wasOpen && !isOpen) {
      // Focus play button when overlay is closed
      widget.controller.setControlsVisibility(true);
      widget.controller.playBtnFocusNode.requestFocus();
    }
    _wasOpen = isOpen;
  }

  void _closeOverlayAndFocusPlay() {
    widget.controller.episodeOverlayController.close();
    widget.controller.setControlsVisibility(true);
    widget.controller.playBtnFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<EpisodeData?>(
      stream: widget.controller.onEpisodeDataChanged,
      initialData: widget.controller.episodeData,
      builder: (context, epSnapshot) {
        return ListenableBuilder(
          listenable: widget.controller.episodeOverlayController,
          builder: (context, child) {
            final epData = epSnapshot.data ?? widget.controller.episodeData;
            final bool isOpen = widget.controller.episodeOverlayController.isOpen && epData != null;

            return FocusScope(
              canRequestFocus: isOpen,
              child: Focus(
                canRequestFocus: isOpen,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double overlayWidth = ResponsiveValue(
                      screenWidth: constraints.maxWidth,
                      mobile: constraints.maxWidth * 0.85,
                      tablet: constraints.maxWidth * 0.50,
                      desktop: constraints.maxWidth * 0.42,
                    ).value();

                    return IgnorePointer(
                      ignoring: !isOpen,
                      child: Stack(
                        children: [
                          if (isOpen)
                            GestureDetector(
                              onTap: _closeOverlayAndFocusPlay,
                              child: Container(
                                color: Colors.black45,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              ),
                            ),
                          AnimatedPositioned(
                            top: 0,
                            bottom: 0,
                            right: !isOpen ? -overlayWidth : 0,
                            curve: Curves.easeInOutCubic,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              width: overlayWidth,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.96),
                                border: Border(
                                  left: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2), width: 1),
                                ),
                              ),
                              child: SafeArea(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header Back Button List Tile
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: _BackListTile(
                                        isOpen: isOpen,
                                        onTap: _closeOverlayAndFocusPlay,
                                      ),
                                    ),
                                    const Divider(height: 1),
                                    if (epData != null) ...[
                                      // Seasons Selector Row (Matches Details Page design)
                                      if (epData.totalSeasons > 1)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          child: SizedBox(
                                            height: 42,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              itemCount: epData.totalSeasons,
                                              itemBuilder: (context, idx) {
                                                final sNum = idx + 1;
                                                final isSelected = epData.selectedSeason == sNum;
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: _SeasonTabTile(
                                                    seasonNum: sNum,
                                                    isSelected: isSelected,
                                                    isOpen: isOpen,
                                                    onTap: () => epData.onSelectSeason(sNum),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      // Episodes Vertical List
                                      Expanded(
                                        child: epData.isLoadingEpisodes
                                            ? Center(
                                                child: CircularProgressIndicator(color: theme.colorScheme.primary),
                                              )
                                            : ListView.separated(
                                                padding: const EdgeInsets.all(16.0),
                                                itemCount: epData.episodes.length,
                                                separatorBuilder: (context, idx) => const SizedBox(height: 14),
                                                itemBuilder: (context, index) {
                                                  final ep = epData.episodes[index];
                                                  final isCurrent = epData.playingSeason == epData.selectedSeason &&
                                                      ep.episodeNumber == epData.playingEpisode;

                                                  return _EpisodeItemCard(
                                                    key: ValueKey('ep_card_${epData.selectedSeason}_${ep.episodeNumber}'),
                                                    episode: ep,
                                                    isCurrent: isCurrent,
                                                    isOpen: isOpen,
                                                    onTap: () {
                                                      _closeOverlayAndFocusPlay();
                                                      epData.onSelectEpisode(epData.selectedSeason, ep.episodeNumber);
                                                    },
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────── HEADER BACK BUTTON LIST TILE ─────────────────────────

class _BackListTile extends StatefulWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const _BackListTile({required this.isOpen, required this.onTap});

  @override
  State<_BackListTile> createState() => _BackListTileState();
}

class _BackListTileState extends State<_BackListTile> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool f) {
    if (f && mounted) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
    if (mounted) {
      setState(() => _isFocused = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: isActive
            ? theme.colorScheme.surfaceBright
            : theme.colorScheme.surfaceBright.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          focusNode: _focusNode,
          canRequestFocus: widget.isOpen,
          onFocusChange: _onFocusChanged,
          onTap: widget.onTap,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isActive ? theme.colorScheme.primary : Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  'EPISODES',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                    color: isActive ? theme.colorScheme.primary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── FOCUSABLE SEASON TAB TILE (Details Page Style) ────────

class _SeasonTabTile extends StatefulWidget {
  final int seasonNum;
  final bool isSelected;
  final bool isOpen;
  final VoidCallback onTap;

  const _SeasonTabTile({
    required this.seasonNum,
    required this.isSelected,
    required this.isOpen,
    required this.onTap,
  });

  @override
  State<_SeasonTabTile> createState() => _SeasonTabTileState();
}

class _SeasonTabTileState extends State<_SeasonTabTile> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool f) {
    if (f && mounted) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
    if (mounted) {
      setState(() => _isFocused = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: widget.isSelected
            ? theme.colorScheme.primary
            : (isActive
                ? theme.colorScheme.surfaceBright
                : theme.colorScheme.surfaceBright.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          focusNode: _focusNode,
          canRequestFocus: widget.isOpen,
          onFocusChange: _onFocusChanged,
          onTap: widget.onTap,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : (widget.isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline.withValues(alpha: 0.5)),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              'Season ${widget.seasonNum}',
              style: TextStyle(
                color: widget.isSelected
                    ? theme.colorScheme.onPrimary
                    : (isActive
                        ? theme.colorScheme.primary
                        : Colors.white),
                fontWeight: widget.isSelected || isActive
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────── FOCUSABLE EPISODE ITEM CARD (Details Page Style) ──────

class _EpisodeItemCard extends StatefulWidget {
  final EpisodeItem episode;
  final bool isCurrent;
  final bool isOpen;
  final VoidCallback onTap;

  const _EpisodeItemCard({
    super.key,
    required this.episode,
    required this.isCurrent,
    required this.isOpen,
    required this.onTap,
  });

  @override
  State<_EpisodeItemCard> createState() => _EpisodeItemCardState();
}

class _EpisodeItemCardState extends State<_EpisodeItemCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged(bool f) {
    if (f && mounted) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
    if (mounted) {
      setState(() => _isFocused = f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: isActive ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            focusNode: _focusNode,
            canRequestFocus: widget.isOpen,
            onFocusChange: _onFocusChanged,
            onTap: widget.onTap,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.white10,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.isCurrent
                    ? (isActive
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : theme.colorScheme.primaryContainer.withValues(alpha: 0.25))
                    : (isActive
                        ? theme.colorScheme.surfaceBright
                        : theme.colorScheme.surfaceBright.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive
                      ? theme.colorScheme.primary
                      : (widget.isCurrent
                          ? theme.colorScheme.primary.withValues(alpha: 0.7)
                          : theme.colorScheme.outline.withValues(alpha: 0.3)),
                  width: isActive ? 2 : 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thumbnail Image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: SizedBox(
                        width: 130,
                        child: Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: [
                            if (widget.episode.fullStillPath.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: widget.episode.fullStillPath,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, err) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: Icon(Icons.movie_rounded, color: theme.colorScheme.secondary),
                                ),
                              )
                            else
                              Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.movie_rounded, color: theme.colorScheme.secondary),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                            ),
                            if (widget.isCurrent || isActive)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            if (widget.isCurrent)
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PLAYING',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Details Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'E${widget.episode.episodeNumber}',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.episode.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (widget.episode.runtime != null) ...[
                                  Text(
                                    '${widget.episode.runtime} min',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                if (widget.episode.voteAverage > 0) ...[
                                  if (widget.episode.runtime != null)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                                      child: Text(
                                        '•',
                                        style: TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                    ),
                                  const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.episode.voteAverage.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.episode.overview.isNotEmpty
                                  ? widget.episode.overview
                                  : 'No episode overview is currently available.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                height: 1.35,
                                color: Colors.white.withValues(alpha: 0.85),
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
        ),
      ),
    );
  }
}
