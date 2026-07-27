import 'dart:async';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/seekBar/info_indicator.dart';
import 'package:video/widgets/seekBar/seek_bar_style.dart';
import 'package:video/widgets/thumbnail/vtt_thumbnail.dart';
import 'package:video/utils/extentions.dart';
import '../../models/chapter.dart';
import 'constants.dart';
import 'segment.dart';
import 'segment_bar.dart';

class PreviewFrame {
  final Duration time;
  final ThumbnailCue? cue;
  PreviewFrame({required this.time, this.cue});
}

class SeekBar extends StatefulWidget {
  final Controller controller;
  final VidStyle style;

  const SeekBar({super.key, required this.style, required this.controller});

  @override
  State<SeekBar> createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  List<Segment>? getSegments() {
    const Chapter initialChapter = Chapter(at: 0, name: "", isSkippable: false);
    final Chapter durationChapter = Chapter(
      at: widget.controller.player.state.duration.inSeconds.toDouble(),
      name: "",
      isSkippable: false,
    );
    final List<Chapter> chapters = widget.controller.chapters;
    if (widget.controller.chapters.isNotEmpty) {
      if (chapters[0].at != 0.0) {
        chapters.insert(0, initialChapter);
      }
    }
    late final List<Segment>? stamps;
    if (chapters.isNotEmpty) {
      stamps = chapters.map((Chapter i) {
        late final Chapter value1 = i;
        late final Chapter value2;
        final int index = chapters.indexOf(i);
        if (index != chapters.length - 1) {
          value2 = chapters[index + 1];
        } else {
          value2 = durationChapter;
        }
        final Segment data = Segment(name: i.name == "" ? null : i.name, start: value1.at, end: value2.at);
        return data;
      }).toList();
    } else {
      stamps = null;
    }
    return stamps;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialSeekBar(
      controller: widget.controller,
      segments: getSegments(),
      style: widget.style,
      colors: SeekBarColors(
        seekBarColor: widget.style.seekBarColor,
        seekBarPositionColor: widget.style.seekBarPositionColor,
        seekBarBufferColor: widget.style.seekBarBufferColor,
        seekBarThumbColor: widget.style.seekBarThumbColor,
      ),
    );
  }
}

class MaterialSeekBar extends StatefulWidget {
  final Controller controller;
  final List<Segment>? segments;
  final SeekBarColors colors;
  final VidStyle style;

  const MaterialSeekBar({
    super.key,
    required this.controller,
    required this.colors,
    required this.segments,
    required this.style,
  });

  @override
  MaterialSeekBarState createState() => MaterialSeekBarState();
}

class MaterialSeekBarState extends State<MaterialSeekBar> {
  bool tapped = false;
  bool hover = false;
  bool _focused = false;
  bool seeking = true;
  double? infoIndicatorPos;
  PointerHoverEvent? hoverDetails;
  double slider = 0.0;

  late Duration position = widget.controller.player.state.position;
  late Duration duration = widget.controller.player.state.duration;
  late Duration buffer = widget.controller.player.state.buffer;

  final List<StreamSubscription> subs = [];

