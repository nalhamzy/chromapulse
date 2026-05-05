import 'package:flutter_test/flutter_test.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/daily_challenge_service.dart';

void main() {
  final svc = DailyChallengeService();

  test('same date always yields same mode + seed', () {
    const player = PlayerStats();
    final a = svc.challengeFor(DateTime.utc(2026, 5, 4, 10), player);
    final b = svc.challengeFor(DateTime.utc(2026, 5, 4, 22, 30), player);
    expect(a.dateKey, b.dateKey);
    expect(a.mode, b.mode);
    expect(a.seed, b.seed);
  });

  test('seed encodes the date as YYYYMMDD', () {
    const player = PlayerStats();
    final c = svc.challengeFor(DateTime.utc(2026, 5, 4), player);
    expect(c.seed, 20260504);
    expect(c.dateKey, '2026-05-04');
  });

  test('weekday determines core mode rotation', () {
    const player = PlayerStats();
    // Mon 2026-05-04 → Shade Hunter
    expect(
      svc.challengeFor(DateTime.utc(2026, 5, 4), player).mode,
      GameMode.shadeHunter,
    );
    // Tue 2026-05-05 → Odd Chroma
    expect(
      svc.challengeFor(DateTime.utc(2026, 5, 5), player).mode,
      GameMode.oddChroma,
    );
    // Wed 2026-05-06 → Chroma Recall
    expect(
      svc.challengeFor(DateTime.utc(2026, 5, 6), player).mode,
      GameMode.chromaRecall,
    );
    // Thu 2026-05-07 → Color Alchemist
    expect(
      svc.challengeFor(DateTime.utc(2026, 5, 7), player).mode,
      GameMode.colorAlchemist,
    );
  });

  test('completed flag tracks lastDailyDate', () {
    final pendingPlayer = const PlayerStats();
    final donePlayer =
        const PlayerStats().copyWith(lastDailyDate: () => '2026-05-04');
    final pending =
        svc.challengeFor(DateTime.utc(2026, 5, 4), pendingPlayer);
    final done = svc.challengeFor(DateTime.utc(2026, 5, 4), donePlayer);
    expect(pending.completed, isFalse);
    expect(done.completed, isTrue);
  });
}
