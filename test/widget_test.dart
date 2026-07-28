import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device/device.dart';

import 'package:cinehq/main.dart';
import 'package:cinehq/core/di/service_locator.dart' as di;

void main() {
  setUp(() async {
    // Initialize Device package
    await Device.ensureInitialized(debugTvMode: false);

    // Mock shared preferences channel
    SharedPreferences.setMockInitialValues({});

    // Load mock env values for tests
    dotenv.testLoad(fileInput: 'TMDB_API_KEY=');
    
    // Initialize dependency injection
    await di.init();
  });

  tearDown(() async {
    await di.sl.reset();
  });

  testWidgets('App renders main navigation layout smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Pump initial frame
    await tester.pump(const Duration(milliseconds: 600)); // Allow mock timer delay

    // Verify that MyApp is rendered cleanly
    expect(find.byType(MyApp), findsOneWidget);

    // Replace widget tree and advance clock to flush pending timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
