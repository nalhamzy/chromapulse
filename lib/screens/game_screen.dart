import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/models/feedback_kind.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/haptic_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/widgets/game/blend_area.dart';
import 'package:chromapulse/widgets/game/color_grid.dart';
import 'package:chromapulse/widgets/game/feedback_toast.dart';
import 'package:chromapulse/widgets/game/game_info_bar.dart';
import 'package:chromapulse/widgets/game/memory_flash.dart';
import 'package:chromapulse/widgets/game/palette_match_area.dart';
import 'package:chromapulse/widgets/game/points_popup.dart';
import 'package:chromapulse/widgets/game/timer_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  int _lastTickSecond = -1;

  @override
  Widget build(BuildContext context) {
    // Sound + haptic effects on feedback changes.
    ref.listen(gameProvider.select((g) => g.feedbackSignal), (prev, next) {
      if (prev == null || next == prev) return;
      final fb = ref.read(gameProvider).lastFeedback;
      if (fb == null) return;
      final audio = ref.read(audioServiceProvider);
      final haptic = ref.read(hapticServiceProvider);
      if (fb == FeedbackKind.miss || fb == FeedbackKind.timeUp) {
        audio.play(SoundEffect.wrong);
        haptic.error();
      } else {
        audio.play(SoundEffect.correct);
        final combo = ref.read(gameProvider).combo;
        if (combo >= 5) {
          audio.play(SoundEffect.combo);
          haptic.celebrate();
        } else {
          haptic.success();
        }
      }
    });

    // Countdown tick on last 3 seconds (whole-second crossings)
    ref.listen(gameProvider.select((g) => g.elapsedMs), (prev, next) {
      final g = ref.read(gameProvider);
      if (g.phase != GamePhase.playing) {
        _lastTickSecond = -1;
        return;
      }
      final remainingMs = g.timeLimitMs - next;
      if (remainingMs <= 0 || remainingMs > 3000) {
        _lastTickSecond = -1;
        return;
      }
      final sec = (remainingMs / 1000).ceil();
      if (sec != _lastTickSecond) {
        _lastTickSecond = sec;
        ref.read(audioServiceProvider).play(SoundEffect.countdownTick);
      }
    });

    final g = ref.watch(gameProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirm = await _confirmExit(context);
        if (confirm == true && context.mounted) {
          ref.read(gameProvider.notifier).abort();
          ref.read(screenProvider.notifier).go(AppScreen.menu);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Stack(
            children: [
              ResponsiveContentBox(
                child: Padding(
                  padding: EdgeInsets.all(context.s(16)),
                  child: Column(
                    children: [
                      _TopBar(mode: g.mode, isDaily: g.isDailyChallenge),
                      SizedBox(height: context.s(8)),
                      const GameInfoBar(),
                      SizedBox(height: context.s(10)),
                      const TimerBar(),
                      SizedBox(height: context.s(6)),
                      _Instruction(text: g.instruction),
                      SizedBox(height: context.s(6)),
                      Expanded(child: _GameArea(phase: g.phase, mode: g.mode)),
                    ],
                  ),
                ),
              ),
              FeedbackToast(
                signal: g.feedbackSignal,
                kind: g.lastFeedback,
              ),
              PointsPopup(signal: g.pointsSignal, points: g.lastPoints),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmExit(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Quit game?'),
          content: const Text('Your progress in this game will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('KEEP PLAYING'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('QUIT',
                  style: TextStyle(color: AppColors.accent2)),
            ),
          ],
        ),
      );
}

class _TopBar extends ConsumerWidget {
  final GameMode mode;
  final bool isDaily;
  const _TopBar({required this.mode, required this.isDaily});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () {
            ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
            ref.read(gameProvider.notifier).abort();
            ref.read(screenProvider.notifier).go(AppScreen.menu);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.textDim),
          label: Text(
            'BACK',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: context.s(12),
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            if (isDaily) ...[
              Icon(Icons.local_fire_department_rounded,
                  color: AppColors.gold, size: context.s(14)),
              SizedBox(width: context.s(4)),
              Text(
                'DAILY · ',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: context.s(11),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            Text(
              mode.label.toUpperCase(),
              style: TextStyle(
                color: mode.accent,
                fontSize: context.s(12),
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Instruction extends StatelessWidget {
  final String text;
  const _Instruction({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: context.s(28)),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.s(14),
          color: AppColors.textDim,
        ),
      ),
    );
  }
}

class _GameArea extends ConsumerWidget {
  final GamePhase phase;
  final GameMode mode;

  const _GameArea({required this.phase, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (mode == GameMode.colorAlchemist) {
      return const BlendArea();
    }
    if (mode == GameMode.paletteMatch) {
      return const PaletteMatchArea();
    }
    if (mode == GameMode.chromaRecall && phase == GamePhase.showing) {
      final target = ref.watch(gameProvider.select((g) => g.memoryTarget));
      if (target != null) {
        return Center(child: MemoryFlash(color: target));
      }
    }
    return const Center(child: ColorGrid());
  }
}
