import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/providers/player_provider.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioService();
  final enabled = ref.read(playerProvider).soundEnabled;
  svc.setEnabled(enabled);
  ref.listen(
    playerProvider.select((p) => p.soundEnabled),
    (_, next) => svc.setEnabled(next),
  );
  ref.onDispose(svc.dispose);
  return svc;
});
