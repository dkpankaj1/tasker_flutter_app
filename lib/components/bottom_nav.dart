import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyBottomNavigation extends StatelessWidget {
  const MyBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    int selectedIndex = 0;
    if (location.startsWith('/tasks')) {
      selectedIndex = 1;
    }

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        if (index == 0) {
          context.go('/');
        } else if (index == 1) {
          context.go('/tasks');
        }
      },
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: "Home"),
        NavigationDestination(icon: Icon(Icons.task), label: "Task"),
      ],
    );
  }
}
