import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../features/movies/presentation/pages/home_page.dart';
import '../../features/movies/presentation/pages/search_page.dart';
import '../../features/movies/presentation/pages/favorites_page.dart';
import '../../features/movies/presentation/pages/settings_page.dart';
import '../../features/movies/presentation/pages/detail_page.dart';
import '../../features/movies/presentation/pages/main_navigation_page.dart';
import '../../features/tv_shows/presentation/pages/tv_show_detail_page.dart';
import '../../features/video_player/presentation/pages/video_player_page.dart';
import '../di/service_locator.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idStr) ?? 0;
        return DetailPage(movieId: id);
      },
    ),
    GoRoute(
      path: '/play/movie/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idStr) ?? 0;
        final title = state.uri.queryParameters['title'] ?? '';
        final releaseDate = state.uri.queryParameters['releaseDate'] ?? '';
        return VideoPlayerPage(
          tmdbId: id,
          title: title,
          releaseDate: releaseDate,
          mediaType: 'movie',
        );
      },
    ),
    GoRoute(
      path: '/tv/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '';
        final id = int.tryParse(idStr) ?? 0;
        return TVShowDetailPage(tvShowId: id);
      },
    ),
    GoRoute(
      path: '/play/tv/:id/:season/:episode',
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
        return VideoPlayerPage(
          tmdbId: id,
          title: title,
          releaseDate: firstAirDate,
          mediaType: 'tv',
          seasonId: season,
          episodeId: episode,
        );
      },
    ),
    GoRoute(
      path: '/logs',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TalkerScreen(talker: sl<Talker>()),
    ),
  ],
);
