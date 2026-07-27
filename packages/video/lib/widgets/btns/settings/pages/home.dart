import 'package:flutter/material.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/settings/settings_overlay.dart';

class SettingsHomePage extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final VoidCallback onBack;
  final Function(SettingsOverlayPage) setPage;

  const SettingsHomePage({
    super.key,
    required this.controller,
    required this.style,
    required this.onBack,
    required this.setPage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        HqListTile(leading: const Icon(Icons.arrow_back), onPress: () => onBack()),
        HqListTile(
          title: "Quality",
          leading: const Icon(Icons.high_quality),
          onPress: () => setPage(SettingsOverlayPage.quality),
        ),
        HqListTile(
          title: "Subtitle",
          leading: const Icon(Icons.subtitles),
          onPress: () => setPage(SettingsOverlayPage.subtitle),
        ),
        HqListTile(
          title: "Playback",
          leading: const Icon(Icons.speed),
          onPress: () => setPage(SettingsOverlayPage.playback),
        ),
      ],
    );
  }
}
