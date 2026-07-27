import 'package:flutter/widgets.dart';
import 'package:video/controller.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/loading_indicator.dart';

class LoadingOverlay extends StatelessWidget {
  final Controller controller;
  final VidStyle style;

  const LoadingOverlay({super.key, required this.controller, required this.style});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: StreamBuilder<bool>(
        stream: controller.streams.onLoadingChanged,
        builder: (context, loadingSnap) {
          return StreamBuilder<bool>(
            stream: controller.player.stream.buffering,
            builder: (context, snapshot) {
              final String? img = controller.coverImg ?? controller.datasource?.coverImg;
              final bool isCoverLoading = (controller.player.state.position == Duration.zero && img != null);
              final bool buffering = snapshot.data ?? false;
              final bool isLoading = controller.isLoading;
              return LoadingIndicator(
                style: style,
                buffering: buffering || (isCoverLoading && isLoading) || isLoading,
              );
            },
          );
        },
      ),
    );
  }
}
