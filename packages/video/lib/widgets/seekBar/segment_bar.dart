import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video/widgets/seekBar/seek_bar_style.dart';
import 'constants.dart';
import 'segment.dart';

class SegmentBar extends StatelessWidget {
  final double totalWidth;
  final List<Segment>? segments;
  final Segment segment;
  final Duration position;
  final Duration buffer;
  final Duration duration;
  final double slider;
  final bool tapped;
  final bool hover;
  final Function(Duration) onSeek;
  final Uint8List? thumbnailVtt;
  final SeekBarColors colors;

  const SegmentBar({
    super.key,
    required this.totalWidth,
    required this.segments,
    required this.segment,
    required this.position,
    required this.buffer,
    required this.duration,
    required this.slider,
    required this.tapped,
    required this.hover,
    required this.onSeek,
    this.thumbnailVtt,
    required this.colors,
  });

  bool get isPosBtwn {
    if (!tapped) {
      final bool lessThan = (position.inSeconds < segment.end);
      final bool greaterThan = (position.inSeconds > segment.start);
      return lessThan && greaterThan;
    } else {
      final bool lessThan = ((slider * duration.inSeconds) < segment.end);
      final bool greaterThan = ((slider * duration.inSeconds) > segment.start);
      return lessThan && greaterThan;
    }
  }

  bool get isBuffBtwn {
    final bool lessThan = (buffer.inSeconds < segment.end);
    final bool greaterThan = (buffer.inSeconds > segment.start);
    return lessThan && greaterThan;
  }

  bool get finished {
    if (!tapped) {
      return (position.inSeconds <= segment.start);
    } else {
      return ((slider * duration.inSeconds) < segment.start);
    }
  }

  bool get hasNotLoaded {
    return (position.inSeconds == 0);
  }

  bool get isLast => (duration.inSeconds == segment.end.floor());

  int get segmentFlex {
    final double relativeSize = segment.diff / duration.inSeconds;
    if (relativeSize.isInfinite) {
      return 1;
    } else if (relativeSize.isNaN) {
      return 1;
    } else {
      return (relativeSize * 5000).ceil();
    }
  }

  double positionVal(double relativeWidth) {
    if (!tapped) {
      final double value = (isPosBtwn ? positionPercent : 1) * (finished ? 0 : 1) * relativeWidth;
      return !(value.isNaN || value.isInfinite) ? value : 0;
    } else {
      final double percent = ((slider * duration.inSeconds) - segment.start) / segment.diff;
      final double value = (isPosBtwn ? percent : 1) * (finished ? 0 : 1) * relativeWidth;
      return !(value.isNaN || value.isInfinite) ? value : 0;
    }
  }

  double bufferVal(double relativeWidth) {
    final bool buffFinished = (buffer.inSeconds < segment.start);
    final double value = (isBuffBtwn ? bufferPercent : 1) * (buffFinished ? 0 : 1) * relativeWidth;
    return !(value.isNaN || value.isInfinite) ? value : 0;
  }

  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    }
    final double diff = segment.diff;
    final double relativePos = (position.inSeconds - segment.start);
    final double value = relativePos / diff;
    return value.clamp(0.0, 1.0);
  }

  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    }
    final double diff = segment.diff;
    final double relativebuff = (buffer.inSeconds - segment.start);
    final double value = relativebuff / diff;
    return value.clamp(0.0, 1.0);
  }

  Container positionIndicator(double barWidth) {
    return Container(
      height: seekBarHeight,
      width: positionVal(barWidth),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: colors.seekBarPositionColor),
    );
  }

  Container bufferIndicator(double barWidth) {
    return Container(
      height: seekBarHeight,
      width: bufferVal(barWidth),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: colors.seekBarBufferColor),
    );
  }

  Positioned thumb(double barWidth) {
    return Positioned(
      left: (positionVal(barWidth) - seekBarThumbSize / 2),
      bottom: -1.0 * seekBarThumbSize / 2 + seekBarHeight / 2,
      child: Container(
        width: seekBarThumbSize,
        height: seekBarThumbSize,
        decoration: BoxDecoration(
          color: colors.seekBarThumbColor,
          borderRadius: BorderRadius.circular(seekBarThumbSize / 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: segmentFlex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double barWidth = constraints.maxWidth;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 3),
            child: Container(
              height: seekBarHeight,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: colors.seekBarColor),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (!hasNotLoaded)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(children: [bufferIndicator(barWidth), positionIndicator(barWidth)]),
                    ),
                  if (isPosBtwn && (hover || tapped)) thumb(barWidth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
