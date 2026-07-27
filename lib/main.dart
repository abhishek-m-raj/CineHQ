import 'package:device/device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:media_kit/media_kit.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:video/video.dart';
import 'package:video_official/video_official.dart';
import 'package:video_media_kit/video_media_kit.dart';

import 'core/di/service_locator.dart' as di;
import 'core/di/talker_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/video_player/presentation/cubits/continue_watching_cubit.dart';


final shortcuts = {
  if (Device.isTv) ...{
    if (Device.isDesktop)
      LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
    LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
    LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(
      TraversalDirection.left,
    ),
    LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(
      TraversalDirection.right,
    ),
    LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(
      TraversalDirection.down,
    ),
    LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(
      TraversalDirection.up,
    ),
  },
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Device.ensureInitialized(debugTvMode: true);
  MediaKit.ensureInitialized();

  await Video.initialize({
    PlatformType.android: VideoPlayerConfig(
      factory: () => OfficialPlayer(),
      initialize: () async => MediaKitPlayer.initialize(),
    ),
    PlatformType.iOS: VideoPlayerConfig(
      factory: () => MediaKitPlayer(),
      initialize: () async => MediaKitPlayer.initialize(),
    ),
    PlatformType.macOS: VideoPlayerConfig(
      factory: () => MediaKitPlayer(),
      initialize: () async => MediaKitPlayer.initialize(),
    ),
    PlatformType.windows: VideoPlayerConfig(
      factory: () => MediaKitPlayer(),
      initialize: () async => MediaKitPlayer.initialize(),
    ),
    PlatformType.linux: VideoPlayerConfig(
      factory: () => MediaKitPlayer(),
      initialize: () async => MediaKitPlayer.initialize(),
    ),
  });

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Dependency Injection container
  await di.init();

  final talker = di.sl<Talker>();

  // Set Talker Bloc Observer
  Bloc.observer = TalkerBlocObserver(talker);

  // Handle Flutter errors
  FlutterError.onError = (details) {
    talker.handle(details.exception, details.stack);
  };

  // Handle platform/Dart asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => di.sl<ThemeCubit>(),
        ),
        BlocProvider<ContinueWatchingCubit>(
          create: (context) => di.sl<ContinueWatchingCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'CineHQ.',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: goRouter,
            shortcuts: shortcuts,
          );
        },
      ),
    );
  }
}

