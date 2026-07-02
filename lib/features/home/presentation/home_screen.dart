import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumasha/widgets/home_bottom_nav.dart';

import '../../../../core/theme/app_colors.dart'; import '../provider/home_provider.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: LumashaColors.background,
      body: RefreshIndicator(
        color: LumashaColors.primary,
        onRefresh: () async {
          ref.invalidate(homeUserProfileProvider);
          ref.invalidate(homeMenuItemsProvider);
          ref.invalidate(homeSrsReviewProvider);
          ref.invalidate(homeWeekStreakProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: const _HeroWithCard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}

class _HeroWithCard extends StatelessWidget {
  const _HeroWithCard();

  @override
  Widget build(BuildContext context) {
    final headerHeight = 100 + MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(top: 0, left: 0, right: 0, child: _GradientHeader()),
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight - 10,
          bottom: 0,
          child: const _MainCard(),
        ),
        const Positioned.fill(child: _HeroParticles()),
      ],
    );
  }
}

class _AnimatedLumashaTitle extends StatefulWidget {
  const _AnimatedLumashaTitle();

  @override
  State<_AnimatedLumashaTitle> createState() => _AnimatedLumashaTitleState();
}

class _AnimatedLumashaTitleState extends State<_AnimatedLumashaTitle>
    with SingleTickerProviderStateMixin {
  static const List<String> _letters = ['लु', 'मा', 'शा'];
  static const Duration _bounceDuration = Duration(milliseconds: 500);
  late final Duration _cycleDuration = _bounceDuration * _letters.length;
  late final AnimationController _controller;

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
    _controller = AnimationController(
      vsync: this,
      duration: _cycleDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColorForLetter(String letter) {
    switch (letter) {
      case 'लु':
        return const Color(0xFFF44336);
      case 'मा':
        return const Color(0xFF43F436);
      case 'शा':
        return const Color(0xfff79313);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        final int letterIndex = (value * _letters.length).floor();
        final double phase = (value * _letters.length) - letterIndex;
        final bool isActive = letterIndex < _letters.length;
        final double translateY = isActive ? _bounceValue(phase) : 0.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_letters.length, (index) {
            final bool isBouncing = (index == letterIndex);
            return Transform.translate(
              offset: Offset(0, isBouncing ? translateY : 0),
              child: Text(
                _letters[index],
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _getColorForLetter(_letters[index]),
                  letterSpacing: 2,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GradientHeader extends ConsumerWidget {
  const _GradientHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(homeUserProfileProvider);
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      height: 100 + topInset,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0077A3), Color(0xFF0096C7), Color(0xFF48CAE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _AnimatedLumashaTitle(),
                  profileAsync.when(
                    data: (p) => _HeartsRow(
                      hearts: p?.hearts ?? 5,
                      max: p?.maxHearts ?? 5,
                    ),
                    loading: () => const _HeartsRow(hearts: 5, max: 5),
                    error: (_, __) => const _HeartsRow(hearts: 5, max: 5),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Learn · Explore · Level Up',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartsRow extends StatelessWidget {
  final int hearts;
  final int max;
  const _HeartsRow({required this.hearts, required this.max});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(max, (i) {
        final filled = i < hearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Text(
            filled ? '❤️' : '🖤',
            style: TextStyle(
              fontSize: 16,
              color: filled ? null : Colors.white24,
            ),
          ),
        );
      }),
    );
  }
}

class _MainCard extends StatelessWidget {
  const _MainCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: LumashaColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 8),
            _AvatarXpBlock(),
            SizedBox(height: 8),
            _DailyGoalRow(),
            SizedBox(height: 16),
            _ReviewBanner(),
            SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: _MenuGrid(),
            ),
            _StreakRow(),
          ],
        ),
      ),
    );
  }
}

class _AvatarXpBlock extends ConsumerWidget {
  const _AvatarXpBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(homeUserProfileProvider);

