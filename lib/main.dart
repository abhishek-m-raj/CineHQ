import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/di/service_locator.dart' as di;
import 'core/di/talker_bloc_observer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return BlocProvider<ThemeCubit>(
      create: (context) => di.sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'CineHQ.',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: goRouter,
          );
        },
      ),
    );
  }
}
