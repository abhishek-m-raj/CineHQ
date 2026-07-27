import 'dart:ui';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video/utils/extentions.dart';
import '../overlays/seek_ripple.dart';
import '../controller.dart';

class KeyEventsManager {
  final bool noFullscreen;
  final Controller controller;

  KeyEventsManager({required this.controller, required this.noFullscreen});

  static const pauseKey = LogicalKeyboardKey.space;
  static const fastForwardKey = LogicalKeyboardKey.keyP;
  static const muteKey = LogicalKeyboardKey.keyM;
  static const timestampSkipKey = LogicalKeyboardKey.keyS;
  static const tvSelectBtn = LogicalKeyboardKey.select;
  static const arrowUp = LogicalKeyboardKey.arrowUp;
  static const fullscreenKey = LogicalKeyboardKey.keyF;
  static const fullscreenexitKey = LogicalKeyboardKey.escape;
  static const doubleSeekRewindKey = LogicalKeyboardKey.arrowLeft;
  static const doubleSeekForwardKey = LogicalKeyboardKey.arrowRight;
  static const volumeUpKey = LogicalKeyboardKey.arrowUp;
  static const volumeDownKey = LogicalKeyboardKey.arrowDown;

  void init() {
    ServicesBinding.instance.keyboard.addHandler(onKeyEvent);
  }

  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(onKeyEvent);
  }

  bool onKeyEvent(KeyEvent event) {
    final LogicalKeyboardKey key = event.logicalKey;
    final bool isKeyUp = (event is KeyUpEvent);
    final bool isKeyRepeat = (event is KeyDownEvent);
    final bool isKeyDown = (event is KeyDownEvent);
    if (Device.isTv) {
      _tvControls(key, isKeyDown, isKeyRepeat, isKeyUp);
    } else {
      _desktopControls(key, isKeyDown, isKeyRepeat, isKeyUp);
    }
    return false;
  }

  bool _tvControls(LogicalKeyboardKey key, bool isKeyDown, bool isKeyRepeat, bool isKeyUp) {
    if (controller.isFullscreen || noFullscreen) {
      if (key == arrowUp) {
        controller.setControlsVisibility(true);
        return true;
      }
      if (!controller.isControlsVisble) {
        if (key == tvSelectBtn) {
          if (isKeyDown) {
            controller.fastForward(true);
            return true;
          } else if (isKeyUp) {
            controller.fastForward(false);
            return true;
          }
        }
        if (!isKeyUp) {
          if (key == doubleSeekRewindKey) {
            controller.seek(RippleSide.left);
            return true;
          }
          if (key == doubleSeekForwardKey) {
            controller.seek(RippleSide.right);
            return true;
          }
        }
      } else {
        controller.setControlsVisibility(true);
      }
    } else {
      controller.setControlsVisibility(true);
    }
    return false;
  }

  Future<bool> _desktopControls(LogicalKeyboardKey key, bool isKeyDown, bool isKeyRepeat, bool isKeyUp) async {
    if (key == fastForwardKey) {
      if (isKeyDown) {
        controller.setControlsVisibility(false);
        controller.fastForward(true);
        return true;
      } else if (isKeyUp) {
        controller.fastForward(false);
        return true;
      }
    }
    if (!isKeyUp) {
      if (key == pauseKey) {
        controller.setControlsVisibility(controller.player.state.playing);
        controller.player.playOrPause();
        return true;
      }
      if (key == timestampSkipKey) {
        if (controller.currentChapter?.isSkippable ?? false) {
          controller.skipChapter();
          return true;
        }
      }
      if (key == doubleSeekRewindKey) {
        controller.seek(RippleSide.left);
        return true;
      }
      if (key == doubleSeekForwardKey) {
        controller.seek(RippleSide.right);
        return true;
      }
      if (key == volumeUpKey) {
        final double value = (controller.volume.value) + 0.5;
        controller.volume.set(value);
        return true;
      }
      if (key == volumeDownKey) {
        final double value = (controller.volume.value) - 0.5;
        controller.volume.set(value);
        return true;
      }
      if (key == fullscreenKey) {
        if (!controller.isFullscreen) {
          controller.enFullscreen();
        } else {
          controller.exFullscreen();
        }
        return true;
      }
      if (key == fullscreenexitKey) {
        if (controller.isFullscreen) {
          controller.exFullscreen();
        }
        return true;
      }
      if (key == muteKey) {
        controller.volume.setMute();
        return true;
      }
    }
    return false;
  }
}

