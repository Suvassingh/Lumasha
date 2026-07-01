import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onboardingStepProvider = StateProvider<int>((ref) => 1);

class OnboardingNotifier extends StateNotifier<Map<String, dynamic>> {
  OnboardingNotifier() : super({});

  void setField(String key, dynamic value) {
    state = {...state, key: value};
  }

  Future<bool> isUsernameTaken(String username) async {
    final supabase = Supabase.instance.client;
    final result = await supabase
        .rpc('is_username_taken', params: {'p_username': username});
    return result as bool;
  }

  Future<bool> saveProfile() async {
    final supabase = Supabase.instance.client;

    AuthResponse authResponse;
    final existingUser = supabase.auth.currentUser;
    if (existingUser == null) {
      authResponse = await supabase.auth.signInAnonymously();
    } else {
      authResponse = AuthResponse(
          user: existingUser, session: supabase.auth.currentSession!);
    }

    final userId = authResponse.user!.id;
    final rawUsername = (state['username'] ?? '').toString().trim();
    final displayName = (state['name'] ?? rawUsername).toString().trim();
    final uniqueUsername = await supabase
        .rpc('generate_unique_username', params: {'base': rawUsername});

    final userData = {
      'id': userId,
      'username': uniqueUsername,
      'name': displayName,
      'age_group': state['ageGroup'] ?? '',
      'country': state['country'] ?? '',
      'ethnicity': state['ethnicity'] ?? '',
      'avatar_emoji': '🧒',
      'daily_goal_min': state['dailyGoalMin'] ?? 10,
      'is_first_launch': false,
      'role': 'learner',
    };

    try {
      await supabase.from('users').upsert(userData);
      return true;
    } catch (e) {
       return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, Map<String, dynamic>>(
  (ref) => OnboardingNotifier(),
);
