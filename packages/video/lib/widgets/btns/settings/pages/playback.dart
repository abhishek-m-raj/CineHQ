import 'package:flutter/material.dart';
import 'package:video/other/responsive.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/settings/pages/settings_page.dart';

class SettingsPlaybackPage extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final VoidCallback onBack;

  const SettingsPlaybackPage({super.key, required this.controller, required this.style, required this.onBack});

  static const playBacks = [0.5, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 4.0];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.player.stream.rate,
      builder: (context, snapshot) {
        return SettingsBtnPage(
          onTap: () => onBack(),
          itemCount: playBacks.length,
          builder: (index) {
            final double item = playBacks[index];
            final bool isSelected = (item == controller.player.state.rate);
            return HqListTile(
              titleWidget: Text(
                item.toString(),
                style: TextStyle(fontSize: fontSize(), color: isSelected ? style.settingTileColor : Colors.white),
              ),
              onPress: () {
                controller.setPlaybackSpeed(item);
              },
            );
          },
        );
      },
    );
  }
}