    return profileAsync.when(
      loading: () => const _AvatarXpSkeleton(),
      error: (_, __) => const _AvatarXpSkeleton(),
      data: (p) {
        if (p == null) return const _AvatarXpSkeleton();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LumashaColors.surface,
                    border: Border.all(
                        color: LumashaColors.primaryLight, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      p.avatarEmoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: LumashaColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      'Lv.${p.level}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              p.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: LumashaColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${p.xp} XP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: LumashaColors.textMed,
                  ),
                ),
                const Spacer(),
                Text(
                  '${p.xpNextLevel} XP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: LumashaColors.textMed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _XpBar(progress: p.xpProgress),
          ],
        );
      },
    );
  }
}

class _AvatarXpSkeleton extends StatelessWidget {
  const _AvatarXpSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 32, backgroundColor: LumashaColors.surface),
        SizedBox(height: 10),
        SizedBox(
          width: 100,
          height: 16,
          child: ColoredBox(color: LumashaColors.surface),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 10,
                child: ColoredBox(color: LumashaColors.surface),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _XpBar extends StatelessWidget {
  final double progress;
  const _XpBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Container(
            height: 10,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              color: LumashaColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            height: 10,
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0096C7), Color(0xFF48CAE4)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      );
    });
  }
}

class _DailyGoalRow extends ConsumerWidget {
  const _DailyGoalRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(homeUserProfileProvider);

