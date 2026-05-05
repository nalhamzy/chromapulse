import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/models/achievement.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(playerProvider).unlockedAchievements;
    final all = Achievements.all;
    final unlockedCount = unlocked.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ResponsiveContentBox(
          child: Column(
            children: [
              _Header(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.s(16)),
                child: _Progress(
                  current: unlockedCount,
                  total: all.length,
                ),
              ),
              SizedBox(height: context.s(12)),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.s(12),
                    vertical: context.s(4),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isTablet ? 4 : 3,
                    crossAxisSpacing: context.s(10),
                    mainAxisSpacing: context.s(10),
                    childAspectRatio: 0.85,
                  ),
                  itemCount: all.length,
                  itemBuilder: (ctx, i) {
                    final a = all[i];
                    final isUnlocked = unlocked.contains(a.id.key);
                    return _BadgeTile(achievement: a, unlocked: isUnlocked);
                  },
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
              'ACHIEVEMENTS',
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

class _Progress extends StatelessWidget {
  final int current;
  final int total;
  const _Progress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.s(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: context.s(11),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$current / $total',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: context.s(13),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.s(6)),
        ClipRRect(
          borderRadius: BorderRadius.circular(context.s(6)),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.surface2,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.gold),
            minHeight: context.s(8),
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  const _BadgeTile({required this.achievement, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final c = unlocked ? achievement.color : AppColors.textDim;
    return Tooltip(
      message: '${achievement.title}\n${achievement.description}',
      child: Container(
        padding: EdgeInsets.all(context.s(10)),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(context.s(14)),
          border: Border.all(
            color: unlocked
                ? c.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.04),
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: c.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: context.s(46),
              height: context.s(46),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: unlocked
                    ? c.withValues(alpha: 0.16)
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(context.s(12)),
              ),
              child: Icon(
                unlocked ? achievement.icon : Icons.lock_outline_rounded,
                size: context.s(22),
                color: c,
              ),
            ),
            SizedBox(height: context.s(8)),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? AppColors.text : AppColors.textDim,
                fontSize: context.s(11),
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            SizedBox(height: context.s(2)),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: context.s(9),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
