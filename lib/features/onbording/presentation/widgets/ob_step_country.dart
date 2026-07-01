import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/ObCTAButton.dart';
import '../../../../widgets/mascot_widget.dart';
import '../../../../provider/mascot_provider.dart';

class CountryOption {
  final String code;
  final String name;
  final String flag;
  const CountryOption(this.code, this.name, this.flag);
}

const List<CountryOption> CountryOptions = [
  CountryOption('NP', 'Nepal', '🇳🇵'),
  CountryOption('IN', 'India', '🇮🇳'),
  CountryOption('US', 'USA', '🇺🇸'),
  CountryOption('GB', 'UK', '🇬🇧'),
  CountryOption('AU', 'Australia', '🇦🇺'),
];

class ObStepCountry extends ConsumerStatefulWidget {
  const ObStepCountry({super.key});

  @override
  ConsumerState<ObStepCountry> createState() => _ObStepCountryState();
}

class _ObStepCountryState extends ConsumerState<ObStepCountry> {
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
    final selected = ref.watch(onboardingProvider)['country'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '🌏 Where are you from? 🌏',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: LumashaColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Helps us tailor content to where you live",
                    style:
                        TextStyle(fontSize: 14, color: LumashaColors.textMed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.0,
                    children: CountryOptions.map((c) {
                      final isSelected = selected == c.code;
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(onboardingProvider.notifier)
                              .setField('country', c.code);
                          _showMascotGoodChoice();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? LumashaColors.primaryFaint.withOpacity(0.6)
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
                                c.flag,
                                style: const TextStyle(fontSize: 44),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c.name,
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
                  ),
                  const SizedBox(height: 28),
                  _ProgressDots(current: 4),
                  const SizedBox(height: 24),
                  ObCTAButton(
                    label: 'Continue →',
                    enabled: selected != null,
                    onTap: () =>
                        ref.read(onboardingStepProvider.notifier).state = 5,
                    height: 56,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
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