    return profileAsync.when(
      loading: () => const _GoalRowSkeleton(),
      error: (_, __) => const _GoalRowSkeleton(),
      data: (p) {
        if (p == null) return const _GoalRowSkeleton();
        final progress = p.dailyGoalProgress;
        final goalMin = p.dailyGoalMin;
        final doneMin = p.dailyDoneMin;
        final leftMin = p.dailyMinLeft;

        final leftMinutes = leftMin;
        final leftSeconds = 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: LumashaColors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _GoalRing(progress: progress),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Goal — $goalMin min',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: LumashaColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$doneMin min done · $leftMin min left',
                      style: const TextStyle(
                        fontSize: 11,
                        color: LumashaColors.textMed,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    '${leftMinutes.toString().padLeft(2, '0')}:${leftSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: LumashaColors.accent,
                    ),
                  ),
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalRowSkeleton extends StatelessWidget {
  const _GoalRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: LumashaColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final double progress;
  const _GoalRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1,
            strokeWidth: 5,
            color: LumashaColors.surface,
          ),
          AnimatedCircularProgress(progress: progress),
          Center(
            child: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: LumashaColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCircularProgress extends StatelessWidget {
  final double progress;
  const AnimatedCircularProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (_, v, __) => CircularProgressIndicator(
        value: v,
        strokeWidth: 5,
        strokeCap: StrokeCap.round,
        color: LumashaColors.accent,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class _ReviewBannerSkeleton extends StatelessWidget {
  const _ReviewBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔁', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewBanner extends ConsumerWidget {
  const _ReviewBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(homeSrsReviewProvider);

    return reviewAsync.when(
      loading: () => const _ReviewBannerSkeleton(),
      error: (_, __) => const _ReviewBannerSkeleton(),
      data: (review) {
        return GestureDetector(
          onTap: () => context.push('/quiz'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF3730A3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🔁', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.count > 0
                            ? 'Review due today'
                            : 'Start your review session',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE0E7FF),
                        ),
                      ),
                      Text(
                        review.count > 0
                            ? 'Spaced repetition • SRS'
                            : 'Practice what you\'ve learned',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFFA5B4FC),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: review.count > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    review.count > 0 ? '${review.count}' : '✨',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuGrid extends ConsumerWidget {
  const _MenuGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(homeMenuItemsProvider);

    return menuAsync.when(
      loading: () => _buildGrid(context, defaultMenuItems()),
      error: (_, __) => _buildGrid(context, defaultMenuItems()),
      data: (items) => _buildGrid(context, items),
    );
  }

  Widget _buildGrid(BuildContext context, List<MenuItem> items) {
    final pairs = <List<MenuItem>>[];
    for (var i = 0; i < items.length; i += 2) {
      pairs.add(items.sublist(i, math.min(i + 2, items.length)));
    }

    return Column(
      children: pairs.map((pair) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(child: _MenuCard(item: pair[0])),
              if (pair.length > 1) ...[
                const SizedBox(width: 10),
                Expanded(child: _MenuCard(item: pair[1])),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MenuCard extends ConsumerStatefulWidget {
  final MenuItem item;
  const _MenuCard({required this.item});

  @override
  ConsumerState<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends ConsumerState<_MenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.forward();
  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  Future<void> _handleTap() async {
    final item = widget.item;
    final userId = ref.read(homeUserProfileProvider).value?.id;

    if (userId != null) {
      await markMenuItemAsSeen(userId, item.id);
      ref.invalidate(homeMenuItemsProvider);
    }

    if (mounted) {
      context.push(item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final progressColor =
        item.isNew ? const Color(0xFFF79313) : LumashaColors.accent;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () => _handleTap(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LumashaColors.surface, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: LumashaColors.primary.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.labelNepali,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(height: 6),
                    _MiniProgressBar(
                      progress: item.progress,
                      color: progressColor,
                    ),
                  ],
                ),
              ),
              if (item.isNew)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF79313),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  const _MiniProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, c) {
      return Stack(
        children: [
          Container(
            height: 5,
            width: c.maxWidth,
            decoration: BoxDecoration(
              color: LumashaColors.surface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOut,
            builder: (_, v, __) => Container(
              height: 5,
              width: c.maxWidth * v,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _StreakRow extends ConsumerWidget {
  const _StreakRow();

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(homeUserProfileProvider);
    final streakAsync = ref.watch(homeWeekStreakProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9E6), Color(0xFFFFF0CC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        children: [
          const _FlameBounce(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (p) => Text(
                    '${p?.streakDays ?? 0} Days',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  loading: () => const Text('— Days',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E))),
                  error: (_, __) => const Text('0 Days',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E))),
                ),
                const Text(
                  'Current streak — keep going!',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB45309)),
                ),
              ],
            ),
          ),
          streakAsync.when(
            data: (ws) => Row(
              children: List.generate(7, (i) {
                final done = i < ws.days.length ? ws.days[i] : false;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Text(
                        _dayLabels[i],
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? const Color(0xFFD97706)
                              : const Color(0xFFBFBFBF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFFDE8CC),
                          border: Border.all(
                            color: done
                                ? const Color(0xFFD97706)
                                : const Color(0xFFFCD34D),
                            width: 1,
                          ),
                          boxShadow: done
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B)
                                        .withOpacity(0.4),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FlameBounce extends StatefulWidget {
  const _FlameBounce();

  @override
  State<_FlameBounce> createState() => _FlameBounceState();
}

class _FlameBounceState extends State<_FlameBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _rotate = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotate,
      builder: (_, __) => Transform.rotate(
        angle: _rotate.value,
        child: const Text('🔥', style: TextStyle(fontSize: 42)),
      ),
    );
  }
}

class _HeroParticles extends StatefulWidget {
  const _HeroParticles();

  @override
  State<_HeroParticles> createState() => _HeroParticlesState();
}

class _HeroParticlesState extends State<_HeroParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _particles = List.generate(14, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble() * 0.8,
        size: rng.nextDouble() * 5 + 2,
        speedX: rng.nextDouble() * 0.3 - 0.15,
        speedY: rng.nextDouble() * 0.3 - 0.15,
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _ParticlePainter(_particles, _ctrl.value),
      ),
    );
  }
}

class _Particle {
  final double x, y, size, speedX, speedY;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.18);
    for (final p in particles) {
      final dx = ((p.x + t * p.speedX) % 1.0) * size.width;
      final dy = ((p.y + t * p.speedY) % 1.0) * size.height;
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => true;
}
