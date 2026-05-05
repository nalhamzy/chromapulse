import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/models/player_stats.dart';

/// Triggers that change which achievements may unlock between calls. The
/// player's achievement state lives in [PlayerStats]; this service is pure
/// — it never mutates state, just reports newly-eligible IDs back so the
/// notifier can persist them.
class AchievementTrigger {
  /// Player just finished a game (`game.phase == finished`). The score on
  /// `game` is the post-double score; pre-double accuracy still uses
  /// `correct/totalRounds` so the round-based criteria stay accurate.
  final GameState? gameJustEnded;

  /// Set true when the player just shared a score for the first time this call.
  final bool sharedThisCall;

  /// Set true when the player just watched a rewarded ad.
  final bool watchedRewardedAdThisCall;

  /// Set true when the VIP entitlement was just activated.
  final bool vipJustActivated;

  const AchievementTrigger({
    this.gameJustEnded,
    this.sharedThisCall = false,
    this.watchedRewardedAdThisCall = false,
    this.vipJustActivated = false,
  });
}

class AchievementService {
  /// Returns the IDs that have just become unlocked. Caller is responsible
  /// for persisting them on [PlayerStats.unlockedAchievements].
  ///
  /// Pass the *post-update* [PlayerStats] so totals (totalGames, totalScore,
  /// streak, rewardedAdsWatched, sharesCount) already reflect the trigger.
  List<AchievementId> evaluate(
    PlayerStats player,
    AchievementTrigger trigger,
  ) {
    final unlocked = player.unlockedAchievements;
    final newly = <AchievementId>[];

    void check(AchievementId id, bool condition) {
      if (condition && !unlocked.contains(id.key) && !newly.contains(id)) {
        newly.add(id);
      }
    }

    final game = trigger.gameJustEnded;

    // Onboarding
    check(AchievementId.firstPulse, player.totalGames >= 1);
    check(
      AchievementId.curiousEye,
      // All four core (non-VIP) modes must have at least one recorded score.
      [
        GameMode.shadeHunter,
        GameMode.oddChroma,
        GameMode.chromaRecall,
        GameMode.colorAlchemist,
      ].every((m) {
        final hist = player.recentScoresByMode[m.id];
        return hist != null && hist.isNotEmpty;
      }),
    );
    check(
      AchievementId.perfectionist,
      game != null &&
          game.totalRounds > 0 &&
          game.correct == game.totalRounds,
    );

    // Skill — per mode score thresholds
    check(
      AchievementId.sharpShade,
      player.bestFor(GameMode.shadeHunter.id) >= 1500,
    );
    check(
      AchievementId.hueHunter,
      player.bestFor(GameMode.oddChroma.id) >= 1500,
    );
    check(
      AchievementId.memoryMaster,
      player.bestFor(GameMode.chromaRecall.id) >= 1500,
    );
    check(
      AchievementId.trueMixer,
      player.bestFor(GameMode.colorAlchemist.id) >= 800,
    );
    check(
      AchievementId.comboKing,
      game != null && game.maxCombo >= 10,
    );

    // Habit
    check(AchievementId.dailyDose, player.lastDailyDate != null);
    check(AchievementId.weekStreak, player.currentStreak >= 7);
    check(AchievementId.monthStreak, player.currentStreak >= 30);
    check(AchievementId.centurion, player.totalGames >= 100);
    check(AchievementId.chromatic, player.totalScore >= 10000);

    // Premium / Social
    check(AchievementId.vipVision, player.vip);
    check(
      AchievementId.palettePro,
      player.bestFor(GameMode.paletteMatch.id) >= 600,
    );
    check(AchievementId.sharer, player.sharesCount >= 1);
    check(AchievementId.generous, player.rewardedAdsWatched >= 5);

    // All-star — needs every other achievement (post-this-batch).
    final wouldBeUnlocked = {
      ...unlocked,
      ...newly.map((e) => e.key),
    };
    final allOthers = AchievementId.values
        .where((a) => a != AchievementId.allStar)
        .every((a) => wouldBeUnlocked.contains(a.key));
    check(AchievementId.allStar, allOthers);

    return newly;
  }
}
