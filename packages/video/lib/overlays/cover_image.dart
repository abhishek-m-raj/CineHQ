import 'package:flutter/material.dart';
import 'package:video/controller.dart';
import 'package:video/models/datasource.dart';
import 'package:video/ui/ui.dart';
import 'package:video/widgets/thumbnail/vtt_thumbnail.dart';

class CoverImageOverlay extends StatelessWidget {
  final Controller controller;

  const CoverImageOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: controller.streams.onLoadingChanged,
      builder: (context, loadingSnap) {
        return StreamBuilder<Datasource?>(
          stream: controller.streams.onVideoLoaded,
          builder: (context, dsSnap) {
            return StreamBuilder<Duration>(
              stream: controller.player.stream.position,
              builder: (context, posSnap) {
                final String? img = controller.coverImg ?? controller.datasource?.coverImg;
                final bool isVidPlaying = (posSnap.data ?? controller.player.state.position) > Duration.zero;

                if (!isVidPlaying && img != null && img.isNotEmpty) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(image: HqDecorationImage.cachedNetwork(img)),
                      ),
                    ),
                  );
                }

                if (controller.datasource == null && !controller.player.state.buffering) {
                  return const SizedBox.shrink();
                }
                if (isVidPlaying) {
                  return const SizedBox.shrink();
                }
                if (controller.player.state.duration != Duration.zero) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: IgnorePointer(
                    child: controller.thumbnailVtt == null
                        ? const SizedBox.shrink()
                        : VttThumbnail(
                            vtt: controller.thumbnailVtt!,
                            baseUrl: controller.thumbnailVttBaseUrl ?? '',
                            currentTime: controller.player.state.position,
                            loading: const SizedBox.shrink(),
                            error: const SizedBox.shrink(),
                          ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
