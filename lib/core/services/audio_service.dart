import 'package:audioplayers/audioplayers.dart';

enum SoundEffect {
  correct('correct.wav'),
  wrong('wrong.wav'),
  combo('combo.wav'),
  countdownTick('countdown_tick.wav'),
  gameOver('game_over.wav'),
  buttonTap('button_tap.wav');

  final String filename;
  const SoundEffect(this.filename);
}

class AudioService {
  final AudioPlayer _player = AudioPlayer(playerId: 'chromapulse_sfx');
  bool _enabled = true;

  bool get enabled => _enabled;

  void setEnabled(bool v) => _enabled = v;

  Future<void> play(SoundEffect sfx) async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${sfx.filename}'));
    } catch (_) {
      // Swallow — audio is non-critical.
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
