import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AgencyShellScreen extends StatelessWidget {
  const AgencyShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'İlanlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Özet',
          ),
        ],
        onDestinationSelected: (idx) {
          navigationShell.goBranch(
            idx,
            initialLocation: idx == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