class EventsListener extends StatefulWidget {
  final Controller controller;
  final Widget child;

  const EventsListener({super.key, required this.controller, required this.child});

  @override
  State<EventsListener> createState() => _EventsListenerState();
}

class _EventsListenerState extends State<EventsListener> {
  TapDownDetails? doubleTap;
  late final Controller controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller.settingsOverlayController,
      builder: (context, child) {
        if (!Device.isTv && !widget.controller.settingsOverlayController.isOpen) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                cursor: controller.isControlsVisble ? SystemMouseCursors.basic : SystemMouseCursors.none,
                onHover: onHoverEvent,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapEvent,
                  onDoubleTap: () => onDoubleTapEvent(doubleTap!, constraints.maxWidth),
                  onDoubleTapDown: (details) => doubleTap = details,
                  onLongPress: onLongPressEvent,
                  onLongPressUp: onLongPressUpEvent,
                  onVerticalDragUpdate: (e) => onVerticalDragUpdateEvent(e, constraints.maxWidth),
                  onHorizontalDragStart: onHorizontalDragStartEvent,
                  onHorizontalDragUpdate: (e) => onHorizontalDragUpdateEvent(e, constraints.maxWidth),
                  onHorizontalDragEnd: onHorizontalDragEndEvent,
                  child: Focus(autofocus: true, child: widget.child),
                ),
              );
            },
          );
        } else {
          return widget.child;
        }
      },
    );
  }

  void onLongPressUpEvent() {
    if (!widget.controller.settings.fastForwardOnLongPress) {
      return;
    }
    controller.fastForward(false);
  }

  void onLongPressEvent() {
    if (!widget.controller.settings.fastForwardOnLongPress) {
      return;
    }
    controller.setControlsVisibility(false);
    controller.fastForward(true);
  }

  void onHoverEvent(PointerHoverEvent event) {
    if (event.kind == PointerDeviceKind.touch) {
      return;
    }
    if (!controller.isControlsVisble) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setControlsVisibility(true);
      });
    }
  }

  void onDoubleTapEvent(TapDownDetails details, double screenWidth) {
    if (controller.settings.seekOnDoubleTap) {
      if (details.globalPosition.dx < (screenWidth / 2)) {
        controller.seek(RippleSide.left);
      } else {
        controller.seek(RippleSide.right);
      }
    }
  }

  void onVerticalDragUpdateEvent(DragUpdateDetails details, double screenWidth) async {
    if (!widget.controller.settings.brightnesVolumeDrags) {
      return;
    }
    if (!controller.isFullscreen || controller.isControlsVisble) {
      return;
    }
    if (details.globalPosition.dx < (screenWidth / 2)) {
      final double brightnes = controller.brightness.value;
      final double val = brightnes - (details.delta.dy / 2);
      controller.brightness.set(val);
    } else {
      final double volume = controller.volume.value;
      final double val = volume - (details.delta.dy / 2);
      controller.volume.set(val);
    }
  }

  void onHorizontalDragStartEvent(DragStartDetails _) {
    if (!widget.controller.settings.seekOnHorizontalDrag) {
      return;
    }
    if (!controller.isFullscreen) {
      return;
    }
    controller.isDragSeeking = true;
    controller.seekDragedDur = controller.player.state.position;
  }

  void onHorizontalDragUpdateEvent(DragUpdateDetails details, double screenWidth) async {
    if (!widget.controller.settings.seekOnHorizontalDrag) {
      return;
    }
    if (!controller.isFullscreen) {
      return;
    }
    if (controller.isControlsVisble) {
      controller.setControlsVisibility(true);
    }
    final Duration dur = controller.player.state.duration;
    final double change = (details.delta.dx / screenWidth);
    final int offset = (change * dur.inSeconds).toInt();
    controller.seekDragedDur = (controller.seekDragedDur! + Duration(seconds: offset)).clamp(Duration.zero, dur);
    controller.player.seek((controller.seekDragedDur!));
  }

  void onHorizontalDragEndEvent(DragEndDetails _) {
    if (!widget.controller.settings.seekOnHorizontalDrag) {
      return;
    }
    if (!controller.isFullscreen) {
      return;
    }
    controller.isDragSeeking = false;
    controller.seekDragedDur = null;
  }

  void onTapEvent() {
    if (controller.settings.pauseOnTap) {
      controller.setControlsVisibility(controller.player.state.playing);
      controller.player.playOrPause();
    } else {
      controller.setControlsVisibility(!controller.isControlsVisble);
    }
  }
}
