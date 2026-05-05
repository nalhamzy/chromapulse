import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/achievement_service.dart';
import 'package:chromapulse/core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Override storageServiceProvider in main.dart');
});

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

class PlayerNotifier extends Notifier<PlayerStats> {
  /// IDs unlocked by the most recent state-mutating call. The result screen
  /// reads + clears this so it can show a toast for each new badge once.
  List<AchievementId> _pendingUnlocks = const [];

  List<AchievementId> get pendingUnlocks => _pendingUnlocks;

  void clearPendingUnlocks() {
    _pendingUnlocks = const [];
  }

  @override
  PlayerStats build() => ref.read(storageServiceProvider).load();

  /// Records the end of a game and evaluates achievements. Pass the post-
  /// final-score [GameState]; the notifier handles totals, best, recent
  /// history, daily streak, and achievement unlocks atomically.
  void recordGameEnd(GameState game) {
    final modeId = game.mode.id;
    final score = game.score;

    // Totals
    final newTotalGames = state.totalGames + 1;
    final newTotalScore = state.totalScore + score;
    final newTotalCorrect = state.totalCorrect + game.correct;
    final newTotalRounds = state.totalRounds + game.totalRounds;

    // Best per mode
    final prevBest = state.bestFor(modeId);
    final newBest = score > prevBest ? score : prevBest;
    final updatedBest = Map<String, int>.from(state.bestByMode)
      ..[modeId] = newBest;

    // Recent score history (newest-first, max 30 per mode)
    final updatedRecent =
        Map<String, List<int>>.from(state.recentScoresByMode);
    final list = List<int>.from(updatedRecent[modeId] ?? const <int>[]);
    list.insert(0, score);
    if (list.length > 30) list.removeRange(30, list.length);
    updatedRecent[modeId] = list;

    // Daily streak update (only if this run was a daily challenge AND we
    // haven't already booked today's streak — replays in the same day no-op).
    String? newLastDaily = state.lastDailyDate;
    int newCurrentStreak = state.currentStreak;
    int newLongestStreak = state.longestStreak;
    if (game.isDailyChallenge) {
      final today = _todayKey();
      if (state.lastDailyDate != today) {
        final yesterday = _yesterdayKey();
        newCurrentStreak =
            state.lastDailyDate == yesterday ? state.currentStreak + 1 : 1;
        newLongestStreak = newCurrentStreak > state.longestStreak
            ? newCurrentStreak
            : state.longestStreak;
        newLastDaily = today;
      }
    } else {
      // Non-daily play also breaks the streak if a calendar day was missed.
      newCurrentStreak = _streakAfterMaybeMiss(state);
    }

    var updated = state.copyWith(
      totalGames: newTotalGames,
      totalScore: newTotalScore,
      totalCorrect: newTotalCorrect,
      totalRounds: newTotalRounds,
      bestByMode: updatedBest,
      recentScoresByMode: updatedRecent,
      lastDailyDate: () => newLastDaily,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
    );

    final newly = ref.read(achievementServiceProvider).evaluate(
          updated,
          AchievementTrigger(gameJustEnded: game),
        );
    if (newly.isNotEmpty) {
      updated = updated.copyWith(
        unlockedAchievements: {
          ...updated.unlockedAchievements,
          ...newly.map((e) => e.key),
        },
      );
    }

    state = updated;
    _pendingUnlocks = newly;
    _save();
  }

  /// Apply a post-game bonus score (from a rewarded "2x score" ad).
  /// Bumps totalScore and updates the best for the mode if the new total wins.
  void recordBonusScore({
    required String modeId,
    required int totalScore,
    required int bonusPoints,
  }) {
    final prevBest = state.bestFor(modeId);
    final newBest = totalScore > prevBest ? totalScore : prevBest;
    final updatedBest = Map<String, int>.from(state.bestByMode)
      ..[modeId] = newBest;
    var updated = state.copyWith(
      totalScore: state.totalScore + bonusPoints,
      bestByMode: updatedBest,
      rewardedAdsWatched: state.rewardedAdsWatched + 1,
    );

    final newly = ref.read(achievementServiceProvider).evaluate(
          updated,
          const AchievementTrigger(watchedRewardedAdThisCall: true),
        );
    if (newly.isNotEmpty) {
      updated = updated.copyWith(
        unlockedAchievements: {
          ...updated.unlockedAchievements,
          ...newly.map((e) => e.key),
        },
      );
    }
    state = updated;
    _pendingUnlocks = [..._pendingUnlocks, ...newly];
    _save();
  }

  /// Called when the player completes a result-screen share.
  void recordShare() {
    var updated = state.copyWith(sharesCount: state.sharesCount + 1);
    final newly = ref.read(achievementServiceProvider).evaluate(
          updated,
          const AchievementTrigger(sharedThisCall: true),
        );
    if (newly.isNotEmpty) {
      updated = updated.copyWith(
        unlockedAchievements: {
          ...updated.unlockedAchievements,
          ...newly.map((e) => e.key),
        },
      );
    }
    state = updated;
    _pendingUnlocks = [..._pendingUnlocks, ...newly];
    _save();
  }

  void activateRemoveAds() {
    if (state.adsRemoved) return;
    state = state.copyWith(adsRemoved: true);
    _save();
  }

  void activateVip() {
    if (state.vip) return;
    var updated = state.copyWith(vip: true, adsRemoved: true);
    final newly = ref.read(achievementServiceProvider).evaluate(
          updated,
          const AchievementTrigger(vipJustActivated: true),
        );
    if (newly.isNotEmpty) {
      updated = updated.copyWith(
        unlockedAchievements: {
          ...updated.unlockedAchievements,
          ...newly.map((e) => e.key),
        },
      );
    }
    state = updated;
    _pendingUnlocks = newly;
    _save();
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _save();
  }

  void toggleHaptics() {
    state = state.copyWith(hapticsEnabled: !state.hapticsEnabled);
    _save();
  }

  /// Wipes all gameplay history and achievements, but preserves entitlements
  /// (adsRemoved / vip) so the player doesn't lose their purchases.
  void resetStats() {
    state = PlayerStats(
      adsRemoved: state.adsRemoved,
      vip: state.vip,
      soundEnabled: state.soundEnabled,
      hapticsEnabled: state.hapticsEnabled,
    );
    _pendingUnlocks = const [];
    _save();
  }

  Future<void> _save() => ref.read(storageServiceProvider).save(state);

  // ── Streak helpers ───────────────────────────────────────────────────────

  static String _todayKey([DateTime? now]) {
    final d = (now ?? DateTime.now()).toUtc();
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  static String _yesterdayKey([DateTime? now]) {
    final d = (now ?? DateTime.now()).toUtc().subtract(const Duration(days: 1));
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$y-$m-$dd';
  }

  /// If the last daily was earlier than yesterday, the streak is broken.
  /// We don't auto-zero on app launch — only on game-end so the menu can
  /// still show the "Streak broken" copy via [DailyChallengeService] +
  /// `lastDailyDate`. But once any non-daily game ends after a missed day,
  /// reset the live counter so the Stats screen reflects truth.
  static int _streakAfterMaybeMiss(PlayerStats s) {
    if (s.lastDailyDate == null) return s.currentStreak;
    final today = _todayKey();
    final yesterday = _yesterdayKey();
    if (s.lastDailyDate == today || s.lastDailyDate == yesterday) {
      return s.currentStreak;
    }
    return 0;
  }
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerStats>(PlayerNotifier.new);
