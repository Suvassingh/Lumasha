import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/ObCTAButton.dart';
import '../../../../widgets/mascot_widget.dart';
import '../../../../provider/mascot_provider.dart';    

class ObStepAge extends ConsumerStatefulWidget {
  const ObStepAge({super.key});

  @override
  ConsumerState<ObStepAge> createState() => _ObStepAgeState();
}

class _ObStepAgeState extends ConsumerState<ObStepAge>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

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
    final selected = ref.watch(onboardingProvider)['ageGroup'] as String?;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final bounceValue = Curves.elasticOut.transform(
                        _bounceController.value,
                      );
                      return Transform.scale(
                        scale: 1.0 + (bounceValue * 0.08),
                        child: child,
                      );
                    },
                    child: const Text(
                      '🎂 How old are you? 🎂',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: LumashaColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We'll adjust the lessons to fit!",
                    style: TextStyle(fontSize: 14, color: LumashaColors.textMed),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeController,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Curves.easeOutCubic,
                        )),
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _AgeTile(
                              svgPath: 'assets/images/Exercise.svg',
                              label: '4 – 7 years',
                              sub: 'Beginner explorer',
                              iconSize: 100,
                              selected: selected == '4-7',
                              onTap: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setField('ageGroup', '4-7');
                                _showMascotGoodChoice();  
                              },
                            ),
                            _AgeTile(
                              svgPath: 'assets/images/Child.svg',
                              label: '8 – 12 years',
                              sub: 'Active learner',
                              iconSize: 100,
                              selected: selected == '8-12',
                              onTap: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setField('ageGroup', '8-12');
                                _showMascotGoodChoice();
                              },
                            ),
                            _AgeTile(
                              svgPath: 'assets/images/Boy.svg',
                              label: '13 – 17 years',
                              sub: 'Teen achiever',
                              iconSize: 100,
                              selected: selected == '13-17',
                              onTap: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setField('ageGroup', '13-17');
                                _showMascotGoodChoice();
                              },
                            ),
                            _AgeTile(
                              svgPath: 'assets/images/Friend.svg',
                              label: '18+ years',
                              sub: 'Heritage seeker',
                              iconSize: 100,
                              selected: selected == '18+',
                              onTap: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .setField('ageGroup', '18+');
                                _showMascotGoodChoice();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProgressDots(current: 2),
                  const SizedBox(height: 12),
                   ObCTAButton(
                    label: 'Continue',
                    enabled: selected != null,
                    onTap: () => ref
                        .read(onboardingStepProvider.notifier)
                        .state = 3,
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

 class _AgeTile extends StatefulWidget {
  final String svgPath;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;

  const _AgeTile({
    required this.svgPath,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
    this.iconSize = 50,
  });

  @override
  State<_AgeTile> createState() => _AgeTileState();
}

class _AgeTileState extends State<_AgeTile> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late AnimationController _selectController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.selected) _selectController.forward();
  }

  @override
  void didUpdateWidget(_AgeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _selectController.forward(from: 0.0);
    } else if (!widget.selected && oldWidget.selected) {
      _selectController.reverse();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _selectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: widget.selected ? LumashaColors.primaryFaint : Colors.white,
          border: Border.all(
            color: widget.selected
                ? LumashaColors.primary
                : LumashaColors.primaryLight,
            width: widget.selected ? 3 : 1.5,
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
            AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _selectController]),
              builder: (context, child) {
                final pulse = 1.0 + (_pulseController.value * 0.04);
                final select = 1.0 + (_selectController.value * 0.08);
                final scale = pulse * select;
                final rotation = _selectController.value * 0.12;
                return Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                widget.svgPath,
                width: widget.iconSize,
                height: widget.iconSize,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.selected
                    ? LumashaColors.primary
                    : LumashaColors.textDark,
                fontSize: 14,
              ),
            ),
            Text(
              widget.sub,
              style: TextStyle(
                color: widget.selected
                    ? LumashaColors.primaryLight
                    : LumashaColors.textLight,
                fontSize: 10,
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