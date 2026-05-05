import 'package:chromapulse/core/models/daily_challenge.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/player_stats.dart';

/// Deterministic per-day challenge generator. The same (UTC) calendar date
/// always maps to the same mode + seed, so every player worldwide gets the
/// same daily layout — important for "today's challenge" social discussions.
class DailyChallengeService {
  /// Returns the challenge for [now] (UTC). The day-of-week determines the
  /// mode; the seed is YYYYMMDD as an int.
  DailyChallenge challengeFor(DateTime now, PlayerStats player) {
    final utc = now.toUtc();
    final dateKey = _dateKey(utc);
    final seed = _seed(utc);
    final mode = _modeForWeekday(utc.weekday, seed);
    final completed = player.lastDailyDate == dateKey;
    return DailyChallenge(
      dateKey: dateKey,
      mode: mode,
      seed: seed,
      completed: completed,
    );
  }

  /// Today (in UTC).
  DailyChallenge todayFor(PlayerStats player) =>
      challengeFor(DateTime.now(), player);

  static String _dateKey(DateTime utc) {
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static int _seed(DateTime utc) =>
      utc.year * 10000 + utc.month * 100 + utc.day;

  static GameMode _modeForWeekday(int weekday, int seed) {
    // DateTime.weekday: Mon=1, Sun=7.
    switch (weekday) {
      case DateTime.monday:
        return GameMode.shadeHunter;
      case DateTime.tuesday:
        return GameMode.oddChroma;
      case DateTime.wednesday:
        return GameMode.chromaRecall;
      case DateTime.thursday:
        return GameMode.colorAlchemist;
      case DateTime.friday:
        // "Daily Mix" — pick deterministically from the four core modes.
        const pool = [
          GameMode.shadeHunter,
          GameMode.oddChroma,
          GameMode.chromaRecall,
          GameMode.colorAlchemist,
        ];
        return pool[seed % pool.length];
      case DateTime.saturday:
        // "Hardcore Saturday" — ramp up the hardest perception mode.
        return GameMode.chromaRecall;
      case DateTime.sunday:
      default:
        // Replay Sunday — let it be Shade Hunter; keeps mode public.
        return GameMode.shadeHunter;
    }
  }
}
