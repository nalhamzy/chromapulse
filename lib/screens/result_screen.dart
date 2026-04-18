import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/ad_provider.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
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
                  SizedBox(height: context.s(20)),
                  // Rewarded-ad "2× SCORE" — shown once per run, only for
                  // non-premium players while an ad is loaded. Silent no-op
                  // otherwise so it doesn't clutter the result screen.
                  if (_shouldShowDoubleScore(ref, g))
                    Padding(
                      padding: EdgeInsets.only(bottom: context.s(12)),
                      child: _DoubleScoreButton(),
                    ),
                  // Primary action — full-width "PLAY AGAIN"
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: 'PLAY AGAIN',
                      width: double.infinity,
                      gradient: AppTheme.logoGradient1,
                      textColor: Colors.black,
                      onPressed: () {
                        ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                        ref.read(gameProvider.notifier).startGame(g.mode);
                        ref.read(screenProvider.notifier).go(AppScreen.game);
                      },
                    ),
                  ),
                  SizedBox(height: context.s(12)),
                  // Secondary actions — Wrap so they never overflow on narrow phones.
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: context.s(10),
                    runSpacing: context.s(8),
                    children: [
                      _SecondaryButton(
                        text: 'Change Mode',
                        icon: Icons.grid_view_rounded,
                        onTap: () {
                          ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                          ref.read(screenProvider.notifier).go(AppScreen.menu);
                        },
                      ),
                      _SecondaryButton(
                        text: 'Share Score',
                        icon: Icons.ios_share_rounded,
                        onTap: () {
                          ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Score ${g.score} — ${g.mode.label}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
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

bool _shouldShowDoubleScore(WidgetRef ref, dynamic g) {
  if (g.score <= 0) return false;
  if (g.scoreDoubled) return false;
  if (ref.read(playerProvider).adsRemoved) return false;
  return ref.read(adServiceProvider).hasRewardedAd;
}

class _DoubleScoreButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_DoubleScoreButton> createState() =>
      _DoubleScoreButtonState();
}

class _DoubleScoreButtonState extends ConsumerState<_DoubleScoreButton> {
  bool _busy = false;

  Future<void> _claim() async {
    if (_busy) return;
    setState(() => _busy = true);
    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
    final ads = ref.read(adServiceProvider);
    await ads.showRewardedAd(
      onRewarded: () {
        ref.read(gameProvider.notifier).applyScoreDouble();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Score doubled! 🎉'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onUnavailable: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not ready. Try again in a moment.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _busy ? null : _claim,
      borderRadius: BorderRadius.circular(context.s(14)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: context.s(14)),
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(context.s(14)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_fill_rounded,
                color: Colors.black, size: context.s(22)),
            SizedBox(width: context.s(8)),
            Text(
              _busy ? 'LOADING…' : 'WATCH AD — DOUBLE SCORE',
              style: TextStyle(
                color: Colors.black,
                fontSize: context.s(14),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const _SecondaryButton({required this.text, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.s(12)),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.s(18), vertical: context.s(12)),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(context.s(12)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.text, size: context.s(16)),
              SizedBox(width: context.s(6)),
            ],
            Text(
              text,
              style: TextStyle(
                color: AppColors.text,
                fontSize: context.s(13),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
