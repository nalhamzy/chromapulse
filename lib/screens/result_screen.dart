import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/ad_provider.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/haptic_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/providers/share_provider.dart';
import 'package:chromapulse/widgets/common/share_card.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(audioServiceProvider).play(SoundEffect.gameOver);

      // Show toasts for any achievements unlocked by this run.
      final notifier = ref.read(playerProvider.notifier);
      final pending = notifier.pendingUnlocks;
      if (pending.isNotEmpty) {
        ref.read(hapticServiceProvider).celebrate();
        _showAchievementToasts(pending);
        notifier.clearPendingUnlocks();
      }
    });
  }

  void _showAchievementToasts(List<AchievementId> ids) async {
    for (final id in ids) {
      if (!mounted) return;
      final ach = Achievements.byId(id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            duration: const Duration(milliseconds: 2200),
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ach.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(ach.icon, color: ach.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ach.title,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      await Future<void>.delayed(const Duration(milliseconds: 2400));
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = ref.watch(gameProvider);
    final p = ref.watch(playerProvider);
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
      body: Stack(
        children: [
          SafeArea(
            child: ResponsiveContentBox(
              child: Column(
                children: [
                  _ResultHeader(
                    onBack: () {
                      ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
                      ref.read(screenProvider.notifier).go(AppScreen.menu);
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        context.s(24),
                        context.s(8),
                        context.s(24),
                        context.s(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      SizedBox(height: context.s(8)),
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
                            fontSize: context.s(72),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        'POINTS',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: context.s(11),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                        ),
                      ),
                      if (isNewBest) ...[
                        SizedBox(height: context.s(12)),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.s(16),
                              vertical: context.s(6)),
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
                      if (g.isDailyChallenge) ...[
                        SizedBox(height: context.s(10)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.s(14),
                            vertical: context.s(6),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent2.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.accent2.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.accent2,
                                size: 16,
                              ),
                              SizedBox(width: context.s(6)),
                              Text(
                                'DAILY · ${p.currentStreak} DAY${p.currentStreak == 1 ? '' : 'S'}',
                                style: TextStyle(
                                  color: AppColors.accent2,
                                  fontSize: context.s(11),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
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
                        padding:
                            EdgeInsets.symmetric(horizontal: context.s(16)),
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
                      if (_shouldShowDoubleScore(ref, g))
                        Padding(
                          padding: EdgeInsets.only(bottom: context.s(12)),
                          child: _DoubleScoreButton(),
                        ),
                      // Equal-prominence primary actions — paired so users
                      // see both "next" options at a glance.
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryAction(
                              icon: Icons.home_rounded,
                              label: 'MENU',
                              filled: false,
                              onTap: () {
                                ref
                                    .read(audioServiceProvider)
                                    .play(SoundEffect.buttonTap);
                                ref
                                    .read(screenProvider.notifier)
                                    .go(AppScreen.menu);
                              },
                            ),
                          ),
                          SizedBox(width: context.s(10)),
                          Expanded(
                            flex: 2,
                            child: _PrimaryAction(
                              icon: Icons.replay_rounded,
                              label: 'PLAY AGAIN',
                              filled: true,
                              onTap: () {
                                ref
                                    .read(audioServiceProvider)
                                    .play(SoundEffect.buttonTap);
                                ref
                                    .read(gameProvider.notifier)
                                    .startGame(g.mode);
                                ref
                                    .read(screenProvider.notifier)
                                    .go(AppScreen.game);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.s(12)),
                      _SecondaryButton(
                        text: 'Share Score',
                        icon: Icons.ios_share_rounded,
                        onTap: () => _share(g, p, isNewBest),
                      ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Off-screen share card. Positioned far off-canvas so the user
          // never sees it but Flutter still renders it for capture.
          Positioned(
            left: -20000,
            top: 0,
            child: RepaintBoundary(
              key: _shareCardKey,
              child: ShareCard(
                modeLabel: g.mode.label,
                score: g.score,
                correct: g.correct,
                totalRounds: g.totalRounds,
                maxCombo: g.maxCombo,
                streak: p.currentStreak,
                isNewBest: isNewBest,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share(dynamic g, dynamic p, bool isNewBest) async {
    ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
    final shareSvc = ref.read(shareServiceProvider);
    final fallback =
        'I scored ${g.score} on ${g.mode.label} in ChromaPulse${isNewBest ? " — new personal best!" : ""}';
    final ok = await shareSvc.shareResult(
      boundaryKey: _shareCardKey,
      fallbackText: fallback,
    );
    if (ok && mounted) {
      ref.read(playerProvider.notifier).recordShare();
      // If the Sharer achievement just unlocked, surface it.
      final pending = ref.read(playerProvider.notifier).pendingUnlocks;
      if (pending.isNotEmpty) {
        _showAchievementToasts(pending);
        ref.read(playerProvider.notifier).clearPendingUnlocks();
      }
    }
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

/// Top header with a clear ← Menu escape route. Without this users had no
/// familiar back affordance on the result screen.
class _ResultHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _ResultHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.s(8),
        context.s(8),
        context.s(16),
        0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.textDim),
            tooltip: 'Menu',
          ),
          SizedBox(width: context.s(4)),
          Text(
            'RESULTS',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: context.s(12),
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A clear, prominent action button used for the bottom Menu / Play Again
/// pair. Filled variant is the recommended next-step (typically Play Again);
/// outlined variant is the alternative (Menu).
class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.s(14)),
      child: Container(
        height: context.s(56),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: filled ? AppTheme.logoGradient1 : null,
          color: filled ? null : AppColors.surface2,
          borderRadius: BorderRadius.circular(context.s(14)),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? Colors.black : AppColors.text,
              size: context.s(20),
            ),
            SizedBox(width: context.s(8)),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.black : AppColors.text,
                fontSize: context.s(14),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
