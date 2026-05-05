import 'package:flutter_test/flutter_test.dart';
import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/achievement_service.dart';

void main() {
  final svc = AchievementService();

  test('first game unlocks First Pulse', () {
    final player = const PlayerStats(totalGames: 1);
    const game = GameState(
      mode: GameMode.shadeHunter,
      totalRounds: 10,
      correct: 5,
      score: 200,
    );
    final ids = svc.evaluate(player, const AchievementTrigger(gameJustEnded: game));
    expect(ids, contains(AchievementId.firstPulse));
  });

  test('Perfectionist requires correct == totalRounds', () {
    const game = GameState(
      mode: GameMode.shadeHunter,
      totalRounds: 10,
      correct: 10,
      score: 1000,
    );
    final ids = svc.evaluate(
      const PlayerStats(totalGames: 1),
      const AchievementTrigger(gameJustEnded: game),
    );
    expect(ids, contains(AchievementId.perfectionist));
  });

  test('Curious Eye requires history in all 4 core modes', () {
    final all4 = const PlayerStats(
      totalGames: 4,
      recentScoresByMode: {
        'shade': [10],
        'odd': [10],
        'memory': [10],
        'blend': [10],
      },
    );
    final ids = svc.evaluate(all4, const AchievementTrigger());
    expect(ids, contains(AchievementId.curiousEye));

    final partial = const PlayerStats(
      totalGames: 2,
      recentScoresByMode: {
        'shade': [10],
        'odd': [10],
      },
    );
    final partialIds = svc.evaluate(partial, const AchievementTrigger());
    expect(partialIds, isNot(contains(AchievementId.curiousEye)));
  });

  test('Combo King fires only when maxCombo >= 10', () {
    const game = GameState(maxCombo: 10, totalRounds: 10, correct: 9);
    final ids = svc.evaluate(
      const PlayerStats(totalGames: 1),
      const AchievementTrigger(gameJustEnded: game),
    );
    expect(ids, contains(AchievementId.comboKing));
  });

  test('Week Streak unlocks at currentStreak >= 7', () {
    final p = const PlayerStats(currentStreak: 7);
    final ids = svc.evaluate(p, const AchievementTrigger());
    expect(ids, contains(AchievementId.weekStreak));
  });

  test('does not re-emit already-unlocked achievements', () {
    const game = GameState(
      mode: GameMode.shadeHunter,
      totalRounds: 10,
      correct: 10,
    );
    final p = const PlayerStats(
      totalGames: 1,
      unlockedAchievements: {'first_pulse', 'perfectionist'},
    );
    final ids = svc.evaluate(p, const AchievementTrigger(gameJustEnded: game));
    expect(ids, isNot(contains(AchievementId.firstPulse)));
    expect(ids, isNot(contains(AchievementId.perfectionist)));
  });

  test('Palette Pro requires palette best >= 600', () {
    final player = const PlayerStats(bestByMode: {'palette': 600});
    final ids = svc.evaluate(player, const AchievementTrigger());
    expect(ids, contains(AchievementId.palettePro));
  });

  test('VIP Vision unlocks when player.vip is true', () {
    final player = const PlayerStats(vip: true);
    final ids = svc.evaluate(player, const AchievementTrigger(vipJustActivated: true));
    expect(ids, contains(AchievementId.vipVision));
  });
}
