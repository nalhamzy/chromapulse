import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';

/// 1080×1920 image card rendered off-screen for share-sheet capture.
class ShareCard extends StatelessWidget {
  final String modeLabel;
  final int score;
  final int correct;
  final int totalRounds;
  final int maxCombo;
  final int streak;
  final bool isNewBest;

  const ShareCard({
    super.key,
    required this.modeLabel,
    required this.score,
    required this.correct,
    required this.totalRounds,
    required this.maxCombo,
    required this.streak,
    required this.isNewBest,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      child: Container(
        width: 1080,
        height: 1920,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF14141C), Color(0xFF06060A)],
          ),
        ),
        padding: const EdgeInsets.all(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CHROMAPULSE',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 36,
                letterSpacing: 6,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              modeLabel.toUpperCase(),
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 56,
                letterSpacing: 4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            ShaderMask(
              shaderCallback: (rect) =>
                  AppTheme.logoGradient1.createShader(rect),
              blendMode: BlendMode.srcIn,
              child: Text(
                '$score',
                style: AppTheme.mono(
                  fontSize: 360,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'POINTS',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 36,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 60),
            if (isNewBest)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  '★ NEW BEST ★',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),
            const Spacer(),
            Row(
              children: [
                _ShareStat(
                  value: '$correct/$totalRounds',
                  label: 'Correct',
                  color: AppColors.accent,
                ),
                const SizedBox(width: 60),
                _ShareStat(
                  value: '×$maxCombo',
                  label: 'Max Combo',
                  color: AppColors.gold,
                ),
                if (streak > 0) ...[
                  const SizedBox(width: 60),
                  _ShareStat(
                    value: '🔥 $streak',
                    label: 'Streak',
                    color: AppColors.accent2,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 60),
            const Text(
              'Train your color vision',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ShareStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.mono(
            fontSize: 72,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textDim,
            fontSize: 22,
            letterSpacing: 4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
