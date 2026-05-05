import 'package:equatable/equatable.dart';
import 'package:chromapulse/core/models/game_mode.dart';

/// A single calendar-day challenge: a fixed mode + deterministic seed.
class DailyChallenge extends Equatable {
  /// UTC date YYYY-MM-DD (e.g. "2026-05-04").
  final String dateKey;

  /// Game mode the player must play today.
  final GameMode mode;

  /// Deterministic random seed (YYYYMMDD as int) — used to make round
  /// generation reproducible so all players share the same daily layout.
  final int seed;

  /// True when the player has already completed today's challenge.
  final bool completed;

  const DailyChallenge({
    required this.dateKey,
    required this.mode,
    required this.seed,
    required this.completed,
  });

  @override
  List<Object?> get props => [dateKey, mode, seed, completed];
}
