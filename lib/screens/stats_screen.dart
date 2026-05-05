import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/models/player_stats.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/section_card.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.s(16),
                    context.s(8),
                    context.s(16),
                    context.s(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OverviewCard(p),
                      SizedBox(height: context.s(16)),
                      _SectionTitle('Per-mode'),
                      SizedBox(height: context.s(8)),
                      for (final m in GameMode.values) ...[
                        _ModeCard(player: p, mode: m),
                        SizedBox(height: context.s(10)),
                      ],
                      SizedBox(height: context.s(16)),
                      _AchievementsTeaser(player: p),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.s(8),
        context.s(8),
        context.s(16),
        context.s(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
              ref.read(screenProvider.notifier).go(AppScreen.menu);
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.textDim),
          ),
          Expanded(
            child: Text(
              'STATS',
              style: TextStyle(
                color: AppColors.text,
                fontSize: context.s(18),
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.s(4), bottom: context.s(4)),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: AppColors.textDim,
          fontSize: context.s(12),
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final PlayerStats p;
  const _OverviewCard(this.p);

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.symmetric(
        horizontal: context.s(20),
        vertical: context.s(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ResultStatBlock(
                value: '${p.totalGames}',
                label: 'Games',
                valueColor: AppColors.accent,
              ),
              ResultStatBlock(
                value: '${p.totalScore}',
                label: 'Total Pts',
                valueColor: AppColors.accent3,
              ),
              ResultStatBlock(
                value: '${p.accuracyPct}%',
                label: 'Accuracy',
                valueColor: AppColors.gold,
              ),
            ],
          ),
          SizedBox(height: context.s(16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.s(14),
              vertical: context.s(10),
            ),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(context.s(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.accent2, size: 20),
                SizedBox(width: context.s(8)),
                Expanded(
                  child: Text(
                    'Daily streak',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: context.s(13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${p.currentStreak}',
                  style: AppTheme.mono(
                    fontSize: context.s(18),
                    color: AppColors.accent2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: context.s(6)),
                Text(
                  'best ${p.longestStreak}',
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: context.s(11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final PlayerStats player;
  final GameMode mode;

  const _ModeCard({required this.player, required this.mode});

  @override
  Widget build(BuildContext context) {
    final best = player.bestFor(mode.id);
    final history = player.recentScoresByMode[mode.id] ?? const <int>[];
    final games = history.length;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.s(34),
                height: context.s(34),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mode.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.s(8)),
                ),
                child: Text(
                  mode.iconGlyph,
                  style: TextStyle(
                    fontSize: context.s(18),
                    color: mode.accent,
                  ),
                ),
              ),
              SizedBox(width: context.s(10)),
              Expanded(
                child: Text(
                  mode.label,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: context.s(14),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'BEST',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: context.s(10),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: context.s(6)),
              Text(
                '$best',
                style: AppTheme.mono(
                  fontSize: context.s(14),
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: context.s(12)),
          if (history.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.s(8)),
              child: Text(
                'No games yet — give it a try.',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: context.s(12),
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  height: context.s(34),
                  width: context.s(120),
                  child: _Sparkline(values: history.reversed.toList()),
                ),
                SizedBox(width: context.s(12)),
                Expanded(
                  child: Text(
                    '$games game${games == 1 ? '' : 's'} • last ${history.first}',
                    style: AppTheme.mono(
                      fontSize: context.s(11),
                      color: AppColors.textDim,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<int> values;
  const _Sparkline({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minV = values.reduce((a, b) => a < b ? a : b).toDouble();
    final span = (maxV - minV) <= 0 ? 1.0 : (maxV - minV);

    final n = values.length;
    final dx = n == 1 ? 0.0 : size.width / (n - 1);
    final path = Path();
    for (var i = 0; i < n; i++) {
      final x = i * dx;
      final v = values[i].toDouble();
      final y = size.height - ((v - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);

    // Last-point dot.
    final lastX = (n - 1) * dx;
    final lastV = values.last.toDouble();
    final lastY = size.height - ((lastV - minV) / span) * size.height;
    canvas.drawCircle(
      Offset(lastX, lastY),
      3,
      Paint()..color = AppColors.gold,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}

class _AchievementsTeaser extends ConsumerWidget {
  final PlayerStats player;
  const _AchievementsTeaser({required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedCount = player.unlockedAchievements.length;
    final total = AchievementId.values.length;
    return InkWell(
      borderRadius: BorderRadius.circular(context.s(16)),
      onTap: () {
        ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
        ref.read(screenProvider.notifier).go(AppScreen.achievements);
      },
      child: SectionCard(
        child: Row(
          children: [
            Container(
              width: context.s(40),
              height: context.s(40),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.s(10)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.emoji_events_rounded,
                  color: AppColors.gold),
            ),
            SizedBox(width: context.s(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: context.s(15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.s(2)),
                  Text(
                    '$unlockedCount / $total unlocked',
                    style: TextStyle(
                      color: AppColors.textDim,
                      fontSize: context.s(12),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }
}
