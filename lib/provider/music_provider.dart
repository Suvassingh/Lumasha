import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';

final musicPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

final isMusicPlayingProvider = StateProvider<bool>((ref) => false);

final onboardingMusicControllerProvider = Provider((ref) {
  final player = ref.watch(musicPlayerProvider);
  return OnboardingMusicController(player, ref);
});

class OnboardingMusicController {
  final AudioPlayer _player;
  final Ref _ref;

  OnboardingMusicController(this._player, this._ref);

  Future<void> startMusic() async {
    try {
      await _player.setVolume(0.5);
      await _player.setAsset('assets/audio/songs/kidsmusic.mp3');
      await _player.setLoopMode(LoopMode.all);
      await _player.play();
      _ref.read(isMusicPlayingProvider.notifier).state = true;
    } catch (e) {
      print('Music error: $e');
    }
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _ref.read(isMusicPlayingProvider.notifier).state = false;
  }

  void dispose() {
    _player.dispose();
  }
}
