import 'package:flutter/material.dart';
import 'package:video/controller.dart';
import 'package:video/ui/ui.dart';
import 'package:video/widgets/thumbnail/vtt_thumbnail.dart';

class CoverImageOverlay extends StatelessWidget {
  final Controller controller;

  const CoverImageOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final String? img = controller.coverImg ?? controller.datasource?.coverImg;
    return Positioned.fill(
      child: IgnorePointer(
        child: Builder(
          builder: (context) {
            if (controller.player.state.duration == Duration.zero && img != null) {
              return Container(
                decoration: BoxDecoration(image: HqDecorationImage.cachedNetwork(img)),
              );
            } else {
              if (controller.datasource == null && !controller.player.state.buffering) {
                return SizedBox.shrink();
              }
              if (controller.player.state.position != Duration.zero) {
                return SizedBox.shrink();
              }
              if (controller.player.state.duration != Duration.zero) {
                return SizedBox.shrink();
              }
              return controller.thumbnailVtt == null
                  ? SizedBox.shrink()
                  : VttThumbnail(
                      vtt: controller.thumbnailVtt!,
                      baseUrl: controller.thumbnailVttBaseUrl ?? '',
                      currentTime: controller.player.state.position,
                      loading: SizedBox.shrink(),
                      error: SizedBox.shrink(),
                    );
            }
          },
        ),
      ),
    );
  }
}
