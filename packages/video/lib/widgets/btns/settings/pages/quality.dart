import 'package:flutter/material.dart';
import 'package:video/other/responsive.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/settings/pages/settings_page.dart';

class SettingsQualityPage extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final VoidCallback onBack;

  const SettingsQualityPage({super.key, required this.controller, required this.style, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.player.stream.tracks,
      builder: (context, snapshot) {
        return SettingsBtnPage(
          onTap: () => onBack(),
          itemCount: controller.videoTracks.length,
          builder: (index) {
            final VideoTrack videoTrack = controller.videoTracks[index];
            final VideoTrack currentTrack = controller.currentTrack;
            final int? quality = videoTrack.h;
            final String id = videoTrack.id;
            final bool isSelected = (quality == currentTrack.h);
            return HqListTile(
              titleWidget: Text(
                id != "auto" ? "${quality}P" : "auto",
                style: TextStyle(fontSize: fontSize(), color: isSelected ? style.settingTileColor : Colors.white),
              ),
              onPress: () {
                controller.switchQuality(videoTrack);
              },
            );
          },
        );
      },
    );
  }
}
