import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../provider/music_provider.dart';
import '../../../../widgets/ObCTAButton.dart';
import '../../../../widgets/mascot_widget.dart';
import '../../../../provider/mascot_provider.dart';
import '../../providers/ethnicity_provider.dart';

class ObStepEthnicity extends ConsumerStatefulWidget {
  const ObStepEthnicity({super.key});

  @override
  ConsumerState<ObStepEthnicity> createState() => _ObStepEthnicityState();
}

class _ObStepEthnicityState extends ConsumerState<ObStepEthnicity> {
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
    final selected = ref.watch(onboardingProvider)['ethnicity'] as String?;
    final selectedCountry =
        ref.watch(onboardingProvider)['country'] as String? ?? 'NP';
    final ethnicitiesAsync = ref.watch(ethnicitiesProvider(selectedCountry));

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
                  const Text(
                    '🌸 Your cultural background? 🌸',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: LumashaColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personalises your culture lessons',
                    style:
                        TextStyle(fontSize: 14, color: LumashaColors.textMed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ethnicitiesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: Colors.red),
                                const SizedBox(height: 8),
                                Text('Failed to load ethnicities: $error'),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => ref.invalidate(
                                      ethnicitiesProvider(selectedCountry)),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (ethnicities) {
                          if (ethnicities.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text('No ethnicities found. Contact admin.'),
                              ),
                            );
                          }
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 18,
                            crossAxisSpacing: 18,
                            childAspectRatio: 1.0,
                            children: ethnicities.map((ethnicity) {
                              final isSelected = selected == ethnicity.name;
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(onboardingProvider.notifier)
                                      .setField('ethnicity', ethnicity.name);
                                  _showMascotGoodChoice();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: isSelected
                                        ? getColorFromHint(ethnicity.colorHint)
                                            .withOpacity(0.6)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? LumashaColors.primary
                                          : LumashaColors.primaryLight,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ethnicity.emoji,
                                        style: const TextStyle(fontSize: 52),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        ethnicity.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? LumashaColors.primary
                                              : LumashaColors.textDark,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _ProgressDots(current: 5),
                  const SizedBox(height: 24),
                  ObCTAButton(
                    label: 'Start Learning! 🎉',
                    enabled: selected != null,
                    onTap: () async {
                      final success = await ref
                          .read(onboardingProvider.notifier)
                          .saveProfile();
                      await ref
                          .read(onboardingMusicControllerProvider)
                          .stopMusic();
                      if (success && context.mounted) {
                        context.go('/home');
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to save profile. Check your internet and try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    height: 56,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Floating mascot
            Positioned(
              bottom: 20,
              right: 20,
              child: MascotWidget(size: 70),
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
        final active = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 40 : 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: active
                ? LumashaColors.primary
                : LumashaColors.primaryLight.withOpacity(0.4),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: LumashaColors.primary.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
