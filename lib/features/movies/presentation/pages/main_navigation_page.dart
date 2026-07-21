import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationPage({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 58,
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.secondary,
              selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.crop_square_sharp, size: 18),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.square_sharp, size: 18),
                  ),
                  label: 'EXPLORE',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.search_sharp, size: 18),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.saved_search_sharp, size: 18),
                  ),
                  label: 'SEARCH',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.favorite_border_sharp, size: 18),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.favorite_sharp, size: 18),
                  ),
                  label: 'FAVORITES',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.settings_outlined, size: 18),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 3.0),
                    child: Icon(Icons.settings_sharp, size: 18),
                  ),
                  label: 'SETTINGS',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
