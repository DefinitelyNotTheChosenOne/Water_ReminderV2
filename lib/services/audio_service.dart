import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around audioplayers for playing in-app notification sounds.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Play a sound from the Flutter asset bundle.
  Future<void> playSound(String assetPath) async {
    try {
      // Ensure the player is ready by stopping any current sound
      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }
      
      final source = AssetSource(assetPath.replaceFirst('assets/', ''));
      await _player.play(source);
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void dispose() {
    _player.dispose();
  }
}

/// The available built-in notification sounds.
class AppSounds {
  static const List<SoundOption> all = [
    SoundOption(
      asset: 'assets/sounds/drop.wav',
      label: 'Water Drop',
      icon: '💧',
    ),
    SoundOption(
      asset: 'assets/sounds/chime.wav',
      label: 'Gentle Chime',
      icon: '🔔',
    ),
    SoundOption(
      asset: 'assets/sounds/bubbles.wav',
      label: 'Bubbles',
      icon: '🫧',
    ),
    SoundOption(
      asset: 'assets/sounds/ding.wav',
      label: 'Bright Ding',
      icon: '✨',
    ),
  ];
}

class SoundOption {
  final String asset;
  final String label;
  final String icon;

  const SoundOption({
    required this.asset,
    required this.label,
    required this.icon,
  });
}
