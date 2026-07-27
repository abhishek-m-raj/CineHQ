import 'dart:async';
import 'package:video/controller.dart';
import 'package:video/models/datasource.dart';
import '../other/logging.dart';

class VideoStreams {
  final Controller controller;
  final StreamController<bool> _completedController = StreamController.broadcast();
  final StreamController<Datasource?> videoLoadedController = StreamController.broadcast();
  final StreamController<bool> fullscreenController = StreamController.broadcast();
  final StreamController<bool> isControlsVisbleController = StreamController.broadcast();

  late List<StreamSubscription> subs;

  VideoStreams({required this.controller}) {
    init();
  }

  void init() {
    subs = [
      controller.player.stream.completed.listen((e) {
        final bool isVidLoaded = controller.player.state.duration.inSeconds > 1;
        final bool isAtLast = controller.player.state.position.inMinutes == controller.player.state.duration.inMinutes;
        final bool isNotBuffering = !controller.player.state.buffering;
        if (isAtLast && isVidLoaded && isNotBuffering) {
          log.i("Video finished");
          _completedController.add(true);
        } else {
          _completedController.add(false);
        }
      }),
    ];
  }

  void dispose() {
    for (final i in subs) {
      i.cancel();
    }
  }

  Stream<bool> get onCompleted => _completedController.stream;
  Stream<Datasource?> get onVideoLoaded => videoLoadedController.stream;
  Stream<bool> get onFullscreen => fullscreenController.stream;
  Stream<bool> get isControlsVisble => isControlsVisbleController.stream;
}
