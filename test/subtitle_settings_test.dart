import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device/device.dart';

import 'package:cinehq/core/di/service_locator.dart' as di;
import 'package:cinehq/core/storage/local_storage.dart';
import 'package:cinehq/core/utils/subtitle_utils.dart';
import 'package:cinehq/features/movies/presentation/pages/settings_page.dart';
import 'package:cinehq/features/video_player/presentation/cubits/continue_watching_cubit.dart';

void main() {
  group('Subtitle Utils Test', () {
    test('isEnglishSubtitle identifies English labels and language codes accurately', () {
      expect(isEnglishSubtitle('English'), isTrue);
      expect(isEnglishSubtitle('english'), isTrue);
      expect(isEnglishSubtitle('English [SDH]'), isTrue);
      expect(isEnglishSubtitle('English - Forced'), isTrue);
      expect(isEnglishSubtitle('en'), isTrue);
      expect(isEnglishSubtitle('eng'), isTrue);
      expect(isEnglishSubtitle('en-US'), isTrue);
      expect(isEnglishSubtitle('en_GB'), isTrue);
      expect(isEnglishSubtitle('ENG SDH'), isTrue);

      // URL pattern checks
      expect(isEnglishSubtitle('Subtitles 1', url: 'https://cdn.net/subs/en/1.vtt'), isTrue);
      expect(isEnglishSubtitle(null, url: 'https://cdn.net/subtitles/english_sdh.srt'), isTrue);

      // Generic label check
      expect(isEnglishSubtitle('Subtitles'), isTrue);
      expect(isEnglishSubtitle('Default'), isTrue);

      // Non-English checks
      expect(isEnglishSubtitle('Spanish'), isFalse);
      expect(isEnglishSubtitle('Español'), isFalse);
      expect(isEnglishSubtitle('es'), isFalse);
      expect(isEnglishSubtitle('French'), isFalse);
      expect(isEnglishSubtitle('fr'), isFalse);
      expect(isEnglishSubtitle('German'), isFalse);
      expect(isEnglishSubtitle('Estonian'), isFalse);
      expect(isEnglishSubtitle(null), isFalse);
      expect(isEnglishSubtitle(''), isFalse);
    });
  });

  group('LocalStorage Subtitle Setting Test', () {
    test('onlyEnglishSubtitles defaults to true and saves preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);

      expect(storage.isOnlyEnglishSubtitlesEnabled(), isTrue);

      await storage.setOnlyEnglishSubtitlesEnabled(false);
      expect(storage.isOnlyEnglishSubtitlesEnabled(), isFalse);

      await storage.setOnlyEnglishSubtitlesEnabled(true);
      expect(storage.isOnlyEnglishSubtitlesEnabled(), isTrue);
    });
  });

  group('SettingsPage Subtitle Setting UI Test', () {
    setUp(() async {
      await Device.ensureInitialized(debugTvMode: false);
      SharedPreferences.setMockInitialValues({});
      dotenv.testLoad(fileInput: 'TMDB_API_KEY=');
      await di.init();
    });

    tearDown(() async {
      await di.sl.reset();
    });

    testWidgets('SettingsPage renders ONLY LOAD ENGLISH SUBTITLES switch and toggles it', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ContinueWatchingCubit>.value(
            value: di.sl<ContinueWatchingCubit>(),
            child: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ONLY LOAD ENGLISH SUBTITLES'), findsOneWidget);
      expect(find.text('Only load and display English subtitles in the video player.'), findsOneWidget);

      final localStorage = di.sl<LocalStorage>();
      expect(localStorage.isOnlyEnglishSubtitlesEnabled(), isTrue);

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      // Toggle the English subtitles switch (the second switch in Playback Preferences)
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      expect(localStorage.isOnlyEnglishSubtitlesEnabled(), isFalse);
    });
  });
}
