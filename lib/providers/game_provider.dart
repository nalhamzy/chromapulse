import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/models/feedback_kind.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/models/round_config.dart';
import 'package:chromapulse/core/utils/color_utils.dart';
import 'package:chromapulse/providers/player_provider.dart';

class GameNotifier extends Notifier<GameState> {
  final _rng = math.Random();
  Timer? _ticker;
  Timer? _memoryTimer;
  Timer? _resolveTimer;
  int _roundStartMs = 0;

  @override
  GameState build() {
    ref.onDispose(_cancelAll);
    return const GameState();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  void startGame(GameMode mode) {
    _cancelAll();
    final previousBest = ref.read(playerProvider).bestFor(mode.id);
    state = GameState(
      mode: mode,
      totalRounds: mode.totalRounds,
      phase: GamePhase.idle,
      previousBestForMode: previousBest,
    );
    _beginNextRound();
  }

  /// Rewarded-ad reward: doubles the final score once per run. Only callable
  /// while the game is finished. Persists the bonus points to player best.
  void applyScoreDouble() {
    if (state.phase != GamePhase.finished) return;
    if (state.scoreDoubled) return;
    final bonus = state.score; // doubling = adding the same amount again
    state = state.copyWith(score: state.score + bonus, scoreDoubled: true);
    ref.read(playerProvider.notifier).recordBonusScore(
          modeId: state.mode.id,
          totalScore: state.score,
          bonusPoints: bonus,
        );
  }

  void retry() {
    if (state.mode == GameMode.shadeHunter &&
        state.phase == GamePhase.idle &&
        state.round == 0) {
      return;
    }
    startGame(state.mode);
  }

  void abort() {
    _cancelAll();
    state = const GameState();
  }

  void handlePick(int index) {
    if (state.phase != GamePhase.playing) return;
    if (state.mode == GameMode.colorAlchemist) return;
    _ticker?.cancel();
    final elapsed = _nowMs() - _roundStartMs;
    _applyPerceptionResult(
      correct: index == state.targetIndex,
      pickedIndex: index,
      elapsedMs: elapsed,
    );
  }

  void updateBlend({int? r, int? g, int? b}) {
    state = state.copyWith(
      blendR: r ?? state.blendR,
      blendG: g ?? state.blendG,
      blendB: b ?? state.blendB,
    );
  }

  void submitBlend() {
    if (state.phase != GamePhase.playing) return;
    if (state.mode != GameMode.colorAlchemist) return;
    _ticker?.cancel();
    final elapsed = _nowMs() - _roundStartMs;
    _applyBlendResult(elapsedMs: elapsed);
  }

  // ── Round lifecycle ──────────────────────────────────────────────────────

  void _beginNextRound() {
    _resolveTimer?.cancel();
    final next = state.round + 1;
    if (next > state.totalRounds) {
      _endGame();
      return;
    }
    final cfg = _buildRound(state.mode, next);
    state = state.copyWith(
      round: next,
      instruction: cfg.instruction,
      timeLimitMs: cfg.timeLimitMs,
      elapsedMs: 0,
      cells: cfg.cells,
      targetIndex: cfg.targetIndex,
      gridColumns: cfg.gridColumns,
      pickedIndex: () => null,
      revealedTargetIndex: () => null,
      memoryTarget: () => cfg.memoryTarget,
      blendTarget: () => cfg.blendTarget,
      blendR: 128,
      blendG: 128,
      blendB: 128,
      lastAccuracyPct: () => null,
    );
    if (state.mode == GameMode.chromaRecall) {
      _startMemoryPhase(cfg);
    } else {
      _startPlayingPhase();
    }
  }

  void _startMemoryPhase(RoundConfig cfg) {
    state = state.copyWith(phase: GamePhase.showing);
    _memoryTimer = Timer(Duration(milliseconds: cfg.memoryShowMs), () {
      state = state.copyWith(memoryTarget: () => null);
      _startPlayingPhase();
    });
  }

  void _startPlayingPhase() {
    _roundStartMs = _nowMs();
    state = state.copyWith(phase: GamePhase.playing, elapsedMs: 0);
    _startTicker();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void _tick() {
    if (state.phase != GamePhase.playing) return;
    final elapsed = _nowMs() - _roundStartMs;
    if (elapsed >= state.timeLimitMs) {
      _ticker?.cancel();
      _handleTimeout();
      return;
    }
    state = state.copyWith(elapsedMs: elapsed);
  }

  void _handleTimeout() {
    final times = [...state.roundTimesMs, state.timeLimitMs];
    state = state.copyWith(
      phase: GamePhase.resolved,
      elapsedMs: state.timeLimitMs,
      combo: 0,
      roundTimesMs: times,
      revealedTargetIndex:
          state.mode.hasGrid ? () => state.targetIndex : () => null,
      feedbackSignal: state.feedbackSignal + 1,
      lastFeedback: () => FeedbackKind.timeUp,
    );
    _scheduleNextRound(const Duration(milliseconds: 1200));
  }

  void _applyPerceptionResult({
    required bool correct,
    required int pickedIndex,
    required int elapsedMs,
  }) {
    final times = [...state.roundTimesMs, elapsedMs];
    if (!correct) {
      state = state.copyWith(
        phase: GamePhase.resolved,
        elapsedMs: elapsedMs,
        combo: 0,
        pickedIndex: () => pickedIndex,
        revealedTargetIndex: () => state.targetIndex,
        roundTimesMs: times,
        feedbackSignal: state.feedbackSignal + 1,
        lastFeedback: () => FeedbackKind.miss,
        pointsSignal: state.pointsSignal + 1,
        lastPoints: 0,
      );
      _scheduleNextRound(const Duration(milliseconds: 1000));
      return;
    }

    final newCombo = state.combo + 1;
    final maxCombo =
        newCombo > state.maxCombo ? newCombo : state.maxCombo;
    final timeBonus =
        math.max(0.0, 1 - elapsedMs / state.timeLimitMs); // 0..1
    final comboMult = 1 + (newCombo - 1) * 0.25;
    final points = ((100 + timeBonus * 50) * comboMult).round();
    final feedback = timeBonus > 0.7
        ? FeedbackKind.blazing
        : timeBonus > 0.3
            ? FeedbackKind.nice
            : FeedbackKind.correct;

    state = state.copyWith(
      phase: GamePhase.resolved,
      elapsedMs: elapsedMs,
      combo: newCombo,
      maxCombo: maxCombo,
      correct: state.correct + 1,
      score: state.score + points,
      pickedIndex: () => pickedIndex,
      roundTimesMs: times,
      feedbackSignal: state.feedbackSignal + 1,
      lastFeedback: () => feedback,
      pointsSignal: state.pointsSignal + 1,
      lastPoints: points,
    );
    _scheduleNextRound(const Duration(milliseconds: 1000));
  }

  void _applyBlendResult({required int elapsedMs}) {
    final picked = Color.fromARGB(255, state.blendR, state.blendG, state.blendB);
    final target = state.blendTarget!;
    final accPct = (rgbAccuracy(picked, target) * 100).round();

    int base;
    FeedbackKind fb;
    bool bumpCombo;
    if (accPct >= 95) {
      base = 150;
      fb = FeedbackKind.perfect;
      bumpCombo = true;
    } else if (accPct >= 85) {
      base = 100;
      fb = FeedbackKind.great;
      bumpCombo = true;
    } else if (accPct >= 70) {
      base = 60;
      fb = FeedbackKind.good;
      bumpCombo = true;
    } else if (accPct >= 50) {
      base = 25;
      fb = FeedbackKind.ok;
      bumpCombo = false;
    } else {
      base = 0;
      fb = FeedbackKind.miss;
      bumpCombo = false;
    }

    final newCombo = bumpCombo ? state.combo + 1 : 0;
    final maxCombo =
        newCombo > state.maxCombo ? newCombo : state.maxCombo;
    final comboMult = 1 + (newCombo - 1) * 0.25;
    final points = (base * math.max(1.0, comboMult)).round();
    final correctInc = accPct >= 70 ? 1 : 0;

    final times = [...state.roundTimesMs, elapsedMs];

    state = state.copyWith(
      phase: GamePhase.resolved,
      elapsedMs: elapsedMs,
      combo: newCombo,
      maxCombo: maxCombo,
      correct: state.correct + correctInc,
      score: state.score + points,
      roundTimesMs: times,
      lastAccuracyPct: () => accPct,
      feedbackSignal: state.feedbackSignal + 1,
      lastFeedback: () => fb,
      pointsSignal: state.pointsSignal + 1,
      lastPoints: points,
    );
    _scheduleNextRound(const Duration(milliseconds: 1200));
  }

  void _scheduleNextRound(Duration after) {
    _resolveTimer?.cancel();
    _resolveTimer = Timer(after, _beginNextRound);
  }

  void _endGame() {
    _cancelAll();
    state = state.copyWith(phase: GamePhase.finished);
    ref.read(playerProvider.notifier).recordGameEnd(
          modeId: state.mode.id,
          score: state.score,
          correct: state.correct,
          totalRounds: state.totalRounds,
        );
  }

  void _cancelAll() {
    _ticker?.cancel();
    _memoryTimer?.cancel();
    _resolveTimer?.cancel();
  }

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  // ── Round builders (dispatch) ────────────────────────────────────────────

  RoundConfig _buildRound(GameMode mode, int diff) {
    switch (mode) {
      case GameMode.shadeHunter:
        return _buildShadeRound(diff, _rng);
      case GameMode.oddChroma:
        return _buildOddRound(diff, _rng);
      case GameMode.chromaRecall:
        return _buildRecallRound(diff, _rng);
      case GameMode.colorAlchemist:
        return _buildAlchemistRound(diff, _rng);
    }
  }
}

// ── Mode builders (private top-level, pure) ────────────────────────────────

RoundConfig _buildShadeRound(int diff, math.Random rng) {
  final count = diff <= 3
      ? 9
      : diff <= 7
          ? 12
          : 16;
  final columns = count == 9 ? 3 : (count == 12 ? 4 : 4);
  final findDarkest = rng.nextBool();
  final hue = randDouble(rng, 0, 360);
  final sat = randDouble(rng, 50, 90);
  final range = math.max(4.0, 30 - diff * 2.5);
  final baseL =
      findDarkest ? randDouble(rng, 45, 65) : randDouble(rng, 35, 55);

  final lightnesses = <double>[];
  for (var i = 0; i < count; i++) {
    lightnesses.add(baseL + (rng.nextDouble() - 0.5) * range);
  }
  final targetOffset = math.max(3.0, 12 - diff.toDouble());
  final extreme = findDarkest
      ? lightnesses.reduce(math.min) - targetOffset
      : lightnesses.reduce(math.max) + targetOffset;
  final targetIdx = rng.nextInt(count);
  lightnesses[targetIdx] = extreme;

  final cells = lightnesses
      .map((l) => hslToRgb(hue, sat, l.clamp(5.0, 95.0)))
      .toList();

  return RoundConfig(
    cells: cells,
    targetIndex: targetIdx,
    gridColumns: columns,
    instruction:
        'Find the ${findDarkest ? 'darkest' : 'lightest'} shade',
    timeLimitMs: 5000,
  );
}

RoundConfig _buildOddRound(int diff, math.Random rng) {
  final count = diff <= 4 ? 9 : 16;
  final columns = count == 9 ? 3 : 4;
  final hue = randDouble(rng, 0, 360);
  final sat = randDouble(rng, 55, 85);
  final light = randDouble(rng, 40, 65);
  final hueDiff = math.max(3.0, 25 - diff * 2.2);
  final targetIdx = rng.nextInt(count);
  final base = hslToRgb(hue, sat, light);
  final odd = hslToRgb((hue + hueDiff) % 360, sat, light);
  final cells = List<Color>.generate(
    count,
    (i) => i == targetIdx ? odd : base,
  );
  return RoundConfig(
    cells: cells,
    targetIndex: targetIdx,
    gridColumns: columns,
    instruction: 'Spot the different color',
    timeLimitMs: 5000,
  );
}

RoundConfig _buildRecallRound(int diff, math.Random rng) {
  final count = diff <= 3
      ? 9
      : diff <= 7
          ? 12
          : 16;
  final columns = count == 9 ? 3 : 4;
  final hue = randDouble(rng, 0, 360);
  final sat = randDouble(rng, 50, 85);
  final light = randDouble(rng, 35, 65);
  final target = hslToRgb(hue, sat, light);

  final range = math.max(4.0, 20 - diff * 1.5);
  final cells = <Color>[];
  for (var i = 0; i < count; i++) {
    final lOff = (rng.nextDouble() - 0.5) * range;
    final hOff = (rng.nextDouble() - 0.5) * range;
    cells.add(hslToRgb(
      (hue + hOff + 360) % 360,
      sat,
      (light + lOff).clamp(10.0, 90.0),
    ));
  }
  final targetIdx = rng.nextInt(count);
  cells[targetIdx] = target;

  final showMs = math.max(800, 2500 - diff * 150);
  return RoundConfig(
    cells: cells,
    targetIndex: targetIdx,
    gridColumns: columns,
    instruction: 'Find the exact color you saw',
    timeLimitMs: 5000,
    memoryTarget: target,
    memoryShowMs: showMs,
  );
}

RoundConfig _buildAlchemistRound(int diff, math.Random rng) {
  final hue = randDouble(rng, 0, 360);
  final sat = randDouble(rng, 40, 90);
  final light = randDouble(rng, 25, 75);
  final target = hslToRgb(hue, sat, light);
  return RoundConfig(
    cells: const [],
    targetIndex: -1,
    gridColumns: 3,
    instruction: 'Mix the exact color using RGB sliders',
    timeLimitMs: math.max(5000, 12000 - diff * 500),
    blendTarget: target,
  );
}

final gameProvider =
    NotifierProvider<GameNotifier, GameState>(GameNotifier.new);
