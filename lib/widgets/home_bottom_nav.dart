import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumasha/core/theme/app_colors.dart';
import 'package:lumasha/widgets/nav_bar.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: LumashaColors.surface, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                active: true,
                onTap: () {},
              ),
              NavItem(
                icon: Icons.route_rounded,
                label: 'Path',
                active: false,
                onTap: () => context.push('/path'),
              ),
              NavItem(
                icon: Icons.emoji_events_rounded,
                label: 'Rewards',
                active: false,
                onTap: () => context.push('/rewards'),
              ),
              NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: false,
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
