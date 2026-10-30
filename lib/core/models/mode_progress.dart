import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_record.dart';
import 'package:chromapulse/core/models/player_stats.dart';

enum TrendDirection { up, down, steady }

/// How the player's latest scores compare with the ones before them.
class ScoreTrend {
  final TrendDirection direction;

  /// Absolute percentage change of the recent average vs the previous one.
  final int pct;

  /// Number of games in each of the two compared windows.
  final int window;

  const ScoreTrend(this.direction, this.pct, this.window);
}

/// Read-only view of one mode's progress, derived from [PlayerStats].
///
/// Scores (chart, average, trend) come from `recentScoresByMode`, which
/// existing installs already have, so the Progress screen is useful the moment
/// the update lands. Dated rows and accuracy come from `history`, which fills
/// in as games are played on 1.2.0+.
class ModeProgress {
  /// Newest games that feed the "recent" average and accuracy.
  static const int recentWindow = 10;

  /// Smallest number of games before a trend is shown.
  static const int minGamesForTrend = 4;

  final GameMode mode;

  /// Scores, newest first (as stored).
  final List<int> scores;

  /// Dated records for this mode, newest first.
  final List<GameRecord> records;

  final int best;

  const ModeProgress({
    required this.mode,
    required this.scores,
    required this.records,
    required this.best,
  });

  factory ModeProgress.of(PlayerStats p, GameMode mode) => ModeProgress(
    mode: mode,
    scores: p.recentScoresByMode[mode.id] ?? const [],
    records: p.history.where((r) => r.modeId == mode.id).toList(),
    best: p.bestFor(mode.id),
  );

  bool get hasGames => scores.isNotEmpty || records.isNotEmpty;

  /// Scores oldest to newest, ready to plot left to right.
  List<int> get chartScores => scores.reversed.toList();

  /// Average of the newest [recentWindow] scores, or null with no games.
  double? get recentAverage {
    if (scores.isEmpty) return null;
    final n = scores.length < recentWindow ? scores.length : recentWindow;
    return scores.take(n).reduce((a, b) => a + b) / n;
  }

  /// Average accuracy (correct answers / rounds) over the newest
  /// [recentWindow] dated games, or null until one has been recorded.
  int? get recentAccuracyPct {
    if (records.isEmpty) return null;
    final take = records.take(recentWindow).toList();
    var correct = 0;
    var rounds = 0;
    for (final r in take) {
      correct += r.correct;
      rounds += r.rounds;
    }
    if (rounds <= 0) return null;
    return ((correct / rounds) * 100).round();
  }

  /// Compares the newest games with the same number of games before them
  /// (up to 5 each). Null until there are [minGamesForTrend] games.
  ScoreTrend? get trend {
    final n = scores.length;
    if (n < minGamesForTrend) return null;
    final k = (n ~/ 2) < 5 ? (n ~/ 2) : 5;
    double avg(Iterable<int> xs) => xs.reduce((a, b) => a + b) / k;
    final recent = avg(scores.take(k));
    final previous = avg(scores.skip(k).take(k));
    if (previous <= 0) return null;
    final change = (recent - previous) / previous * 100;
    final pct = change.abs().round();
    final dir = pct < 3
        ? TrendDirection.steady
        : (change > 0 ? TrendDirection.up : TrendDirection.down);
    return ScoreTrend(dir, pct, k);
  }

  /// Modes the player has at least one game in, in menu order.
  static List<GameMode> playedModes(PlayerStats p) => [
    for (final m in GameMode.values)
      if (ModeProgress.of(p, m).hasGames) m,
  ];

  /// Mode to show first: the one played most recently, else the one with the
  /// longest score history. Null when nothing has been played.
  static GameMode? defaultMode(PlayerStats p) {
    if (p.history.isNotEmpty) {
      final m = GameMode.byId(p.history.first.modeId);
      if (m != null) return m;
    }
    GameMode? best;
    var bestLen = 0;
    for (final m in GameMode.values) {
      final len = p.recentScoresByMode[m.id]?.length ?? 0;
      if (len > bestLen) {
        best = m;
        bestLen = len;
      }
    }
    return best;
  }
}

/// "Today", "Yesterday" or "Oct 28" for [when], relative to [now] in local
/// calendar days.
String dayLabel(DateTime when, DateTime now) {
  // UTC midnights so a 23/25-hour DST day still counts as one day.
  final a = DateTime.utc(when.year, when.month, when.day);
  final b = DateTime.utc(now.year, now.month, now.day);
  final diff = b.difference(a).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final label = '${months[when.month - 1]} ${when.day}';
  return when.year == now.year ? label : '$label, ${when.year}';
}
