import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/ObCTAButton.dart';
import '../../../../widgets/mascot_widget.dart';
import '../../../../provider/mascot_provider.dart';

class ObStepGoal extends ConsumerStatefulWidget {
  const ObStepGoal({super.key});

  @override
  ConsumerState<ObStepGoal> createState() => _ObStepGoalState();
}

class _ObStepGoalState extends ConsumerState<ObStepGoal> {
  void _showMascotGoodChoice() {
    ref.read(mascotMoodProvider.notifier).state = MascotMood.happy;
    ref.read(mascotMessageProvider.notifier).state = 'Good choice! 🎉';
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ref.read(mascotMoodProvider.notifier).state = MascotMood.idle;
        ref.read(mascotMessageProvider.notifier).state = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(onboardingProvider)['dailyGoalMin'] as int? ?? 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                   const SizedBox(height: 20),
                   Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🎯 Set your daily goal 🎯',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: LumashaColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consistency beats intensity!',
                          style: TextStyle(fontSize: 14, color: LumashaColors.textMed),
                        ),
                        const SizedBox(height: 32),
                        _GoalChip(
                          emoji: '🌱',
                          title: 'Casual — 5 min/day',
                          subtitle: '2 lessons · Easy streak',
                          xp: '+10 XP',
                          selected: selected == 5,
                          onTap: () {
                            ref.read(onboardingProvider.notifier).setField('dailyGoalMin', 5);
                            _showMascotGoodChoice();
                          },
                        ),
                        const SizedBox(height: 12),
                        _GoalChip(
                          emoji: '⚡',
                          title: 'Regular — 10 min/day',
                          subtitle: '4 lessons · Good streak',
                          xp: '+20 XP',
                          selected: selected == 10,
                          onTap: () {
                            ref.read(onboardingProvider.notifier).setField('dailyGoalMin', 10);
                            _showMascotGoodChoice();
                          },
                        ),
                        const SizedBox(height: 12),
                        _GoalChip(
                          emoji: '🔥',
                          title: 'Intense — 15 min/day',
                          subtitle: '6 lessons · Max streak',
                          xp: '+30 XP',
                          selected: selected == 15,
                          onTap: () {
                            ref.read(onboardingProvider.notifier).setField('dailyGoalMin', 15);
                            _showMascotGoodChoice();
                          },
                        ),
                        const SizedBox(height: 32),
                        _ProgressDots(current: 3),
                      ],
                    ),
                  ),
                  // Button at the bottom
                  ObCTAButton(
                    label: 'Continue →',
                    enabled: true,
                    onTap: () => ref.read(onboardingStepProvider.notifier).state = 4,
                    height: 56,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Positioned(
              bottom: 120,
              right: 20,
              child: MascotWidget(size: 70),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String xp;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected ? LumashaColors.primaryFaint : Colors.white,
          border: Border.all(
            color: selected ? LumashaColors.primary : LumashaColors.primaryLight,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? LumashaColors.primary : LumashaColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? LumashaColors.primaryLight : LumashaColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: LumashaColors.accentFaint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                xp,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: LumashaColors.accent,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  final int current;
  const _ProgressDots({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final done = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: done ? 32 : 12,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: done ? LumashaColors.primary : LumashaColors.primaryLight.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}