import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class LumashaBottomNav extends StatelessWidget {
  const LumashaBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return BottomNavigationBar(
      currentIndex: _currentIndex(location),
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
          case 1:
            context.go('/path');
          case 2:
            context.go('/rewards');
          case 3:
            context.go('/profile');
        }
      },
      selectedItemColor: LumashaColors.primary,
      unselectedItemColor: LumashaColors.primaryFaint,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Path'),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events),
          label: 'Rewards',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  int _currentIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/path')) return 1;
    if (location.startsWith('/rewards')) return 2;
    if (location.startsWith('/profile') || location.startsWith('/admin'))
      return 3;
    return 0;
  }
}
