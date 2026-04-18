import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Override storageServiceProvider in main.dart');
});

class PlayerNotifier extends Notifier<PlayerStats> {
  @override
  PlayerStats build() => ref.read(storageServiceProvider).load();

  void recordGameEnd({
    required String modeId,
    required int score,
    required int correct,
    required int totalRounds,
  }) {
    final prevBest = state.bestFor(modeId);
    final newBest = score > prevBest ? score : prevBest;
    final updatedBest = Map<String, int>.from(state.bestByMode)
      ..[modeId] = newBest;

    state = state.copyWith(
      totalGames: state.totalGames + 1,
      totalScore: state.totalScore + score,
      totalCorrect: state.totalCorrect + correct,
      totalRounds: state.totalRounds + totalRounds,
      bestByMode: updatedBest,
    );
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
    state = state.copyWith(
      totalScore: state.totalScore + bonusPoints,
      bestByMode: updatedBest,
    );
    _save();
  }

  void activateRemoveAds() {
    if (state.adsRemoved) return;
    state = state.copyWith(adsRemoved: true);
    _save();
  }

  void activateVip() {
    if (state.vip) return;
    state = state.copyWith(vip: true, adsRemoved: true);
    _save();
  }

  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
    _save();
  }

  Future<void> _save() => ref.read(storageServiceProvider).save(state);
}

final playerProvider =
    NotifierProvider<PlayerNotifier, PlayerStats>(PlayerNotifier.new);
