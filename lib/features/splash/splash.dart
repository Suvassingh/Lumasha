import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../provider/music_provider.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  return await supabase.from('users').select().eq('id', user.id).maybeSingle();
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<String> _letters = ['L', 'u', 'ma', 'षा'];
  bool _showButton = false;

  // Duration for one complete bounce of a single letter (up + down)
  static const Duration _bounceDuration = Duration(milliseconds: 600);
  // Total cycle duration = bounce duration * number of letters
  late final Duration _cycleDuration = _bounceDuration * _letters.length;

  // Bounce curve: up with bounce out, down linear
  double _bounceValue(double t) {
    if (t < 0.5) {
      final double u = t * 2;
      final double bounce = Curves.bounceOut.transform(u);
      return -12 * bounce;
    } else {
      final double u = (t - 0.5) * 2;
      return -12 + (12 * u);
    }
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _playBackgroundMusic();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: _cycleDuration,
    )..repeat(); // Loop forever
  }

  Future<void> _playBackgroundMusic() async {
    try {
      ref.read(onboardingMusicControllerProvider).startMusic();
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> _stopBackgroundMusic() async {
    ref.read(onboardingMusicControllerProvider).stopMusic();
  }

  Future<void> _handleGetStarted() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      if (mounted) context.go('/onboarding');
      return;
    }

    final profile = await ref.read(userProfileProvider.future);
    final isFirstLaunch = profile?['is_first_launch'] ?? true;

    if (mounted) {
      if (isFirstLaunch) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.08),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sequential bouncing letters
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final double value = _controller.value;
                      // Determine which letter is currently bouncing
                      final int letterIndex = (value * _letters.length).floor();
                      final double phase =
                          (value * _letters.length) - letterIndex;
                      final bool isActive = letterIndex < _letters.length;
                      final double translateY =
                          isActive ? _bounceValue(phase) : 0.0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_letters.length, (index) {
                          return Flexible(
                            child: Transform.translate(
                              offset: Offset(
                                  0, index == letterIndex ? translateY : 0),
                              child: Text(
                                _letters[index],
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _getColorForLetter(_letters[index]),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Masked gradient tagline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xfff79313),
                        Color(0xfffbcd3c),
                        Color(0xfff0665d),
                        Color(0xffff0000),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Column(
                      children: [
                        const Text(
                          'LEARN LOCAL,',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 120),
                          child: const Text(
                            'SPEAK GLOBAL',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_showButton)
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: ElevatedButton(
                    onPressed: _handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xfff79313),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Get Started'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForLetter(String letter) {
    switch (letter) {
      case 'L':
        return const Color(0xfff79313);
      case 'u':
        return const Color(0xfff0665d);
      case 'ma':
        return const Color(0xff3b82f6);
      case 'षा':
        return const Color(0xfffbcd3c);
      default:
        return Colors.black;
    }
  }
}

