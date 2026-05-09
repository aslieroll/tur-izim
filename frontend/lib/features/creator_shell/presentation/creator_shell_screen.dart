import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation host for authenticated creator UX.
class CreatorShellScreen extends StatelessWidget {
  const CreatorShellScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _tap(int idx) {
    navigationShell.goBranch(
      idx,
      initialLocation: idx == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Turlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Başvurular',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Atamalar',
          ),
        ],
        onDestinationSelected: _tap,
      ),
    );
  }
}
