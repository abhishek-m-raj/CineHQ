import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cineui/cineui.dart';
import 'package:responsive/layout.dart';

class MainNavigationPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final navItems = [
      CineNavbarItem(
        icon: CineIcons.home,
        id: 0,
      ),
      CineNavbarItem(
        icon: CineIcons.search,
        id: 1,
      ),
      CineNavbarItem(
        icon: CineIcons.bookmarks,
        id: 2,
      ),
      CineNavbarItem(
        icon: CineIcons.settings,
        id: 3,
      ),
    ];

    final horizontalNav = CineNavigationBar<int>(
      direction: Axis.horizontal,
      items: navItems,
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
    );

    final verticalNav = CineNavigationBar<int>(
      direction: Axis.vertical,
      items: navItems,
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: Scaffold(
          body: navigationShell,
          bottomNavigationBar: horizontalNav,
        ),
        tablet: Row(
          children: [
            verticalNav,
            Expanded(child: navigationShell),
          ],
        ),
        desktop: Row(
          children: [
            verticalNav,
            Expanded(child: navigationShell),
          ],
        ),
        tv: Row(
          children: [
            verticalNav,
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }
}
