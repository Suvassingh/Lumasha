import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeUserProfile {
  final String id;
  final String name;
  final String username;
  final String avatarEmoji;
  final int level;
  final int xp;
  final int xpNextLevel;
  final int hearts;
  final int maxHearts;
  final int streakDays;
  final int dailyGoalMin;
  final int dailyDoneMin;
  final int gemsCount;
  final int dailyGoalPct;

  const HomeUserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.avatarEmoji,
    required this.level,
    required this.xp,
    required this.xpNextLevel,
    required this.hearts,
    required this.maxHearts,
    required this.streakDays,
    required this.dailyGoalMin,
    required this.dailyDoneMin,
    required this.gemsCount,
    required this.dailyGoalPct,
  });

  double get dailyGoalProgress => (dailyGoalPct / 100.0).clamp(0.0, 1.0);
  double get xpProgress =>
      xpNextLevel == 0 ? 0 : (xp / xpNextLevel).clamp(0.0, 1.0);
  int get dailyMinLeft => (dailyGoalMin - dailyDoneMin).clamp(0, dailyGoalMin);

  factory HomeUserProfile.fromRows({
    required Map<String, dynamic> user,
    required Map<String, dynamic>? gami,
  }) {
    return HomeUserProfile(
      id: user['id'] ?? '',
      name: user['name'] ?? user['username'] ?? 'Learner',
      username: user['username'] ?? '',
      avatarEmoji: user['avatar_emoji'] ?? '🧒',
      dailyGoalMin: user['daily_goal_min'] ?? 10,
      level: gami?['level'] ?? 1,
      xp: gami?['xp'] ?? 0,
      xpNextLevel: gami?['xp_next_level'] ?? 100,
      hearts: gami?['hearts'] ?? 5,
      maxHearts: gami?['max_hearts'] ?? 5,
      streakDays: gami?['streak_days'] ?? 0,
      dailyDoneMin: gami?['daily_done_min'] ?? 0,
      gemsCount: gami?['gems'] ?? 0,
      dailyGoalPct: gami?['daily_goal_pct'] ?? 0,
    );
  }
}

class MenuItem {
  final String id;
  final String label;
  final String labelNepali;
  final String emoji;
  final double progress;
  final bool isNew;
  final String route;

  const MenuItem({
    required this.id,
    required this.label,
    required this.labelNepali,
    required this.emoji,
    required this.progress,
    required this.isNew,
    required this.route,
  });

  factory MenuItem.fromJson(Map<String, dynamic> j,
      {bool isNewOverride = false,double progressOverride = 0.0}) {
    return MenuItem(
      id: j['id'] ?? '',
      label: j['label'] ?? '',
      labelNepali: j['label_nepali'] ?? '',
      emoji: j['emoji'] ?? '📚',
      progress: progressOverride,
      isNew: isNewOverride,
      route: j['route'] ?? '/',
    );
  }
}

class SrsReview {
  final int count;
  const SrsReview({required this.count});
}

class WeekStreak {
  final List<bool> days; // Mon–Sun, 7 items
  const WeekStreak(this.days);

  factory WeekStreak.fromJson(List<dynamic> j) =>
      WeekStreak(j.map((e) => e == true).toList());
}

final _db = Supabase.instance.client;

final homeUserProfileProvider = FutureProvider<HomeUserProfile?>((ref) async {
  final user = _db.auth.currentUser;
  if (user == null) return null;

  final results = await Future.wait([
    _db
        .from('users')
        .select('id, name, username, avatar_emoji, daily_goal_min')
        .eq('id', user.id)
        .maybeSingle(),
    _db
        .from('user_gamification')
        .select('level, xp, xp_next_level, hearts, max_hearts, streak_days, '
            'daily_done_min, daily_goal_pct, gems')
        .eq('user_id', user.id)
        .maybeSingle(),
  ]);

  final userRow = results[0] as Map<String, dynamic>?;
  if (userRow == null) return null;

  return HomeUserProfile.fromRows(
    user: userRow,
    gami: results[1] as Map<String, dynamic>?,
  );
});

final homeMenuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  final user = _db.auth.currentUser;
  if (user == null) return defaultMenuItems();

   final rows = await _db
      .from('home_menu_items')
      .select('id, label, label_nepali, emoji, route')
      .order('sort_order');

   final statusRows = await _db
      .from('user_menu_items')
      .select('item_id, is_new, progress')
      .eq('user_id', user.id);

   final Map<String, Map<String, dynamic>> userData = {};
  for (final row in statusRows) {
    userData[row['item_id']] = {
      'is_new': row['is_new'] as bool,
      'progress': (row['progress'] ?? 0) as int,
    };
  }

   final List<MenuItem> items = [];
  for (final row in rows) {
    final id = row['id'] as String;
    final data = userData[id] ?? {'is_new': true, 'progress': 0};
    items.add(MenuItem.fromJson(
      row,
      isNewOverride: data['is_new'] as bool,
      progressOverride: (data['progress'] as num).toDouble() / 100.0,
    ));
  }

   const order = ['path', 'culture', 'writing', 'songs'];
  items.sort((a, b) {
    final indexA = order.indexOf(a.id);
    final indexB = order.indexOf(b.id);
    return (indexA == -1 ? order.length : indexA)
        .compareTo(indexB == -1 ? order.length : indexB);
  });

  return items;
});

 Future<void> updateMenuItemProgress(String userId, String itemId, int newProgress) async {
  await _db
      .from('user_menu_items')
      .update({'progress': newProgress, 'updated_at': DateTime.now().toIso8601String()})
      .eq('user_id', userId)
      .eq('item_id', itemId);
}
Future<void> markMenuItemAsSeen(String userId, String itemId) async {
  await _db
      .from('user_menu_items')
      .update({'is_new': false, 'updated_at': DateTime.now().toIso8601String()})
      .eq('user_id', userId)
      .eq('item_id', itemId);
}
final homeSrsReviewProvider = FutureProvider<SrsReview>((ref) async {
  final user = _db.auth.currentUser;
  if (user == null) return const SrsReview(count: 0);

  try {
    final row = await _db
        .from('user_srs_due')
        .select('review_count')
        .eq('user_id', user.id)
        .maybeSingle();
    return SrsReview(count: (row?['review_count'] ?? 0) as int);
  } catch (_) {
    return const SrsReview(count: 0);
  }
});

final homeWeekStreakProvider = FutureProvider<WeekStreak>((ref) async {
  final user = _db.auth.currentUser;
  if (user == null) return _emptyStreak();

  try {
    final row = await _db
        .from('user_week_streak')
        .select('days')
        .eq('user_id', user.id)
        .maybeSingle();
    if (row == null || row['days'] == null) return _emptyStreak();
    return WeekStreak.fromJson(row['days'] as List);
  } catch (_) {
    return _emptyStreak();
  }
});

WeekStreak _emptyStreak() =>
    const WeekStreak([false, false, false, false, false, false, false]);

List<MenuItem> defaultMenuItems() => const [
      MenuItem(
        id: 'path',
        label: 'Skill Path',
        labelNepali: 'पाठ्यक्रम',
        emoji: '🗺️',
        progress: 0.44,
        isNew: false,
        route: '/path',
      ),
      MenuItem(
        id: 'culture',
        label: 'Culture',
        labelNepali: 'संस्कृति',
        emoji: '🎎',
        progress: 0.20,
        isNew: false,
        route: '/culture',
      ),
      MenuItem(
        id: 'writing',
        label: 'Writing',
        labelNepali: 'लेखन',
        emoji: '✍️',
        progress: 0.30,
        isNew: false,
        route: '/writing',
      ),
      MenuItem(
        id: 'songs',
        label: 'Songs',
        labelNepali: 'गीत & लोरी',
        emoji: '🎵',
        progress: 0.10,
        isNew: true,
        route: '/songs',
      ),
    ];
