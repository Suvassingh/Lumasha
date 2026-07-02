import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumasha/core/theme/app_colors.dart';
import 'package:lumasha/features/home/provider/home_provider.dart';

import '../../../widgets/lumasha_bottom_nav.dart';

class RewardScreen extends ConsumerWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: LumashaColors.background,
        bottomNavigationBar: const LumashaBottomNav(),
        body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(homeUserProfileProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                    hasScrollBody: true,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Positioned(
                            child: SafeArea(
                                child: Column(
                          children: [Text("Reward")],
                        )))
                      ],
                    ))
              ],
            )));
  }
}
