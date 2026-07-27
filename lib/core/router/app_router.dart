import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/movies/presentation/pages/home_page.dart';
import '../../features/movies/presentation/pages/search_page.dart';
import '../../features/movies/presentation/pages/settings_page.dart';
import '../../features/movies/presentation/pages/detail_page.dart';
import '../../features/movies/presentation/pages/main_navigation_page.dart';
import '../../features/tv_shows/presentation/pages/tv_show_detail_page.dart';
import '../../features/video_player/presentation/pages/video_player_page.dart';
import '../di/service_locator.dart';
import 'routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  static GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: Routes.home.path,
        observers: [
          TalkerRouteObserver(sl<Talker>()),
        ],
        routes: <RouteBase>[
          if (Device.isTv) ...tvNavRoutes else ...nonTvNavRoutes,
          ...mediaRoutes,
          ...miscPages,
        ],
      );

  static List<RouteBase> get tvNavRoutes {
    return [
      GoRoute(
        name: Routes.home.name,
        path: Routes.home.path,
        builder: (context, state) => const MainNavigationPage(
          selectedIndex: 0,
          child: HomePage(),
        ),
      ),
      GoRoute(
        name: Routes.search.name,
        path: Routes.search.path,
        builder: (context, state) => const MainNavigationPage(
          selectedIndex: 1,
          child: SearchPage(),
        ),
      ),
      GoRoute(
        name: Routes.settings.name,
        path: Routes.settings.path,
        builder: (context, state) => const MainNavigationPage(
          selectedIndex: 2,
          child: SettingsPage(),
        ),
      ),
    ];
  }

  static List<RouteBase> get nonTvNavRoutes {
    return [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.home.name,
                path: Routes.home.path,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.search.name,
                path: Routes.search.path,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: Routes.settings.name,
                path: Routes.settings.path,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }

  static List<RouteBase> get mediaRoutes {
    return [
      GoRoute(
        name: Routes.movieDetails.name,
        path: Routes.movieDetails.path,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '';
          final id = int.tryParse(idStr) ?? 0;
          return DetailPage(movieId: id);
        },
      ),
      GoRoute(
        name: Routes.moviePlay.name,
        path: Routes.moviePlay.path,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '';
          final id = int.tryParse(idStr) ?? 0;
          final title = state.uri.queryParameters['title'] ?? '';
          final releaseDate = state.uri.queryParameters['releaseDate'] ?? '';
          final posterPath = state.uri.queryParameters['posterPath'];
          final backdropPath = state.uri.queryParameters['backdropPath'];
          return VideoPlayerPage(
            tmdbId: id,
            title: title,
            releaseDate: releaseDate,
            mediaType: 'movie',
            posterPath: posterPath,
            backdropPath: backdropPath,
          );
        },
      ),
      GoRoute(
        name: Routes.tvDetails.name,
        path: Routes.tvDetails.path,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '';
          final id = int.tryParse(idStr) ?? 0;
          return TVShowDetailPage(tvShowId: id);
        },
      ),
      GoRoute(
        name: Routes.tvPlay.name,
        path: Routes.tvPlay.path,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '';
          final id = int.tryParse(idStr) ?? 0;
          final seasonStr = state.pathParameters['season'] ?? '1';
          final season = int.tryParse(seasonStr) ?? 1;
          final episodeStr = state.pathParameters['episode'] ?? '1';
          final episode = int.tryParse(episodeStr) ?? 1;
          final title = state.uri.queryParameters['title'] ?? '';
          final firstAirDate = state.uri.queryParameters['firstAirDate'] ?? '';
          final posterPath = state.uri.queryParameters['posterPath'];
          final backdropPath = state.uri.queryParameters['backdropPath'];
          return VideoPlayerPage(
            tmdbId: id,
            title: title,
            releaseDate: firstAirDate,
            mediaType: 'tv',
            seasonId: season,
            episodeId: episode,
            posterPath: posterPath,
            backdropPath: backdropPath,
          );
        },
      ),
    ];
  }

  static List<RouteBase> get miscPages {
    return [
      GoRoute(
        name: Routes.logs.name,
        path: Routes.logs.path,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => TalkerScreen(talker: sl<Talker>()),
      ),
    ];
  }
}

final goRouter = AppRouter.router;
