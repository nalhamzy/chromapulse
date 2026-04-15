import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/widgets/common/gradient_button.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).play(SoundEffect.gameOver);
    });
  }

  @override
  Widget build(BuildContext context) {
    final g = ref.watch(gameProvider);
    final isNewBest = g.score > g.previousBestForMode;
    final pct = g.totalRounds == 0 ? 0.0 : g.correct / g.totalRounds;

    String title, grade;
    if (pct >= 0.9) {
      title = 'Incredible!';
      grade =
          'Your color perception is extraordinary. You have the eyes of an artist!';
    } else if (pct >= 0.7) {
      title = 'Great Job!';
      grade = 'Solid performance! Your color sense is well above average.';
    } else if (pct >= 0.5) {
      title = 'Not Bad!';
      grade =
          "Keep practicing and you'll sharpen those chromatic instincts.";
    } else {
      title = 'Keep Going!';
      grade = 'Color perception improves with practice. Try again!';
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Padding(
            padding: EdgeInsets.all(context.s(24)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: context.s(32),
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: context.s(16)),
                  ShaderMask(
                    shaderCallback: (rect) =>
                        AppTheme.logoGradient1.createShader(rect),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      '${g.score}',
                      style: AppTheme.mono(
                        fontSize: context.s(56),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isNewBest) ...[
                    SizedBox(height: context.s(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.s(16), vertical: context.s(6)),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '★ NEW BEST ★',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: context.s(11),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: context.s(24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ResultStatBlock(
                        value: '${g.correct}/${g.totalRounds}',
                        label: 'Correct',
                        valueColor: AppColors.accent,
                      ),
                      ResultStatBlock(
                        value: '×${g.maxCombo}',
                        label: 'Max Combo',
                        valueColor: AppColors.gold,
                      ),
                      ResultStatBlock(
                        value: '${g.avgTimeSec.toStringAsFixed(1)}s',
                        label: 'Avg Time',
                        valueColor: AppColors.accent3,
                      ),
                    ],
                  ),
                  SizedBox(height: context.s(24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.s(16)),
                    child: Text(
                      grade,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.s(13),
                        color: AppColors.textDim,
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: context.s(32)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SecondaryButton(
                        text: 'MENU',
                        onTap: () {
                          ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                          ref.read(screenProvider.notifier).go(AppScreen.menu);
                        },
                      ),
                      SizedBox(width: context.s(12)),
                      GradientButton(
                        text: 'Play Again',
                        width: 160,
                        gradient: AppTheme.logoGradient1,
                        textColor: Colors.black,
                        onPressed: () {
                          ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                          ref.read(gameProvider.notifier).startGame(g.mode);
                          ref.read(screenProvider.notifier).go(AppScreen.game);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SecondaryButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.s(12)),
      child: Container(
        width: context.s(140),
        padding: EdgeInsets.symmetric(vertical: context.s(14)),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(context.s(12)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.text,
            fontSize: context.s(14),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
