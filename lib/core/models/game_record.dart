import 'package:equatable/equatable.dart';

/// One finished game, kept (newest first) in `PlayerStats.history` so the
/// Progress screen can show when it was played and how accurate it was.
///
/// Stored as plain JSON; every field has a safe default in [fromJson] so a
/// record written by a future version never breaks an older decode.
class GameRecord extends Equatable {
  final String modeId;
  final int score;
  final int correct;
  final int rounds;
  final int avgTimeMs;

  /// Epoch milliseconds (UTC) when the game finished.
  final int playedAtMs;
  final bool daily;

  const GameRecord({
    required this.modeId,
    required this.score,
    required this.correct,
    required this.rounds,
    required this.avgTimeMs,
    required this.playedAtMs,
    this.daily = false,
  });

  int get accuracyPct => rounds <= 0 ? 0 : ((correct / rounds) * 100).round();

  double get avgTimeSec => avgTimeMs / 1000;

  DateTime get playedAt =>
      DateTime.fromMillisecondsSinceEpoch(playedAtMs, isUtc: true).toLocal();

  GameRecord copyWith({int? score}) => GameRecord(
    modeId: modeId,
    score: score ?? this.score,
    correct: correct,
    rounds: rounds,
    avgTimeMs: avgTimeMs,
    playedAtMs: playedAtMs,
    daily: daily,
  );

  Map<String, dynamic> toJson() => {
    'm': modeId,
    's': score,
    'c': correct,
    'r': rounds,
    't': avgTimeMs,
    'at': playedAtMs,
    'd': daily,
  };

  /// Returns null when [j] is not a usable record (missing mode or time).
  static GameRecord? tryFromJson(Object? j) {
    if (j is! Map) return null;
    final mode = j['m'];
    final at = j['at'];
    if (mode is! String || mode.isEmpty || at is! num) return null;
    int n(Object? v) => v is num ? v.toInt() : 0;
    return GameRecord(
      modeId: mode,
      score: n(j['s']),
      correct: n(j['c']),
      rounds: n(j['r']),
      avgTimeMs: n(j['t']),
      playedAtMs: at.toInt(),
      daily: j['d'] == true,
    );
  }

  @override
  List<Object?> get props => [
    modeId,
    score,
    correct,
    rounds,
    avgTimeMs,
    playedAtMs,
    daily,
  ];
}
