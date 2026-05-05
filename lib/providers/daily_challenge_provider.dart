import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/models/daily_challenge.dart';
import 'package:chromapulse/core/services/daily_challenge_service.dart';
import 'package:chromapulse/providers/player_provider.dart';

final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService();
});

/// Today's challenge derived from the player's `lastDailyDate`.
/// Auto-recomputes whenever the player record changes (e.g. after completion).
final todayChallengeProvider = Provider<DailyChallenge>((ref) {
  final svc = ref.watch(dailyChallengeServiceProvider);
  final player = ref.watch(playerProvider);
  return svc.todayFor(player);
});
