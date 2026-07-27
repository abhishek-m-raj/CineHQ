import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:video/other/logging.dart';
import 'package:video/overlays/mini_progress.dart';
import 'package:video/overlays/fast_forward.dart';
import 'package:video/overlays/loading.dart';
import 'package:video/overlays/shade.dart';
import 'package:video/overlays/top_controls.dart';
import 'package:video/overlays/volume_brightness.dart';
import 'package:video/style/enums.dart';
import 'package:video/widgets/btns/btn.dart';
import 'package:video/widgets/btns/settings/settings_overlay.dart';
import 'dart:async';
import 'overlays/cover_image.dart';
import 'other/events_listener.dart';
import 'video.dart';
import 'overlays/bottom_controls.dart';
import 'overlays/middle_controls.dart';
import 'overlays/seek_ripple.dart';

class VideoUI extends StatefulWidget {
  final Controller controller;
  final VidStyle style;
  final List<VidBtn> extraBtns;
  final List<Widget> extraOverlays;
  final bool showFullScreenBtn;

  const VideoUI({
    super.key = const ValueKey("video"),
    required this.controller,
    this.style = const VidStyle(),
    this.extraBtns = const [],
    this.extraOverlays = const [],
    this.showFullScreenBtn = true,
  });

  @override
  State<VideoUI> createState() => VideoUIState();
}

class VideoUIState extends State<VideoUI> {
  late List<StreamSubscription> subs;

  @override
  void initState() {
    super.initState();
    subs = [
      widget.controller.player.stream.error.listen((e) => log.e(e)),
      widget.controller.streams.isControlsVisble.listen((e) => setState(() {})),
    ];
    widget.controller.setControlsVisibility(true);
  }

  @override
  void dispose() {
    super.dispose();
    for (final sub in subs) {
      sub.cancel();
    }
  }

  EdgeInsets get padding {
    if (widget.style.playerMode == VidPlayerMode.mobile) {
      if (!widget.controller.isFullscreen) {
        return EdgeInsets.only(top: HqSpacing.s2, left: HqSpacing.s2, right: HqSpacing.s2);
      }
      return EdgeInsets.all(HqSpacing.s3);
    } else {
      return EdgeInsets.symmetric(horizontal: HqSpacing.s3, vertical: HqSpacing.s3).copyWith(bottom: HqSpacing.s1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: EventsListener(
        controller: widget.controller,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(navigationMode: NavigationMode.directional),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              CoverImageOverlay(controller: widget.controller),
              ShadeOverlay(controller: widget.controller),
              (() {
                final bool usePackageSubtitle = !widget.controller.player.hasSubtitleSupport || widget.controller.settings.usePackageSubtitleViewer;
                if (!usePackageSubtitle) return const SizedBox.shrink();
                return StreamBuilder<String?>(
                  stream: widget.controller.settings.usePackageSubtitleViewer
                      ? widget.controller.packageSubtitleStream
                      : widget.controller.player.stream.subtitleText,
                  initialData: widget.controller.settings.usePackageSubtitleViewer
                      ? null
                      : widget.controller.player.state.subtitleText,
                  builder: (context, snapshot) {
                    return VideoSubtitleView(text: snapshot.data, settings: widget.controller.settings);
                  },
                );
              })(),
              ForwardAndRewindOverlay(controller: widget.controller),
              Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(1),
                      child: TopControlsOverlay(controller: widget.controller, style: widget.style),
                    ),
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(3),
                      child: BottomControlsOverlay(
                        controller: widget.controller,
                        style: widget.style,
                        extraBtns: widget.extraBtns,
                        showFullScreenBtn: widget.showFullScreenBtn,
                      ),
                    ),
                  ],
                ),
              ),
              if (!Device.isTv) VolumeBrightnessOverlay(controller: widget.controller, style: widget.style),
              FastForwardOverlay(controller: widget.controller),
              MiniProgressOverlay(controller: widget.controller),
              FocusTraversalOrder(
                order: const NumericFocusOrder(2),
                child: MiddleControlsOverlay(controller: widget.controller, style: widget.style),
              ),
              LoadingOverlay(controller: widget.controller, style: widget.style),
              SettingsOverlay(controller: widget.controller, style: widget.style),
              EpisodesOverlay(controller: widget.controller, style: widget.style),
              ...widget.extraOverlays,
            ],
          ),
        ),
      ),
    );
  }
}
