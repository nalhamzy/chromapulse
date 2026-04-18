import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/feedback_kind.dart';

enum GamePhase { idle, showing, playing, resolved, finished }

class GameState extends Equatable {
  final GameMode mode;
  final GamePhase phase;
  final int round;              // 1-based
  final int totalRounds;
  final int score;
  final int combo;
  final int maxCombo;
  final int correct;
  final List<int> roundTimesMs;

  final int timeLimitMs;
  final int elapsedMs;
  final String instruction;

  // Grid modes
  final List<Color> cells;
  final int targetIndex;
  final int gridColumns;
  final int? pickedIndex;          // highlight cell after answer
  final int? revealedTargetIndex;  // reveal on miss/timeout

  // Recall mode
  final Color? memoryTarget;

  // Alchemist mode
  final Color? blendTarget;
  final int blendR;
  final int blendG;
  final int blendB;
  final int? lastAccuracyPct;

  // Transient signal flags (bumped by a counter so listeners fire every time)
  final int feedbackSignal;
  final FeedbackKind? lastFeedback;
  final int pointsSignal;
  final int lastPoints;

  // Snapshot of best for current mode at game start (for new-best detection on result screen)
  final int previousBestForMode;

  // True once the player has burned their rewarded-ad "2x score" claim for this run.
  final bool scoreDoubled;

  const GameState({
    this.mode = GameMode.shadeHunter,
    this.phase = GamePhase.idle,
    this.round = 0,
    this.totalRounds = 10,
    this.score = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.correct = 0,
    this.roundTimesMs = const [],
    this.timeLimitMs = 5000,
    this.elapsedMs = 0,
    this.instruction = '',
    this.cells = const [],
    this.targetIndex = -1,
    this.gridColumns = 3,
    this.pickedIndex,
    this.revealedTargetIndex,
    this.memoryTarget,
    this.blendTarget,
    this.blendR = 128,
    this.blendG = 128,
    this.blendB = 128,
    this.lastAccuracyPct,
    this.feedbackSignal = 0,
    this.lastFeedback,
    this.pointsSignal = 0,
    this.lastPoints = 0,
    this.previousBestForMode = 0,
    this.scoreDoubled = false,
  });

  double get timeFraction =>
      timeLimitMs == 0 ? 0 : (1 - elapsedMs / timeLimitMs).clamp(0.0, 1.0);

  double get avgTimeSec => roundTimesMs.isEmpty
      ? 0
      : roundTimesMs.reduce((a, b) => a + b) / roundTimesMs.length / 1000;

  GameState copyWith({
    GameMode? mode,
    GamePhase? phase,
    int? round,
    int? totalRounds,
    int? score,
    int? combo,
    int? maxCombo,
    int? correct,
    List<int>? roundTimesMs,
    int? timeLimitMs,
    int? elapsedMs,
    String? instruction,
    List<Color>? cells,
    int? targetIndex,
    int? gridColumns,
    int? Function()? pickedIndex,
    int? Function()? revealedTargetIndex,
    Color? Function()? memoryTarget,
    Color? Function()? blendTarget,
    int? blendR,
    int? blendG,
    int? blendB,
    int? Function()? lastAccuracyPct,
    int? feedbackSignal,
    FeedbackKind? Function()? lastFeedback,
    int? pointsSignal,
    int? lastPoints,
    int? previousBestForMode,
    bool? scoreDoubled,
  }) =>
      GameState(
        mode: mode ?? this.mode,
        phase: phase ?? this.phase,
        round: round ?? this.round,
        totalRounds: totalRounds ?? this.totalRounds,
        score: score ?? this.score,
        combo: combo ?? this.combo,
        maxCombo: maxCombo ?? this.maxCombo,
        correct: correct ?? this.correct,
        roundTimesMs: roundTimesMs ?? this.roundTimesMs,
        timeLimitMs: timeLimitMs ?? this.timeLimitMs,
        elapsedMs: elapsedMs ?? this.elapsedMs,
        instruction: instruction ?? this.instruction,
        cells: cells ?? this.cells,
        targetIndex: targetIndex ?? this.targetIndex,
        gridColumns: gridColumns ?? this.gridColumns,
        pickedIndex: pickedIndex != null ? pickedIndex() : this.pickedIndex,
        revealedTargetIndex: revealedTargetIndex != null
            ? revealedTargetIndex()
            : this.revealedTargetIndex,
        memoryTarget: memoryTarget != null ? memoryTarget() : this.memoryTarget,
        blendTarget: blendTarget != null ? blendTarget() : this.blendTarget,
        blendR: blendR ?? this.blendR,
        blendG: blendG ?? this.blendG,
        blendB: blendB ?? this.blendB,
        lastAccuracyPct:
            lastAccuracyPct != null ? lastAccuracyPct() : this.lastAccuracyPct,
        feedbackSignal: feedbackSignal ?? this.feedbackSignal,
        lastFeedback: lastFeedback != null ? lastFeedback() : this.lastFeedback,
        pointsSignal: pointsSignal ?? this.pointsSignal,
        lastPoints: lastPoints ?? this.lastPoints,
        previousBestForMode: previousBestForMode ?? this.previousBestForMode,
        scoreDoubled: scoreDoubled ?? this.scoreDoubled,
      );

  @override
  List<Object?> get props => [
        mode,
        phase,
        round,
        totalRounds,
        score,
        combo,
        maxCombo,
        correct,
        roundTimesMs,
        timeLimitMs,
        elapsedMs,
        instruction,
        cells,
        targetIndex,
        gridColumns,
        pickedIndex,
        revealedTargetIndex,
        memoryTarget,
        blendTarget,
        blendR,
        blendG,
        blendB,
        lastAccuracyPct,
        feedbackSignal,
        lastFeedback,
        pointsSignal,
        lastPoints,
        previousBestForMode,
        scoreDoubled,
      ];
}
