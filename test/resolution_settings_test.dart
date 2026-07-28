import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device/device.dart';

import 'package:cinehq/core/di/service_locator.dart' as di;
import 'package:cinehq/core/storage/local_storage.dart';
import 'package:cinehq/features/movies/presentation/pages/settings_page.dart';
import 'package:cinehq/features/video_player/presentation/cubits/continue_watching_cubit.dart';

import 'package:cineui/cineui.dart';

void main() {
  group('LocalStorage Default Resolution Setting Test', () {
    test('defaultResolution defaults to 1080p and saves user preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);

      expect(storage.getDefaultResolution(), equals('1080p'));

      await storage.setDefaultResolution('720p');
      expect(storage.getDefaultResolution(), equals('720p'));

      await storage.setDefaultResolution('1080p');
      expect(storage.getDefaultResolution(), equals('1080p'));
    });
  });

  group('SettingsPage Resolution Setting UI Test', () {
    setUp(() async {
      await Device.ensureInitialized(debugTvMode: false);
      SharedPreferences.setMockInitialValues({});
      dotenv.testLoad(fileInput: 'TMDB_API_KEY=');
      await di.init();
    });

    tearDown(() async {
      await di.sl.reset();
    });

    testWidgets('SettingsPage renders DEFAULT VIDEO RESOLUTION dropdown and changes resolution', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ContinueWatchingCubit>.value(
            value: di.sl<ContinueWatchingCubit>(),
            child: const SettingsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEFAULT VIDEO RESOLUTION'), findsOneWidget);
      expect(find.text('Preferred resolution tried first during playback. If unavailable, best alternative is picked.'), findsOneWidget);

      final localStorage = di.sl<LocalStorage>();
      expect(localStorage.getDefaultResolution(), equals('1080p'));

      // Find CineDropDown widget
      final dropdown = find.byType(CineDropDown<String>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Select '720p' option from open dropdown menu
      final item720p = find.text('720p').last;
      await tester.tap(item720p);
      await tester.pumpAndSettle();

      expect(localStorage.getDefaultResolution(), equals('720p'));
    });
  });
}
