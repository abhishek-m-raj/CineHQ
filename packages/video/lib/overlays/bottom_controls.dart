import 'package:animated_visibility/animated_visibility.dart';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video/ui/ui.dart';
import 'package:video/controller.dart';
import 'package:video/style/enums.dart';
import 'package:video/style/style.dart';
import 'package:video/widgets/btns/btn.dart';
import 'package:video/widgets/btns/fit_btn.dart';
import 'package:video/widgets/time.dart';
import '../widgets/btns/full_screen_btn.dart';
import '../widgets/btns/mute_btn.dart';
import '../widgets/btns/skip_btn.dart';
import '../widgets/seekBar/seek_bar.dart';
import '../widgets/btns/settings/settings_btn.dart';

class BottomControlsOverlay extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final List<VidBtn> extraBtns;
  final bool showFullScreenBtn;

  const BottomControlsOverlay({
    super.key,
    required this.controller,
    required this.style,
    this.extraBtns = const [],
    this.showFullScreenBtn = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [SkipBtn(visible: !controller.isControlsVisble, controller: controller)],
        ),
        if (style.playerMode == VidPlayerMode.mobile) SizedBox(height: HqSpacing.s2),
        AnimatedVisibility(
          visible: controller.isControlsVisble,
          enterDuration: 500.ms,
          exitDuration: 300.ms,
          enter: fadeIn(curve: Curves.easeOutCubic) + slideInVertically(curve: Curves.easeOutCubic),
          exit: fadeOut(curve: Curves.easeOutCubic),
          child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    FocusTraversalOrder(
                      order: const NumericFocusOrder(2),
                      child: _BottomRow(
                        controller: controller,
                        style: style,
                        extraBtns: extraBtns,
                        showFullScreenBtn: showFullScreenBtn,
                      ),
                    ),
                    if (Device.isTv)
                      FocusTraversalOrder(
                        order: const NumericFocusOrder(1),
                        child: Focus(
                          onFocusChange: (focused) {
                            if (focused) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                          child: const SizedBox(width: 100, height: 10),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: HqSpacing.s1),
                FocusTraversalOrder(
                  order: const NumericFocusOrder(3),
                  child: SeekBar(controller: controller, style: style),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomRow extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final List<VidBtn> extraBtns;
  final bool showFullScreenBtn;

  const _BottomRow({
    required this.controller,
    required this.style,
    required this.extraBtns,
    required this.showFullScreenBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [TimeLabel(isVisible: controller.player.state.duration != Duration.zero, controller: controller)],
        ),
        if (style.playerMode != VidPlayerMode.mobile)
          Row(
            children: [
              SkipBtn(controller: controller),
              SizedBox(width: HqSpacing.s1),
              ...extraBtns,
              FitBtn(controller: controller, style: style),
              MuteBtn(controller: controller, style: style),
              SettingsBtn(controller: controller, style: style),
              if (showFullScreenBtn) FullScreenBtn(controller: controller, style: style),
            ],
          ),
        if (style.playerMode == VidPlayerMode.mobile) SkipBtn(controller: controller),
      ],
    );
  }
}
