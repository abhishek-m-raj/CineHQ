import 'package:flutter/material.dart';
import 'package:locale_names/locale_names.dart';
import 'package:video/other/responsive.dart';
import 'package:video/utils/language.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/settings/pages/settings_page.dart';

class SettingsSubtitlePage extends StatelessWidget {
  final Controller controller;
  final VidStyle style;
  final VoidCallback onBack;

  const SettingsSubtitlePage({super.key, required this.controller, required this.style, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: controller.player.stream.tracks,
      builder: (context, snapshot) {
        final List<SubtitleTrack> tracks = snapshot.data?.subtitle ?? controller.player.state.tracks.subtitle;
        return SettingsBtnPage(
          onTap: () => onBack(),
          itemCount: tracks.length,
          builder: (index) {
            final SubtitleTrack item = tracks[index];
            final bool isSelected = (item == controller.player.state.track.subtitle);
            String title;
            if (item.language != null && item.language!.validateLangCode) {
              final langKey = item.language!.iso6391LangKey;
              String? displayLang;
              if (langKey != null) {
                try {
                  displayLang = Locale.fromSubtags(languageCode: langKey).defaultDisplayLanguage;
                } catch (_) {}
              }
              title = displayLang ?? item.title ?? item.id;
            } else {
              title = item.title ?? item.id;
            }
            return HqListTile(
              titleWidget: Text(
                title,
                style: TextStyle(fontSize: fontSize(), color: isSelected ? style.settingTileColor : Colors.white),
              ),
              onPress: () {
                controller.setSubtitleTrack(item);
              },
            );
          },
        );
      },
    );
  }
}
