import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Persisted player profile. v1.1.0 adds streak, achievements, recent-score
/// history, haptics flag, and engagement counters used by the achievement
/// evaluator. All new fields are optional in [fromJson] so installs upgrading
/// from 1.0.x decode cleanly.
class PlayerStats extends Equatable {
  // — Lifetime totals (v1.0+) —
  final int totalGames;
  final int totalScore;
  final int totalCorrect;
  final int totalRounds;
  final Map<String, int> bestByMode;

  // — Entitlements / settings (v1.0+ + new haptics flag) —
  final bool adsRemoved;
  final bool vip;
  final bool soundEnabled;
  final bool hapticsEnabled;

  // — Daily Challenge + streak (v1.1) —
  /// Calendar date (UTC, YYYY-MM-DD) of the most recently *completed* daily
  /// challenge. Drives streak math and the menu banner state.
  final String? lastDailyDate;
  final int currentStreak;
  final int longestStreak;

  // — Achievements (v1.1) —
  /// Set of unlocked achievement IDs (see [AchievementId]).
  final Set<String> unlockedAchievements;

  // — Per-mode score history (v1.1) — last 30 entries newest-first.
  final Map<String, List<int>> recentScoresByMode;

  // — Engagement counters used by achievement criteria (v1.1) —
  final int rewardedAdsWatched;
  final int sharesCount;

  const PlayerStats({
    this.totalGames = 0,
    this.totalScore = 0,
    this.totalCorrect = 0,
    this.totalRounds = 0,
    this.bestByMode = const {},
    this.adsRemoved = false,
    this.vip = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.lastDailyDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.unlockedAchievements = const {},
    this.recentScoresByMode = const {},
    this.rewardedAdsWatched = 0,
    this.sharesCount = 0,
  });

  int bestFor(String modeId) => bestByMode[modeId] ?? 0;

  int get accuracyPct =>
      totalRounds > 0 ? ((totalCorrect / totalRounds) * 100).round() : 0;

  /// Number of distinct modes the player has played at least one round in.
  int get modesPlayed => bestByMode.values.where((v) => v > 0).length +
      // Modes with 0 best but >0 games played still count via recent history.
      recentScoresByMode.entries
          .where((e) => !bestByMode.containsKey(e.key) && e.value.isNotEmpty)
          .length;

  /// Most recent score for a mode, or 0 if none recorded.
  int lastScoreFor(String modeId) {
    final list = recentScoresByMode[modeId];
    return (list == null || list.isEmpty) ? 0 : list.first;
  }

  PlayerStats copyWith({
    int? totalGames,
    int? totalScore,
    int? totalCorrect,
    int? totalRounds,
    Map<String, int>? bestByMode,
    bool? adsRemoved,
    bool? vip,
    bool? soundEnabled,
    bool? hapticsEnabled,
    String? Function()? lastDailyDate,
    int? currentStreak,
    int? longestStreak,
    Set<String>? unlockedAchievements,
    Map<String, List<int>>? recentScoresByMode,
    int? rewardedAdsWatched,
    int? sharesCount,
  }) =>
      PlayerStats(
        totalGames: totalGames ?? this.totalGames,
        totalScore: totalScore ?? this.totalScore,
        totalCorrect: totalCorrect ?? this.totalCorrect,
        totalRounds: totalRounds ?? this.totalRounds,
        bestByMode: bestByMode ?? this.bestByMode,
        adsRemoved: adsRemoved ?? this.adsRemoved,
        vip: vip ?? this.vip,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        lastDailyDate:
            lastDailyDate != null ? lastDailyDate() : this.lastDailyDate,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        unlockedAchievements:
            unlockedAchievements ?? this.unlockedAchievements,
        recentScoresByMode: recentScoresByMode ?? this.recentScoresByMode,
        rewardedAdsWatched: rewardedAdsWatched ?? this.rewardedAdsWatched,
        sharesCount: sharesCount ?? this.sharesCount,
      );

  Map<String, dynamic> toJson() => {
        'totalGames': totalGames,
        'totalScore': totalScore,
        'totalCorrect': totalCorrect,
        'totalRounds': totalRounds,
        'bestByMode': bestByMode,
        'adsRemoved': adsRemoved,
        'vip': vip,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'lastDailyDate': lastDailyDate,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'unlockedAchievements': unlockedAchievements.toList(),
        'recentScoresByMode': recentScoresByMode
            .map((k, v) => MapEntry(k, List<int>.from(v))),
        'rewardedAdsWatched': rewardedAdsWatched,
        'sharesCount': sharesCount,
      };

  static PlayerStats fromJson(Map<String, dynamic> j) => PlayerStats(
        totalGames: j['totalGames'] as int? ?? 0,
        totalScore: j['totalScore'] as int? ?? 0,
        totalCorrect: j['totalCorrect'] as int? ?? 0,
        totalRounds: j['totalRounds'] as int? ?? 0,
        bestByMode: (j['bestByMode'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ??
            const {},
        adsRemoved: j['adsRemoved'] as bool? ?? false,
        vip: j['vip'] as bool? ?? false,
        soundEnabled: j['soundEnabled'] as bool? ?? true,
        hapticsEnabled: j['hapticsEnabled'] as bool? ?? true,
        lastDailyDate: j['lastDailyDate'] as String?,
        currentStreak: j['currentStreak'] as int? ?? 0,
        longestStreak: j['longestStreak'] as int? ?? 0,
        unlockedAchievements: (j['unlockedAchievements'] as List?)
                ?.map((e) => e.toString())
                .toSet() ??
            const {},
        recentScoresByMode: (j['recentScoresByMode'] as Map?)?.map(
              (k, v) => MapEntry(
                k.toString(),
                (v as List).map((e) => (e as num).toInt()).toList(),
              ),
            ) ??
            const {},
        rewardedAdsWatched: j['rewardedAdsWatched'] as int? ?? 0,
        sharesCount: j['sharesCount'] as int? ?? 0,
      );

  String encode() => jsonEncode(toJson());

  static PlayerStats decode(String raw) {
    try {
      return fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const PlayerStats();
    }
  }

  @override
  List<Object?> get props => [
        totalGames,
        totalScore,
        totalCorrect,
        totalRounds,
        bestByMode,
        adsRemoved,
        vip,
        soundEnabled,
        hapticsEnabled,
        lastDailyDate,
        currentStreak,
        longestStreak,
        unlockedAchievements,
        recentScoresByMode,
        rewardedAdsWatched,
        sharesCount,
      ];
}
