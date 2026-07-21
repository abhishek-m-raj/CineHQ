import 'package:flutter/material.dart';
import 'package:cineui/components/icon.dart';
import 'package:hugeicons/hugeicons.dart';

class CineIcons {
  static final home = ExternalIcon(HugeIcons.strokeRoundedHome01);
  static final community = ExternalIcon(HugeIcons.strokeRoundedChat01);
  static final search = ExternalIcon(HugeIcons.strokeRoundedSearch01);
  static final searchOff = ExternalIcon(HugeIcons.strokeRoundedSearch01);
  static final bookmarks = ExternalIcon(HugeIcons.strokeRoundedBookmark01);
  static final settings = ExternalIcon(HugeIcons.strokeRoundedSettings01);
  static final notification = ExternalIcon(HugeIcons.strokeRoundedNotification01);

  static final clock = ExternalIcon(HugeIcons.strokeRoundedClock01);
  static final calendar = ExternalIcon(HugeIcons.strokeRoundedCalendar03);
  static final play = ExternalIcon(HugeIcons.strokeRoundedPlay);

  static final vidPlay = ExternalIcon(HugeIcons.strokeRoundedPlay);
  static final vidPause = ExternalIcon(HugeIcons.strokeRoundedPause);
  static final vidFastForward = ExternalIcon(HugeIcons.strokeRoundedForward01);
  static final vidFastRewind = ExternalIcon(HugeIcons.strokeRoundedBackward01);
  static final vidFullscreen = ExternalIcon(HugeIcons.strokeRoundedArrowExpand);
  static final vidCloseFullscreen = ExternalIcon(HugeIcons.strokeRoundedArrowShrink);
  static final vidMuted = ExternalIcon(HugeIcons.strokeRoundedVolumeMute01);
  static final vidVolume = ExternalIcon(HugeIcons.strokeRoundedVolumeHigh);
  static final vidSettings = ExternalIcon(HugeIcons.strokeRoundedSettings02);
  static final vidEpList = ExternalIcon(HugeIcons.strokeRoundedListVideo);
  static final vidMusicList = ExternalIcon(HugeIcons.strokeRoundedPlaylist01);

  static final vidBoxContain = ExternalIcon(HugeIcons.strokeRoundedSquare);
  static final vidBoxCover = ExternalIcon(HugeIcons.strokeRoundedArrowExpand01);
  static final vidBoxFill = ExternalIcon(HugeIcons.strokeRoundedGrid);

  static final share = ExternalIcon(HugeIcons.strokeRoundedShare01);
  static final download = ExternalIcon(HugeIcons.strokeRoundedDownload01);
  static final arrowRight = ExternalIcon(HugeIcons.strokeRoundedArrowRight01);
  static final arrowLeft = ExternalIcon(HugeIcons.strokeRoundedArrowLeft01);
  static final info = ExternalIcon(HugeIcons.strokeRoundedInformationCircle);
  static final noImage = ExternalIcon(HugeIcons.strokeRoundedImage01);

  static final tv = ExternalIcon(HugeIcons.strokeRoundedTv01);
  static final fastForward = ExternalIcon(HugeIcons.strokeRoundedForward01);
  static final dev = ExternalIcon(HugeIcons.strokeRoundedBug01);
  static final maintenance = ExternalIcon(HugeIcons.strokeRoundedAlertCircle);
  static final switchAcc = ExternalIcon(HugeIcons.strokeRoundedUserAdd01);
  static final logout = ExternalIcon(HugeIcons.strokeRoundedLogout01);
  static final check = ExternalIcon(HugeIcons.strokeRoundedTick01);
  static final delete = ExternalIcon(HugeIcons.strokeRoundedDelete01);
  static final user = ExternalIcon(HugeIcons.strokeRoundedUser);
  static final edit = ExternalIcon(HugeIcons.strokeRoundedPencilEdit01);
  static final editUser = ExternalIcon(HugeIcons.strokeRoundedUserEdit01);
  static final sync = ExternalIcon(HugeIcons.strokeRoundedRefresh);
  static final error = ExternalIcon(HugeIcons.strokeRoundedAlert01);
  static final cancel = ExternalIcon(HugeIcons.strokeRoundedCancel01);
  static final expand = ExternalIcon(HugeIcons.strokeRoundedExpand);

  static final weather = ExternalIcon(HugeIcons.strokeRoundedCloud);
  static final spring = ExternalIcon(HugeIcons.strokeRoundedFlower);
  static final summer = ExternalIcon(HugeIcons.strokeRoundedSun01);
  static final fall = ExternalIcon(HugeIcons.strokeRoundedWindPower01);
  static final winter = ExternalIcon(HugeIcons.strokeRoundedSnow);

  static final star = ExternalIcon(HugeIcons.strokeRoundedStar);
  static final episode = ExternalIcon(HugeIcons.strokeRoundedVideo01);
  static final source = ExternalIcon(HugeIcons.strokeRoundedCircle);
  static final country = ExternalIcon(HugeIcons.strokeRoundedFlag01);
  static final building = ExternalIcon(HugeIcons.strokeRoundedBuilding01);
  static final link = ExternalIcon(HugeIcons.strokeRoundedLink01);

  static final radio = NormalIcon(Icons.radio_rounded);
  static final music = NormalIcon(Icons.music_note_rounded);
  static final noShuffle = ExternalIcon(HugeIcons.strokeRoundedListView);
  static final shuffle = ExternalIcon(HugeIcons.strokeRoundedShuffle);

  static List<IconSource> getAllIcons() {
    return [
      home,
      community,
      search,
      bookmarks,
      settings,
      clock,
      calendar,
      play,
      share,
      download,
      arrowRight,
      arrowLeft,
      info,
      noImage,
      tv,
      fastForward,
      dev,
      switchAcc,
      logout,
      check,
      delete,
      user,
      edit,
      editUser,
      error,
      cancel,
      expand,
      spring,
      summer,
      fall,
      winter,
      star,
      episode,
      source,
      country,
      building,
      link,
      radio,
    ];
  }
}
