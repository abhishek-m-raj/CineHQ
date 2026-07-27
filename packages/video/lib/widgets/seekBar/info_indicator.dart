import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video/ui/ui.dart';
import 'package:video/utils/extentions.dart';
import 'package:video/widgets/seekBar/constants.dart';
import 'package:video/widgets/seekBar/segment.dart';
import 'package:video/widgets/thumbnail/vtt_thumbnail.dart';

class InfoIndicator extends StatelessWidget {
  const InfoIndicator({
    super.key,
    required this.positionVal,
    required this.hoverDetails,
    required this.barWidth,
    required this.tapped,
    required this.segment,
    required this.totalWidth,
    this.thumbnailVtt,
  });

  final bool tapped;
  final Segment segment;
  final double totalWidth;
  final double positionVal;
  final Uint8List? thumbnailVtt;
  final PointerHoverEvent? hoverDetails;
  final double barWidth;

  double get containerHeight => 100;
  double get containerWidth => (16 / 9) * containerHeight;

  @override
  Widget build(BuildContext context) {
    final double diff = segment.diff;
    late final double relativePos;
    if (hoverDetails == null) {
      relativePos = (((positionVal / barWidth) * diff) + segment.start);
    } else {
      relativePos = (((hoverDetails!.localPosition.dx / barWidth) * diff) + segment.start);
    }
    return Positioned(
      left: ((hoverDetails?.localPosition.dx ?? positionVal) - (containerWidth / 2)),
      bottom: seekBarHeight + 5,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: containerHeight,
              width: containerWidth,
              margin: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: infoIndicatorColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.putOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 12,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: thumbnailVtt == null
                    ? SizedBox()
                    : VttThumbnail(
                        vtt: thumbnailVtt!,
                        baseUrl: '',
                        currentTime: Duration(seconds: relativePos.toInt()),
                        width: containerWidth,
                        height: containerHeight,
                        loading: SizedBox.shrink(),
                        error: SizedBox.shrink(),
                      ),
              ),
            ),
            Positioned(
              bottom: 6,
              child: HqText(
                "${segment.name ?? ""} ${(Duration(seconds: relativePos.toInt())).label()}",
                style: HqTextStyles.b2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoIndicatorN extends StatelessWidget {
  const InfoIndicatorN({
    super.key,
    required this.localPosition,
    required this.segments,
    required this.duration,
    required this.totalWidth,
    this.thumbnailVtt,
    this.thumbnailVttBaseUrl,
  });

  final double localPosition;
  final List<Segment>? segments;
  final Duration duration;
  final double totalWidth;
  final Uint8List? thumbnailVtt;
  final String? thumbnailVttBaseUrl;

  double get containerHeight => 100;
  double get containerWidth => (16 / 9) * containerHeight;

  Duration get relativePos => Duration(seconds: ((localPosition / totalWidth) * duration.inSeconds).toInt());

  Segment? get segment {
    try {
      final Segment segment = segments!.firstWhere((element) {
        final bool lessThan = (relativePos.inSeconds < element.end);
        final bool greaterThan = (relativePos.inSeconds > element.start);
        return lessThan && greaterThan;
      });
      return segment;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (localPosition - (containerWidth / 2)).clamp(0, totalWidth - containerWidth),
      bottom: seekBarHeight + 10,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: containerHeight,
              width: containerWidth,
              margin: EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: infoIndicatorColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.putOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 12,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: thumbnailVtt == null
                    ? SizedBox()
                    : VttThumbnail(
                        vtt: thumbnailVtt!,
                        baseUrl: thumbnailVttBaseUrl ?? '',
                        currentTime: relativePos,
                        width: containerWidth,
                        height: containerHeight,
                        loading: SizedBox.shrink(),
                        error: SizedBox.shrink(),
                      ),
              ),
            ),
            Positioned(
              bottom: 6,
              child: HqText("${segment?.name ?? ""} ${relativePos.label()}", style: HqTextStyles.b2),
            ),
          ],
        ),
      ),
    );
  }
}