  bool _showFramesStrip = false;
  int _selectedFrameIndex = 0;
  List<PreviewFrame> _previewFrames = [];
  ScrollController? _framesScrollController;
  double _currentWidth = 0.0;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subs.isEmpty) {
      subs.addAll([
        widget.controller.player.stream.position.listen((event) {
          setState(() {
            if (!tapped && !_showFramesStrip) {
              position = event;
            }
          });
        }),
        widget.controller.player.stream.duration.listen((event) {
          setState(() {
            duration = event;
          });
        }),
        widget.controller.player.stream.buffer.listen((event) {
          setState(() {
            buffer = event;
          });
        }),
        widget.controller.streams.isControlsVisble.listen((event) {
          if ((event == false) && (tapped || _showFramesStrip)) {
            widget.controller.setControlsVisibility(true);
          }
        }),
      ]);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.framesOverlayController.addListener(_onFramesOverlayChanged);
  }

  void _onFramesOverlayChanged() {
    if (!widget.controller.framesOverlayController.isOpen && _showFramesStrip) {
      setState(() {
        _showFramesStrip = false;
        position = widget.controller.player.state.position;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.framesOverlayController.removeListener(_onFramesOverlayChanged);
    for (final subscription in subs) {
      subscription.cancel();
    }
    _framesScrollController?.dispose();
    super.dispose();
  }

  Widget eventsListener({required double width, required Widget child}) {
    void onPointerMove(PointerMoveEvent e, double totalWidth) {
      final percent = e.localPosition.dx / totalWidth;
      setState(() {
        tapped = true;
        slider = percent.clamp(0.0, 1.0);
        infoIndicatorPos = e.localPosition.dx;
      });
      widget.controller.player.seek(duration * slider);
    }

    void onPointerDown(PointerDownEvent e) {
      setState(() {
        tapped = true;
        infoIndicatorPos = e.localPosition.dx;
      });
    }

    void onPointerUp() async {
      await widget.controller.player.seek(duration * slider);
      setState(() {
        tapped = false;
        position = duration * slider;
        infoIndicatorPos = null;
      });
    }

    void onPanStart(DragStartDetails e, double totalWidth) {
      final percent = e.localPosition.dx / totalWidth;
      setState(() {
        tapped = true;
        slider = percent.clamp(0.0, 1.0);
        infoIndicatorPos = e.localPosition.dx;
      });
    }

    void onPanDown(DragDownDetails e, double totalWidth) {
      final percent = e.localPosition.dx / totalWidth;
      setState(() {
        tapped = true;
        slider = percent.clamp(0.0, 1.0);
        infoIndicatorPos = e.localPosition.dx;
      });
    }

    void onPanUpdate(DragUpdateDetails e, double totalWidth) {
      final percent = e.localPosition.dx / totalWidth;
      setState(() {
        tapped = true;
        slider = percent.clamp(0.0, 1.0);
        infoIndicatorPos = e.localPosition.dx;
      });
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        hover = true;
        hoverDetails = event;
        infoIndicatorPos = event.localPosition.dx;
        setState(() {});
      },
      onExit: (event) {
        hover = false;
        hoverDetails = null;
        infoIndicatorPos = null;
        setState(() {});
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (_) {},
        onPanStart: (e) => onPanStart(e, width),
        onPanDown: (e) => onPanDown(e, width),
        onPanUpdate: (e) => onPanUpdate(e, width),
        child: Listener(
          onPointerMove: (e) => onPointerMove(e, width),
          onPointerDown: (e) => onPointerDown(e),
          onPointerUp: (e) => onPointerUp(),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = SeekBarColors(
      seekBarColor: widget.colors.seekBarColor,
      seekBarPositionColor: _focused ? widget.style.seekBarPositionFocusColor : widget.style.seekBarPositionColor,
      seekBarBufferColor: widget.colors.seekBarBufferColor,
      seekBarThumbColor: widget.colors.seekBarThumbColor,
    );

    return Focus(
      onFocusChange: (val) {
        setState(() {
          _focused = val;
          if (!val) {
            _showFramesStrip = false;
            widget.controller.framesOverlayController.close();
            position = widget.controller.player.state.position;
          }
        });
      },
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }

        final key = event.logicalKey;

        if (!_showFramesStrip) {
          if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowRight) {
            setState(() {
              _showFramesStrip = true;
              widget.controller.framesOverlayController.open();
              _initializePreviewFrames(_currentWidth);
              if (_previewFrames.isNotEmpty && _selectedFrameIndex < _previewFrames.length) {
                position = _previewFrames[_selectedFrameIndex].time;
              }
            });
            return KeyEventResult.handled;
          }
          if (Device.isTv && (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select)) {
            setState(() {
              tapped = !tapped;
            });
            return KeyEventResult.handled;
          }
        } else {
          if (key == LogicalKeyboardKey.arrowLeft) {
            if (_selectedFrameIndex > 0) {
              setState(() {
                _selectedFrameIndex--;
                position = _previewFrames[_selectedFrameIndex].time;
              });
            }
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowRight) {
            if (_selectedFrameIndex < _previewFrames.length - 1) {
              setState(() {
                _selectedFrameIndex++;
                position = _previewFrames[_selectedFrameIndex].time;
              });
            }
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.select) {
            if (_selectedFrameIndex >= 0 && _selectedFrameIndex < _previewFrames.length) {
              final selectedTime = _previewFrames[_selectedFrameIndex].time;
              widget.controller.player.seek(selectedTime);
              setState(() {
                position = selectedTime;
                _showFramesStrip = false;
                widget.controller.framesOverlayController.close();
              });
            }
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowUp ||
              key == LogicalKeyboardKey.arrowDown ||
              key == LogicalKeyboardKey.escape) {
            setState(() {
              _showFramesStrip = false;
              widget.controller.framesOverlayController.close();
              position = widget.controller.player.state.position;
            });
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          _currentWidth = constraints.maxWidth;
          return eventsListener(
            width: constraints.maxWidth,
            child: Container(
              height: seekBarContainerHeight + 16,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (infoIndicatorPos != null && !Device.isMobile && !_showFramesStrip)
                    InfoIndicatorN(
                      localPosition: infoIndicatorPos!,
                      segments: widget.segments,
                      duration: duration,
                      totalWidth: constraints.maxWidth,
                      thumbnailVtt: widget.controller.thumbnailVtt,
                      thumbnailVttBaseUrl: widget.controller.thumbnailVttBaseUrl,
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ...widget.segments?.map((Segment i) {
                            return SegmentBar(
                              totalWidth: constraints.maxWidth,
                              segments: widget.segments,
                              segment: i,
                              position: position,
                              buffer: buffer,
                              duration: duration,
                              tapped: tapped,
                              hover: hover || _focused,
                              slider: slider,
                              onSeek: (val) => widget.controller.player.seek(val),
                              thumbnailVtt: widget.controller.thumbnailVtt,
                              colors: effectiveColors,
                            );
                          }) ??
                          [
                            SegmentBar(
                              totalWidth: constraints.maxWidth,
                              segments: widget.segments,
                              segment: Segment(name: "", start: 0, end: duration.inSeconds.toDouble()),
                              position: position,
                              buffer: buffer,
                              duration: duration,
                              tapped: tapped,
                              hover: hover || _focused,
                              slider: slider,
                              onSeek: (val) => widget.controller.player.seek(val),
                              thumbnailVtt: widget.controller.thumbnailVtt,
                              colors: effectiveColors,
                            ),
                          ],
                    ],
                  ),
                  if (_showFramesStrip && _previewFrames.isNotEmpty) _buildFramesStrip(constraints.maxWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _initializePreviewFrames(double totalWidth) {
    _previewFrames.clear();
    final vtt = widget.controller.thumbnailVtt;
    if (vtt != null) {
      final cues = VttParser.parse(vtt, widget.controller.thumbnailVttBaseUrl ?? '');
      _previewFrames = cues
          .map(
            (cue) => PreviewFrame(
              time: Duration(
                milliseconds: cue.start.inMilliseconds + (cue.end.inMilliseconds - cue.start.inMilliseconds) ~/ 2,
              ),
              cue: cue,
            ),
          )
          .toList();
    } else {
      final totalSeconds = duration.inSeconds;
      if (totalSeconds > 0) {
        final int interval = (totalSeconds / 100).round().clamp(5, 60);
        for (int sec = 0; sec <= totalSeconds; sec += interval) {
          _previewFrames.add(PreviewFrame(time: Duration(seconds: sec)));
        }
        if (_previewFrames.isEmpty || _previewFrames.last.time.inSeconds != totalSeconds) {
          _previewFrames.add(PreviewFrame(time: Duration(seconds: totalSeconds)));
        }
      }
    }

    if (_previewFrames.isEmpty) {
      _selectedFrameIndex = 0;
      _framesScrollController?.dispose();
      _framesScrollController = ScrollController();
      return;
    }

    // Find the frame closest to the current position
    final currentMs = position.inMilliseconds;
    int closestIndex = 0;
    int minDiff = 9007199254740991; // JS safe int max
    for (int i = 0; i < _previewFrames.length; i++) {
      final diff = (_previewFrames[i].time.inMilliseconds - currentMs).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestIndex = i;
      }
    }
    _selectedFrameIndex = closestIndex;

    // Dispose old controller and create new one with correct initial scroll offset
    _framesScrollController?.dispose();
    const double cardWidth = 144.0;
    const double spacing = 12.0;
    const double itemOuterWidth = cardWidth + spacing;
    final double approxMaxScroll = (_previewFrames.length * itemOuterWidth) - totalWidth;
    final double targetOffset = (_selectedFrameIndex * itemOuterWidth) - (totalWidth / 2) + (itemOuterWidth / 2);
    _framesScrollController = ScrollController(
      initialScrollOffset: targetOffset.clamp(0.0, approxMaxScroll > 0 ? approxMaxScroll : 0.0),
    );
  }

  Widget _buildFramesStrip(double totalWidth) {
    const double cardWidth = 144.0;
    return Positioned(
      left: 0,
      right: 0,
      bottom: seekBarHeight + 20,
      child: Container(
        height: 130,
        width: totalWidth,
        alignment: Alignment.center,
        child: ListView.builder(
          controller: _framesScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _previewFrames.length,
          padding: EdgeInsets.symmetric(horizontal: totalWidth / 2 - cardWidth / 2),
          itemBuilder: (context, index) {
            final frame = _previewFrames[index];
            final isSelected = index == _selectedFrameIndex;
            return _FrameCardWidget(isSelected: isSelected, child: _buildFrameCard(frame, isSelected));
          },
        ),
      ),
    );
  }

  Widget _buildFrameCard(PreviewFrame frame, bool isSelected) {
    const double cardWidth = 144.0;
    const double cardHeight = 81.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      width: isSelected ? cardWidth * 1.15 : cardWidth,
      height: isSelected ? cardHeight * 1.15 : cardHeight,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: HqColorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? HqColorScheme.primary : Colors.white24, width: isSelected ? 3 : 1),
        boxShadow: isSelected
            ? [BoxShadow(color: HqColorScheme.primary.putOpacity(0.5), blurRadius: 12, spreadRadius: 2)]
            : [BoxShadow(color: Colors.black.putOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            Positioned.fill(
              child: frame.cue != null
                  ? SingleCueThumbnail(
                      cue: frame.cue!,
                      width: cardWidth,
                      height: cardHeight,
                      loading: const Center(
                        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: _buildPlaceholderBackground(frame.time),
                    )
                  : _buildPlaceholderBackground(frame.time),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  frame.time.label(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSelected ? 12 : 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBackground(Duration time) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HqColorScheme.surfaceContainerHigh, HqColorScheme.surfaceContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.2,
          child: Icon(Icons.movie_creation_outlined, color: HqColorScheme.onSurface, size: 32),
        ),
      ),
    );
  }
}

class _FrameCardWidget extends StatefulWidget {
  final bool isSelected;
  final Widget child;

  const _FrameCardWidget({required this.isSelected, required this.child});

  @override
  State<_FrameCardWidget> createState() => _FrameCardWidgetState();
}

class _FrameCardWidgetState extends State<_FrameCardWidget> {
  @override
  void didUpdateWidget(_FrameCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scrollToMe();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMe());
    }
  }

  void _scrollToMe() {
    if (!mounted) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
