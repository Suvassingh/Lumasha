import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lumasha/features/onbording/providers/onbording_provider.dart';
import 'package:lumasha/widgets/ObCTAButton.dart';
import 'package:lumasha/widgets/mascot_widget.dart';
import '../../../../core/theme/app_colors.dart';

class ObStepWelcome extends ConsumerStatefulWidget {
  const ObStepWelcome({super.key});

  @override
  ConsumerState<ObStepWelcome> createState() => _ObStepWelcomeState();
}

class _ObStepWelcomeState extends ConsumerState<ObStepWelcome>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _usernameError;
  bool _isUsernameAvailable = false;

  late AnimationController _bounceController;
  final List<String> _lumashaChars = ['L', 'u', 'ma', 'षा'];
  final List<Color> _charColors = [
    const Color(0xfff79313),
    const Color(0xfff0665d),
    const Color(0xff3b82f6),
    const Color(0xfffbcd3c),
  ];
  static const Duration _bounceDuration = Duration(milliseconds: 600);
  late final Duration _cycleDuration = _bounceDuration * _lumashaChars.length;

   late AnimationController _particleController;
  late List<Particle> _particles;

   late AnimationController _mascotScaleController;
  late Animation<double> _mascotScale;
  late AnimationController _boyBounceController;
  late AnimationController _starPulseController;
  late AnimationController _journeyFloatController;
  @override
  void initState() {
    super.initState();
    final existingName = ref.read(onboardingProvider)['name'];
    final existingUsername = ref.read(onboardingProvider)['username'];
    if (existingName != null) _nameController.text = existingName;
    if (existingUsername != null) _usernameController.text = existingUsername;

     _bounceController = AnimationController(
      vsync: this,
      duration: _cycleDuration,
    )..repeat();

     _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _initParticles();

     _mascotScaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _mascotScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _mascotScaleController, curve: Curves.easeInOut),
    );
  }

  void _initParticles() {
    final random = math.Random();
    _particles = List.generate(25, (index) {
      return Particle(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        size: random.nextDouble() * 8 + 3,
        speedX: random.nextDouble() * 0.8 - 0.4,
        speedY: random.nextDouble() * 0.8 - 0.4,
        color: [
          LumashaColors.primaryLight,
          LumashaColors.accent,
          LumashaColors.primaryFaint,
          Colors.pink.shade200,
          Colors.green.shade200,
        ][random.nextInt(5)],
      );
    });
     _boyBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

     _starPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

     _journeyFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bounceController.dispose();
    _particleController.dispose();
    _mascotScaleController.dispose();
    _boyBounceController.dispose();
    _starPulseController.dispose();
    _journeyFloatController.dispose();
    super.dispose();
  }

  double _bounceValue(double t) {
    if (t < 0.5) {
      final double u = t * 2;
      final double bounce = Curves.bounceOut.transform(u);
      return -20 * bounce;
    } else {
      final double u = (t - 0.5) * 2;
      return -20 + (20 * u);
    }
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
     if (username.isEmpty) {
      setState(() {
        _usernameError = null;
        _isUsernameAvailable = false;
      });
      return;
    }
    try {
      final isTaken = await ref
          .read(onboardingProvider.notifier)
          .isUsernameTaken(username);
       setState(() {
        _usernameError = isTaken ? '✨ Username already taken ✨' : null;
        _isUsernameAvailable = !isTaken;
      });
    } catch (e, stack) {
       setState(() {
        _usernameError = ' Network error. Check your internet.';
        _isUsernameAvailable = false;
      });
    }
  }

  Future<void> _onContinue() async {
    if (mounted) {
      ref.read(onboardingStepProvider.notifier).state = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
           AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _particleController.value),
                size: screenSize,
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                   AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      final double value = _bounceController.value;
                      final int charIndex = (value * _lumashaChars.length).floor();
                      final double phase = (value * _lumashaChars.length) - charIndex;
                      final bool isActive = charIndex < _lumashaChars.length;
                      final double translateY = isActive ? _bounceValue(phase) : 0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_lumashaChars.length, (index) {
                          return Transform.translate(
                            offset: Offset(0, index == charIndex ? translateY : 0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    _charColors[index],
                                    _charColors[index].withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                blendMode: BlendMode.srcIn,
                                child: Text(
                                  _lumashaChars[index],
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 24),
                   ScaleTransition(
                    scale: _mascotScale,
                    child: MascotWidget(size: 130),
                  ),
                  const SizedBox(height: 32),

                        Text(
                          "Learn Nepali culture & language!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: LumashaColors.textDark,
                          ),
                        ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AnimatedBuilder(
                          animation: _boyBounceController,
                          builder: (context, child) {
                             final offsetY = -4 * _boyBounceController.value;
                            return Transform.translate(
                              offset: Offset(0, offsetY),
                              child: child,
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/Boy.svg',
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      hintText: "What's your name?",
                      hintStyle: TextStyle(
                        color: LumashaColors.textLight,
                        fontSize: 16,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: LumashaColors.primaryLight, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: LumashaColors.primary, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    onChanged: (v) =>
                        ref.read(onboardingProvider.notifier).setField('name', v),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AnimatedBuilder(
                          animation: _starPulseController,
                          builder: (context, child) {
                             final scale =
                                1.0 + (_starPulseController.value * 0.15);
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: SvgPicture.asset(
                            'assets/images/Username.svg',
                            width: 38,
                            height: 38,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      suffixIcon: _usernameController.text.isNotEmpty
                          ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isUsernameAvailable
                            ? const Icon(Icons.check_circle, key: ValueKey('check'), color: Colors.green)
                            : _usernameError != null
                            ? const Icon(Icons.error, key: ValueKey('error'), color: Colors.red)
                            : const SizedBox.shrink(),
                      )
                          : null,
                      hintText: "Create a username",
                      hintStyle: TextStyle(color: LumashaColors.textLight, fontSize: 16),
                      helperText: "🌟 No spaces, unique and fun! 🌟",
                      helperStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: LumashaColors.primaryLight, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: LumashaColors.primary, width: 2.5),
                      ),
                      errorText: _usernameError,
                      errorStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    ),
                    onChanged: (v) {
                      ref.read(onboardingProvider.notifier).setField('username', v);
                      _checkUsername();
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressDot(0, true),
                      _buildProgressDot(1, false),
                      _buildProgressDot(2, false),
                      _buildProgressDot(3, false),
                      _buildProgressDot(4, false), 
                    ],
                  ),
                  const SizedBox(height: 24),
             ObCTAButton(
                    label: "Start My Adventure!   ",
                    svgIcon: 'assets/images/Journey.svg',
                    iconSize: 100,
                    iconAnimationController:
                        _journeyFloatController, 
                    enabled: _nameController.text.trim().isNotEmpty &&
                        _usernameController.text.trim().isNotEmpty &&
                        _isUsernameAvailable,
                    onTap: _onContinue,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int index, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: active ? 40 : 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: active ? LumashaColors.primary : LumashaColors.primaryLight.withOpacity(0.4),
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
  }
}

class Particle {
  final double startX, startY, size, speedX, speedY;
  final Color color;
  Particle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color.withOpacity(0.25);
      double x = (p.startX + time * p.speedX) % 1.0;
      double y = (p.startY + time * p.speedY) % 1.0;
      if (x < 0) x += 1.0;
      if (y < 0) y += 1.0;
      final offset = Offset(x * size.width, y * size.height);
      canvas.drawCircle(offset, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}