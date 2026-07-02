import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumasha/features/home/presentation/home_screen.dart';
import 'package:lumasha/features/onbording/presentation/onbording_screen.dart';
import 'package:lumasha/features/splash/splash.dart';
import 'package:lumasha/widgets/lumasha_bottom_nav.dart';

import '../../features/home/presentation/reward_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Root route uses SplashScreen
      GoRoute(
        path: '/',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
          path: '/rewards',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (_, __) => const RewardScreen())
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
});

class LumashaScaffold extends StatelessWidget {
  final Widget child;
  const LumashaScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const LumashaBottomNav(),
    );
  }
}


//suvas
