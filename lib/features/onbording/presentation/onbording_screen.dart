import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumasha/features/onbording/presentation/widgets/ob_step_country.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import '../../../provider/music_provider.dart';
import 'widgets/ob_step_welcome.dart';
import 'widgets/ob_step_age.dart';
import 'widgets/ob_step_goal.dart';
import 'widgets/ob_step_ethnicity.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(onboardingStepProvider);
    return Scaffold(
      body: Container(
        color: Colors.white, 
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(step),
              child: _stepWidget(step),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepWidget(int step) {
    switch (step) {
      case 1:
        return const ObStepWelcome();
      case 2:
        return const ObStepAge();
      case 3:
        return const ObStepGoal();
      case 4:
        return const ObStepCountry();
      case 5:
        return const ObStepEthnicity();
      default:
        return const ObStepWelcome();
    }
  }
}
