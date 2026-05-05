import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/services/haptic_service.dart';
import 'package:chromapulse/providers/player_provider.dart';

final hapticServiceProvider = Provider<HapticService>((ref) {
  final svc = HapticService();
  svc.setEnabled(ref.read(playerProvider).hapticsEnabled);
  ref.listen(
    playerProvider.select((p) => p.hapticsEnabled),
    (_, next) => svc.setEnabled(next),
  );
  return svc;
});
