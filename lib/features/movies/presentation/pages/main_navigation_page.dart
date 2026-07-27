import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cineui/cineui.dart';
import 'package:responsive/layout.dart';
import '../../../../core/router/routes.dart';

class MainNavigationPage extends StatelessWidget {
  final StatefulNavigationShell? navigationShell;
  final Widget? child;
  final int selectedIndex;

  const MainNavigationPage({
    super.key,
    this.navigationShell,
    this.child,
    this.selectedIndex = 0,
  });

  int get _currentIndex {
    if (navigationShell != null) {
      return navigationShell!.currentIndex;
    }
    return selectedIndex;
  }

  void _onTap(BuildContext context, int index) {
    if (navigationShell != null) {
      navigationShell!.goBranch(
        index,
        initialLocation: index == navigationShell!.currentIndex,
      );
    } else {
      switch (index) {
        case 0:
          context.go(Routes.home.path);
          break;
        case 1:
          context.go(Routes.search.path);
          break;
        case 2:
          context.go(Routes.settings.path);
          break;
      }
    }
  }

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
        icon: CineIcons.settings,
        id: 2,
      ),
    ];

    final activeIndex = _currentIndex;

    final horizontalNav = CineNavigationBar<int>(
      direction: Axis.horizontal,
      items: navItems,
      currentIndex: activeIndex,
      onTap: (index) => _onTap(context, index),
    );

    final verticalNav = CineNavigationBar<int>(
      direction: Axis.vertical,
      items: navItems,
      currentIndex: activeIndex,
      onTap: (index) => _onTap(context, index),
    );

    final pageBody = navigationShell ?? child ?? const SizedBox.shrink();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: Scaffold(
          body: pageBody,
          bottomNavigationBar: horizontalNav,
        ),
        tablet: Row(
          children: [
            verticalNav,
            Expanded(child: pageBody),
          ],
        ),
        desktop: Row(
          children: [
            verticalNav,
            Expanded(child: pageBody),
          ],
        ),
        tv: Row(
          children: [
            verticalNav,
            Expanded(child: pageBody),
          ],
        ),
      ),
    );
  }
}
