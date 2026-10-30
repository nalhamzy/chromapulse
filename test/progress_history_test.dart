import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_record.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/models/mode_progress.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/storage_service.dart';
import 'package:chromapulse/providers/player_provider.dart';

GameRecord rec({
  String mode = 'shade',
  int score = 500,
  int correct = 7,
  int rounds = 10,
  int ms = 2500,
  int at = 1000,
  bool daily = false,
}) => GameRecord(
  modeId: mode,
  score: score,
  correct: correct,
  rounds: rounds,
  avgTimeMs: ms,
  playedAtMs: at,
  daily: daily,
);

PlayerStats statsWithScores(String mode, List<int> newestFirst) => PlayerStats(
  bestByMode: {mode: newestFirst.reduce((a, b) => a > b ? a : b)},
  recentScoresByMode: {mode: newestFirst},
);

void main() {
  group('GameRecord', () {
    test('JSON round-trips', () {
      final r = rec(score: 910, daily: true, at: 1760000000000);
      expect(GameRecord.tryFromJson(r.toJson()), r);
    });

    test('accuracy and average time are derived', () {
      final r = rec(correct: 7, rounds: 8, ms: 1840);
      expect(r.accuracyPct, 88); // 87.5 rounds up
      expect(r.avgTimeSec, closeTo(1.84, 1e-9));
      expect(rec(rounds: 0).accuracyPct, 0);
    });

    test('rejects entries without a mode or a timestamp', () {
      expect(GameRecord.tryFromJson(null), isNull);
      expect(GameRecord.tryFromJson('x'), isNull);
      expect(GameRecord.tryFromJson({'m': 'shade'}), isNull);
      expect(GameRecord.tryFromJson({'at': 5}), isNull);
      expect(GameRecord.tryFromJson({'m': '', 'at': 5}), isNull);
    });

    test('missing numeric fields fall back to zero', () {
      final r = GameRecord.tryFromJson({'m': 'odd', 'at': 42})!;
      expect(r.score, 0);
      expect(r.rounds, 0);
      expect(r.daily, false);
    });
  });

  group('PlayerStats.history', () {
    test('survives an encode/decode round-trip', () {
      final original = PlayerStats(
        history: [rec(at: 3), rec(at: 2), rec(at: 1)],
      );
      expect(PlayerStats.decode(original.encode()), original);
    });

    test('profiles saved before 1.2.0 decode with an empty history', () {
      const legacy =
          '{"totalGames":4,"bestByMode":{"shade":300},'
          '"recentScoresByMode":{"shade":[300,200]}}';
      final decoded = PlayerStats.decode(legacy);
      expect(decoded.totalGames, 4);
      expect(decoded.history, isEmpty);
      expect(decoded.recentScoresByMode['shade'], [300, 200]);
    });

    test('a malformed entry is skipped, not fatal to the whole profile', () {
      const raw =
          '{"totalGames":9,"history":['
          '{"m":"shade","s":100,"c":5,"r":10,"t":2000,"at":10,"d":false},'
          '"junk",{"m":"odd"},'
          '{"m":"odd","s":200,"c":6,"r":10,"t":1500,"at":20,"d":true}]}';
      final decoded = PlayerStats.decode(raw);
      expect(decoded.totalGames, 9);
      expect(decoded.history.map((r) => r.modeId), ['shade', 'odd']);
    });

    test('a non-list history value is ignored', () {
      expect(PlayerStats.decode('{"history":"oops"}').history, isEmpty);
    });
  });

  group('ModeProgress', () {
    test('chart runs oldest to newest', () {
      final p = ModeProgress.of(
        statsWithScores('shade', [30, 20, 10]),
        GameMode.shadeHunter,
      );
      expect(p.chartScores, [10, 20, 30]);
    });

    test('average covers only the latest 10 games', () {
      // newest 10 are all 100; the older 5 are 0.
      final scores = [...List.filled(10, 100), ...List.filled(5, 0)];
      final p = ModeProgress.of(
        statsWithScores('shade', scores),
        GameMode.shadeHunter,
      );
      expect(p.recentAverage, 100);
    });

    test('no games means no average, trend or accuracy', () {
      final p = ModeProgress.of(const PlayerStats(), GameMode.oddChroma);
      expect(p.hasGames, false);
      expect(p.recentAverage, isNull);
      expect(p.trend, isNull);
      expect(p.recentAccuracyPct, isNull);
    });

    test('trend needs at least 4 games', () {
      final p = ModeProgress.of(
        statsWithScores('shade', [300, 200, 100]),
        GameMode.shadeHunter,
      );
      expect(p.trend, isNull);
    });

    test('trend compares the newest games with the ones before', () {
      // newest-first: 200,200 vs 100,100 -> +100%
      final up = ModeProgress.of(
        statsWithScores('shade', [200, 200, 100, 100]),
        GameMode.shadeHunter,
      );
      expect(up.trend!.direction, TrendDirection.up);
      expect(up.trend!.pct, 100);
      expect(up.trend!.window, 2);

      // 50,50 vs 100,100 -> -50%
      final down = ModeProgress.of(
        statsWithScores('shade', [50, 50, 100, 100]),
        GameMode.shadeHunter,
      );
      expect(down.trend!.direction, TrendDirection.down);
      expect(down.trend!.pct, 50);
    });

    test('trend window caps at 5 games each side', () {
      final scores = [...List.filled(5, 110), ...List.filled(5, 100), 1, 1, 1];
      final t = ModeProgress.of(
        statsWithScores('shade', scores),
        GameMode.shadeHunter,
      ).trend!;
      expect(t.window, 5);
      expect(t.pct, 10);
      expect(t.direction, TrendDirection.up);
    });

    test('a change under 3% reads as steady', () {
      final p = ModeProgress.of(
        statsWithScores('shade', [101, 101, 100, 100]),
        GameMode.shadeHunter,
      );
      expect(p.trend!.direction, TrendDirection.steady);
    });

    test('a zero baseline gives no trend instead of dividing by zero', () {
      final p = ModeProgress.of(
        statsWithScores('shade', [50, 50, 0, 0]),
        GameMode.shadeHunter,
      );
      expect(p.trend, isNull);
    });

    test('accuracy pools correct answers over the latest 10 dated games', () {
      final stats = PlayerStats(
        history: [
          rec(correct: 10, rounds: 10),
          rec(correct: 5, rounds: 10),
          rec(mode: 'odd', correct: 0, rounds: 10), // other mode, ignored
        ],
      );
      expect(
        ModeProgress.of(stats, GameMode.shadeHunter).recentAccuracyPct,
        75,
      );
    });

    test('records are filtered to the mode and keep newest-first order', () {
      final stats = PlayerStats(
        history: [
          rec(mode: 'odd', at: 5),
          rec(mode: 'shade', at: 4),
          rec(mode: 'shade', at: 3),
        ],
      );
      final p = ModeProgress.of(stats, GameMode.shadeHunter);
      expect(p.records.map((r) => r.playedAtMs), [4, 3]);
    });

    test('playedModes lists only modes with games, in menu order', () {
      final stats = PlayerStats(
        recentScoresByMode: const {
          'blend': [10],
          'shade': [20],
        },
      );
      expect(ModeProgress.playedModes(stats), [
        GameMode.shadeHunter,
        GameMode.colorAlchemist,
      ]);
      expect(ModeProgress.playedModes(const PlayerStats()), isEmpty);
    });

    test('default mode is the most recently played, else the longest', () {
      final dated = PlayerStats(
        history: [rec(mode: 'blend')],
        recentScoresByMode: const {
          'shade': [1, 2, 3],
          'blend': [9],
        },
      );
      expect(ModeProgress.defaultMode(dated), GameMode.colorAlchemist);

      const legacy = PlayerStats(
        recentScoresByMode: {
          'shade': [1],
          'odd': [1, 2, 3],
        },
      );
      expect(ModeProgress.defaultMode(legacy), GameMode.oddChroma);
      expect(ModeProgress.defaultMode(const PlayerStats()), isNull);
    });
  });

  group('dayLabel', () {
    final now = DateTime(2026, 10, 30, 15, 0);

    test('same calendar day is Today, even late the night before', () {
      expect(dayLabel(DateTime(2026, 10, 30, 0, 5), now), 'Today');
      expect(dayLabel(DateTime(2026, 10, 29, 23, 59), now), 'Yesterday');
    });

    test('older dates show month and day, with the year if not this year', () {
      expect(dayLabel(DateTime(2026, 10, 28), now), 'Oct 28');
      expect(dayLabel(DateTime(2025, 12, 3), now), 'Dec 3, 2025');
    });

    test('month boundaries still count as yesterday', () {
      expect(
        dayLabel(DateTime(2026, 9, 30, 22), DateTime(2026, 10, 1, 8)),
        'Yesterday',
      );
    });
  });

  group('PlayerNotifier history', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
        ],
      );
      addTearDown(container.dispose);
    });

    GameState game({
      GameMode mode = GameMode.shadeHunter,
      int score = 800,
      int correct = 8,
      bool daily = false,
    }) => GameState(
      mode: mode,
      score: score,
      correct: correct,
      totalRounds: 10,
      roundTimesMs: const [2000, 3000],
      isDailyChallenge: daily,
    );

    test('recordGameEnd logs a dated entry', () {
      final when = DateTime.utc(2026, 10, 30, 12, 30);
      container
          .read(playerProvider.notifier)
          .recordGameEnd(game(daily: true), now: when);

      final h = container.read(playerProvider).history;
      expect(h, hasLength(1));
      expect(h.first.modeId, 'shade');
      expect(h.first.score, 800);
      expect(h.first.correct, 8);
      expect(h.first.rounds, 10);
      expect(h.first.avgTimeMs, 2500);
      expect(h.first.daily, true);
      expect(h.first.playedAtMs, when.millisecondsSinceEpoch);
    });

    test('newest game goes first', () {
      final n = container.read(playerProvider.notifier);
      n.recordGameEnd(game(score: 100), now: DateTime.utc(2026, 10, 1));
      n.recordGameEnd(game(score: 200), now: DateTime.utc(2026, 10, 2));
      expect(container.read(playerProvider).history.map((r) => r.score), [
        200,
        100,
      ]);
    });

    test('history is capped at ${PlayerStats.historyLimit} games', () {
      final n = container.read(playerProvider.notifier);
      for (var i = 0; i < PlayerStats.historyLimit + 5; i++) {
        n.recordGameEnd(game(score: i), now: DateTime.utc(2026, 10, 1));
      }
      final h = container.read(playerProvider).history;
      expect(h, hasLength(PlayerStats.historyLimit));
      expect(h.first.score, PlayerStats.historyLimit + 4); // newest kept
    });

    test('is persisted so it survives an app restart', () async {
      container
          .read(playerProvider.notifier)
          .recordGameEnd(game(), now: DateTime.utc(2026, 10, 30));
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final reloaded = StorageService(prefs).load();
      expect(reloaded.history, hasLength(1));
      expect(reloaded.history.first.score, 800);
    });

    test('doubling the score updates the latest entry and the chart', () {
      final n = container.read(playerProvider.notifier);
      n.recordGameEnd(game(score: 300), now: DateTime.utc(2026, 10, 1));
      n.recordGameEnd(game(score: 400), now: DateTime.utc(2026, 10, 2));
      n.recordBonusScore(modeId: 'shade', totalScore: 800, bonusPoints: 400);

      final s = container.read(playerProvider);
      expect(s.history.map((r) => r.score), [800, 300]);
      expect(s.recentScoresByMode['shade'], [800, 300]);
      expect(s.bestFor('shade'), 800);
    });

    test('doubling never touches another mode\'s latest entry', () {
      final n = container.read(playerProvider.notifier);
      n.recordGameEnd(game(score: 300), now: DateTime.utc(2026, 10, 1));
      n.recordBonusScore(modeId: 'odd', totalScore: 999, bonusPoints: 500);
      expect(container.read(playerProvider).history.first.score, 300);
    });

    test('resetStats clears the history', () {
      final n = container.read(playerProvider.notifier);
      n.recordGameEnd(game(), now: DateTime.utc(2026, 10, 1));
      n.resetStats();
      expect(container.read(playerProvider).history, isEmpty);
    });
  });
}
