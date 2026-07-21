import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:cineui/cineui.dart';
import 'package:responsive/responsive.dart';
import '../../domain/entities/movie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/datasources/movie_remote_data_source.dart';

class Spotlight extends StatefulWidget {
  final int spotlightNumber;
  final Movie movie;
  final FocusNode? watchNowFocusNode;
  final FocusNode? moreInfoFocusNode;

  const Spotlight({
    super.key,
    required this.spotlightNumber,
    required this.movie,
    this.watchNowFocusNode,
    this.moreInfoFocusNode,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  Future<ColorScheme>? _colorSchemeFuture;
  String? _logoUrl;
  bool _isLoadingLogo = true;

  @override
  void initState() {
    super.initState();
    if (widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty) {
      _colorSchemeFuture = ColorScheme.fromImageProvider(
        provider: CachedNetworkImageProvider(widget.movie.fullBackdropPath),
      );
    }
    _loadLogo();
  }

  void _loadLogo() {
    setState(() {
      _isLoadingLogo = true;
      _logoUrl = null;
    });
    sl<MovieRemoteDataSource>()
        .getMovieDetails(widget.movie.id)
        .then((detail) {
          if (mounted) {
            setState(() {
              _logoUrl = detail.fullLogoPath;
              _isLoadingLogo = false;
            });
          }
        })
        .catchError((_) {
          if (mounted) {
            setState(() {
              _isLoadingLogo = false;
            });
          }
        });
  }

  @override
  void didUpdateWidget(covariant Spotlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movie.id != oldWidget.movie.id) {
      _loadLogo();
    }
    if (widget.movie.backdropPath != oldWidget.movie.backdropPath) {
      if (widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty) {
        setState(() {
          _colorSchemeFuture = ColorScheme.fromImageProvider(
            provider: CachedNetworkImageProvider(widget.movie.fullBackdropPath),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CineColorScheme.surface,
        image: widget.movie.backdropPath != null && widget.movie.backdropPath!.isNotEmpty
            ? CineDecorationImage.cachedNetwork(widget.movie.fullBackdropPath)
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: shadows()),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: CineSpacing.s4, vertical: CineSpacing.s3),
              child: content(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget shadows() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                CineColorScheme.surface.putOpacity(0.9),
                CineColorScheme.surface.putOpacity(0.4),
                CineColorScheme.transparent,
              ],
              stops: const [0.0, 0.4, 0.8],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                CineColorScheme.surface,
                CineColorScheme.surface.putOpacity(0.3),
                CineColorScheme.transparent,
              ],
              stops: const [0.0, 0.25, 0.6],
            ),
          ),
        ),
      ],
    );
  }

  Widget content(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final year = widget.movie.releaseDate != null && widget.movie.releaseDate!.length >= 4
        ? widget.movie.releaseDate!.substring(0, 4)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(height: CineSpacing.s2),
        if (_colorSchemeFuture != null)
          FutureBuilder<ColorScheme>(
            future: _colorSchemeFuture,
            builder: (context, asyncSnapshot) {
              return Container(
                decoration: BoxDecoration(
                  color: asyncSnapshot.data?.primary.withValues(alpha: 0.3) ?? Colors.white24,
                  borderRadius: BorderRadius.circular(CineSpacing.s2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: CineText(
                  '#${widget.spotlightNumber} Featured',
                  style: CineTextStyles.h6.copyWith(
                    color: asyncSnapshot.data?.onPrimary.withValues(alpha: 0.8) ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(CineSpacing.s2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: CineText(
              '#${widget.spotlightNumber} Featured',
              style: CineTextStyles.h6.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        SizedBox(height: CineSpacing.s3),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoadingLogo
              ? SizedBox(
                  key: const ValueKey('loading'),
                  height: ResponsiveValue<double>(screenWidth: screenWidth, mobile: 70, desktop: 90).value(),
                )
              : (_logoUrl != null && _logoUrl!.isNotEmpty)
                  ? Padding(
                      key: const ValueKey('logo'),
                      padding: EdgeInsets.only(bottom: CineSpacing.s2),
                      child: CineImage.cachedNetwork(
                        src: _logoUrl,
                        showLoading: false,
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.contain,
                        height: ResponsiveValue<double>(screenWidth: screenWidth, mobile: 70, desktop: 90).value(),
                        width: ResponsiveValue<double>(
                          screenWidth: screenWidth,
                          mobile: screenWidth * 0.7,
                          desktop: screenWidth * 0.45,
                        ).value(),
                      ),
                    )
                  : SizedBox(
                      key: const ValueKey('title'),
                      width: ResponsiveValue<double>(
                        screenWidth: screenWidth,
                        mobile: screenWidth * 0.85,
                        desktop: screenWidth * 0.5,
                      ).value(),
                      child: CineText(
                        widget.movie.title,
                        style: CineTextStyles.h2.copyWith(
                          fontSize: ResponsiveValue<double>(
                            screenWidth: screenWidth,
                            mobile: 22.0,
                            tablet: 30.0,
                            desktop: 38.0,
                          ).value(),
                          height: 1.1,
                          shadows: [
                            Shadow(color: Colors.black.withValues(alpha: 0.8), offset: const Offset(0, 2), blurRadius: 8),
                          ],
                        ),
                        maxLines: 2,
                      ),
                    ),
        ),
        SizedBox(height: CineSpacing.s4),

        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: CineSpacing.s2,
          runSpacing: 4,
          children: [
            _infoChip('MOVIE'),
            if (widget.movie.voteAverage != 0.0)
              _infoItem('${widget.movie.voteAverage.toStringAsFixed(1)} ★', CineIcons.star),
            _infoItem(year, CineIcons.calendar),
          ],
        ),
        SizedBox(height: CineSpacing.s3),

        descBox(context),
        SizedBox(height: CineSpacing.s4),

        Row(
          children: [
            CinePrimaryBtn(
              text: "Watch Now",
              icon: CineIcons.play,
              height: 40,
              focusNode: widget.watchNowFocusNode,
              scrollTillTop: true,
              onTap: () {
                context.push('/play/movie/${widget.movie.id}');
              },
            ),
            SizedBox(width: CineSpacing.s2),
            CineSecondaryBtn(
              text: "More Info",
              icon: CineIcons.info,
              height: 40,
              focusNode: widget.moreInfoFocusNode,
              scrollTillTop: true,
              onTap: () {
                context.push('/movie/${widget.movie.id}');
              },
            ),
          ],
        ),
        SizedBox(height: CineSpacing.s6),
      ],
    );
  }

  Widget descBox(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveValue<double>(
          screenWidth: screenWidth,
          mobile: screenWidth * 0.85,
          tablet: screenWidth * 0.5,
          desktop: screenWidth * 0.4,
        ).value(),
      ),
      child: CineText(
        widget.movie.overview,
        style: CineTextStyles.b2.copyWith(color: CineColorScheme.onSurface.putOpacity(0.7)),
        maxLines: ResponsiveValue<int>(screenWidth: screenWidth, mobile: 2, tablet: 2, desktop: 2).value(),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: CineColorScheme.primary.putOpacity(0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: CineText(text, style: CineTextStyles.h6.copyWith(color: CineColorScheme.primary)),
    );
  }

  Widget _infoItem(String text, IconSource icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CineIcon(
          icon: icon,
          color: CineColorScheme.onSurface.putOpacity(0.5),
          size: (((CineTextStyles.h5.fontSize) ?? 12) * 1.2),
          strokeWidth: 3,
        ),
        const SizedBox(width: 3),
        CineText(text, style: CineTextStyles.h6.copyWith(color: CineColorScheme.onSurface.putOpacity(0.8))),
      ],
    );
  }
}

class MovieSpotlights extends StatefulWidget {
  final List<Movie> movies;

  const MovieSpotlights({super.key, required this.movies});

  @override
  MovieSpotlightsState createState() => MovieSpotlightsState();
}

class MovieSpotlightsState extends State<MovieSpotlights> {
  final PageController controller = PageController();
  late final Timer periodicTimer;
  late List<FocusNode> _watchNowFocusNodes;
  late List<FocusNode> _moreInfoFocusNodes;
  final FocusNode _parentFocusNode = FocusNode(canRequestFocus: false);
  bool _watchNowHadFocus = false;
  bool _moreInfoHadFocus = false;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _watchNowFocusNodes = List.generate(
      widget.movies.length,
      (index) => FocusNode(debugLabel: 'MovieWatchNow $index')..onKeyEvent = _onWatchNowKeyEvent,
    );
    _moreInfoFocusNodes = List.generate(
      widget.movies.length,
      (index) => FocusNode(debugLabel: 'MovieMoreInfo $index')..onKeyEvent = _onMoreInfoKeyEvent,
    );
    periodicTimer = Timer.periodic(const Duration(seconds: 10), (timer) => next());
  }

  KeyEventResult _onWatchNowKeyEvent(FocusNode node, KeyEvent event) {
    if (Device.isTv && event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      back();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onMoreInfoKeyEvent(FocusNode node, KeyEvent event) {
    if (Device.isTv && event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
      next();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void didUpdateWidget(covariant MovieSpotlights oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.movies.length != oldWidget.movies.length) {
      for (final node in _watchNowFocusNodes) {
        node.dispose();
      }
      for (final node in _moreInfoFocusNodes) {
        node.dispose();
      }
      _watchNowFocusNodes = List.generate(
        widget.movies.length,
        (index) => FocusNode(debugLabel: 'MovieWatchNow $index')..onKeyEvent = _onWatchNowKeyEvent,
      );
      _moreInfoFocusNodes = List.generate(
        widget.movies.length,
        (index) => FocusNode(debugLabel: 'MovieMoreInfo $index')..onKeyEvent = _onMoreInfoKeyEvent,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    periodicTimer.cancel();
    _parentFocusNode.dispose();
    for (final node in _watchNowFocusNodes) {
      node.dispose();
    }
    for (final node in _moreInfoFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkFocus() {
    _watchNowHadFocus = _watchNowFocusNodes.any((node) => node.hasFocus);
    _moreInfoHadFocus = _moreInfoFocusNodes.any((node) => node.hasFocus);
  }

  void next() async {
    if (!controller.hasClients || _isAnimating) {
      return;
    }
    _checkFocus();
    if (mounted) {
      _isAnimating = true;
      final int page = (controller.page ?? 0).round();
      final int lastIndex = widget.movies.length - 1;
      final int targetPage = page != lastIndex ? page + 1 : 0;

      await controller.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutSine,
      );

      if (mounted) {
        _isAnimating = false;
        if (_watchNowHadFocus) {
          _watchNowFocusNodes[targetPage].requestFocus();
        } else if (_moreInfoHadFocus) {
          _moreInfoFocusNodes[targetPage].requestFocus();
        } else if (_parentFocusNode.hasFocus && !Device.isTv) {
          _watchNowFocusNodes[targetPage].requestFocus();
        }
        _watchNowHadFocus = false;
        _moreInfoHadFocus = false;
      }
    }
  }

  void back() async {
    if (!controller.hasClients || _isAnimating) {
      return;
    }
    _checkFocus();
    if (mounted) {
      _isAnimating = true;
      final int page = (controller.page ?? 0).round();
      final int lastIndex = widget.movies.length - 1;
      final int targetPage = page != 0 ? page - 1 : lastIndex;

      await controller.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutSine,
      );

      if (mounted) {
        _isAnimating = false;
        if (_watchNowHadFocus) {
          _watchNowFocusNodes[targetPage].requestFocus();
        } else if (_moreInfoHadFocus) {
          _moreInfoFocusNodes[targetPage].requestFocus();
        } else if (_parentFocusNode.hasFocus && !Device.isTv) {
          _watchNowFocusNodes[targetPage].requestFocus();
        }
        _watchNowHadFocus = false;
        _moreInfoHadFocus = false;
      }
    }
  }

  Widget view(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      children: [
        Focus(
          focusNode: _parentFocusNode,
          child: PageView.builder(
            controller: controller,
            itemCount: widget.movies.length,
            onPageChanged: (int index) {
              if (_isAnimating) return;
              if (_watchNowHadFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (index < _watchNowFocusNodes.length && mounted) {
                    _watchNowFocusNodes[index].requestFocus();
                  }
                });
                _watchNowHadFocus = false;
              } else if (_moreInfoHadFocus) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (index < _moreInfoFocusNodes.length && mounted) {
                    _moreInfoFocusNodes[index].requestFocus();
                  }
                });
                _moreInfoHadFocus = false;
              } else if (_parentFocusNode.hasFocus && !Device.isTv) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (index < _watchNowFocusNodes.length && mounted) {
                    _watchNowFocusNodes[index].requestFocus();
                  }
                });
              }
            },
            itemBuilder: (BuildContext context, int index) {
              final data = widget.movies[index];
              return Spotlight(
                spotlightNumber: index + 1,
                movie: data,
                watchNowFocusNode: _watchNowFocusNodes[index],
                moreInfoFocusNode: _moreInfoFocusNodes[index],
              );
            },
          ),
        ),
        Positioned(
          bottom: CineSpacing.s4,
          left: CineSpacing.s4,
          child: SmoothPageIndicator(
            controller: controller,
            count: widget.movies.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 10,
              spacing: 6,
              expansionFactor: 3,
              activeDotColor: CineColorScheme.primary,
              dotColor: CineColorScheme.white.putOpacity(0.2),
            ),
            onDotClicked: (index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutSine,
              );
            },
          ),
        ),
        if (!Device.isMobile && !Device.isTv)
          Positioned(
            right: ResponsiveValue<double>(
              screenWidth: screenWidth,
              mobile: CineSpacing.s4,
              tablet: CineSpacing.s6,
              desktop: CineSpacing.s8,
            ).value(),
            bottom: CineSpacing.s4,
            child: Row(
              children: [
                _navBtn(CineIcons.arrowLeft, () => back()),
                SizedBox(width: CineSpacing.s2),
                _navBtn(CineIcons.arrowRight, () => next()),
              ],
            ),
          ),
      ],
    );
  }

  Widget _navBtn(IconSource icon, VoidCallback onTap) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: CineColorScheme.black.putOpacity(0.3), shape: BoxShape.circle),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: CineIcon(icon: icon, size: 16, color: CineColorScheme.white),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SizedBox(height: 380, child: view(context)),
      tablet: SizedBox(height: 400, child: view(context)),
      desktop: SizedBox(height: 440, child: view(context)),
      tv: SizedBox(height: 400, child: view(context)),
    );
  }
}
