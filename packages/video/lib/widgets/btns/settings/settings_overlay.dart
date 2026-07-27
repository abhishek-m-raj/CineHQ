import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:responsive/responsive.dart';
import 'package:video/video.dart';
import 'package:video/other/overlay_controller.dart';
import 'pages/home.dart';
import 'pages/playback.dart';
import 'pages/quality.dart';
import 'pages/subtitle.dart';

class SettingsOverlay extends StatefulWidget {
  final Controller controller;
  final VidStyle style;

  const SettingsOverlay({super.key, required this.controller, required this.style});

  @override
  State<SettingsOverlay> createState() => SettingsOverlayState();
}

class SettingsOverlayState extends State<SettingsOverlay> {
  @override
  void initState() {
    super.initState();
  }

  Widget getWidget() {
    final page = widget.controller.settingsOverlayController.page;
    switch (page) {
      case SettingsOverlayPage.quality:
        return SettingsQualityPage(
          controller: widget.controller,
          style: widget.style,
          onBack: () {
            widget.controller.settingsOverlayController.setPage(SettingsOverlayPage.home);
          },
        );
      case SettingsOverlayPage.playback:
        return SettingsPlaybackPage(
          controller: widget.controller,
          style: widget.style,
          onBack: () {
            widget.controller.settingsOverlayController.setPage(SettingsOverlayPage.home);
          },
        );
      case SettingsOverlayPage.subtitle:
        return SettingsSubtitlePage(
          controller: widget.controller,
          style: widget.style,
          onBack: () {
            widget.controller.settingsOverlayController.setPage(SettingsOverlayPage.home);
          },
        );
      default:
        return SettingsHomePage(
          controller: widget.controller,
          style: widget.style,
          onBack: () {
            widget.controller.settingsOverlayController.toggle();
            if (Device.isTv) {
              widget.controller.playBtnFocusNode.requestFocus();
            }
          },
          setPage: (pg) {
            widget.controller.settingsOverlayController.setPage(pg);
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.settingsOverlayController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isOpen = widget.controller.settingsOverlayController.isOpen;
            return IgnorePointer(
              ignoring: !isOpen,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    top: 0,
                    bottom: 0,
                    right: !isOpen
                        ? -ResponsiveValue(
                            screenWidth: constraints.maxWidth,
                            mobile: constraints.maxWidth / 2,
                            tablet: constraints.maxWidth / 3,
                            desktop: constraints.maxWidth / 4,
                          ).value()
                        : 0,
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: ResponsiveValue(
                        screenWidth: constraints.maxWidth,
                        mobile: constraints.maxWidth / 2,
                        tablet: constraints.maxWidth / 3,
                        desktop: constraints.maxWidth / 4,
                      ).value(),
                      decoration: BoxDecoration(
                        color: HqColorScheme.surfaceContainer,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                      ),
                      padding: EdgeInsets.all(HqSpacing.s1),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: FocusTraversalGroup(
                          descendantsAreTraversable: isOpen,
                          descendantsAreFocusable: isOpen,
                          child: getWidget(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

enum SettingsOverlayPage { home, quality, playback, subtitle }

class SettingsOverlayController extends OverlayController {
  SettingsOverlayPage page = SettingsOverlayPage.home;

  void setPage(SettingsOverlayPage pg) {
    page = pg;
    notifyListeners();
  }
}
