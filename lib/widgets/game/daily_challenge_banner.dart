import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/services/audio_service.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/audio_provider.dart';
import 'package:chromapulse/providers/daily_challenge_provider.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/providers/haptic_provider.dart';
import 'package:chromapulse/providers/navigation_provider.dart';
import 'package:chromapulse/providers/player_provider.dart';

/// Top-of-menu banner that promotes today's Daily Challenge and shows the
/// player's current streak. Tapping starts the challenge with a deterministic
/// seed so every player worldwide gets the same layout for that day.
class DailyChallengeBanner extends ConsumerWidget {
  const DailyChallengeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(todayChallengeProvider);
    final player = ref.watch(playerProvider);
    final completed = challenge.completed;

    final gradient = completed
        ? const LinearGradient(
            colors: [AppColors.surface2, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : AppTheme.goldGradient;

    return InkWell(
      onTap: () {
        ref.read(audioServiceProvider).play(SoundEffect.buttonTap);
        ref.read(hapticServiceProvider).light();
        ref.read(gameProvider.notifier).startGame(
              challenge.mode,
              dailySeed: challenge.seed,
            );
        ref.read(screenProvider.notifier).go(AppScreen.game);
      },
      borderRadius: BorderRadius.circular(context.s(16)),
      child: Container(
        padding: EdgeInsets.all(context.s(16)),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(context.s(16)),
          border: Border.all(
            color: completed
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.gold.withValues(alpha: 0.4),
          ),
          boxShadow: completed
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: context.s(46),
              height: context.s(46),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: completed ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(context.s(12)),
              ),
              alignment: Alignment.center,
              child: Icon(
                completed
                    ? Icons.check_rounded
                    : Icons.local_fire_department_rounded,
                color: completed ? AppColors.accent : Colors.black,
                size: context.s(24),
              ),
            ),
            SizedBox(width: context.s(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'DAILY CHALLENGE',
                        style: TextStyle(
                          color: completed ? AppColors.textDim : Colors.black87,
                          fontSize: context.s(11),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: context.s(8)),
                      if (player.currentStreak > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.s(8),
                            vertical: context.s(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(context.s(8)),
                          ),
                          child: Text(
                            '🔥 ${player.currentStreak}',
                            style: AppTheme.mono(
                              fontSize: context.s(11),
                              color: completed
                                  ? AppColors.gold
                                  : Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.s(2)),
                  Text(
                    completed
                        ? 'Done — back tomorrow'
                        : 'Today: ${challenge.mode.label}',
                    style: TextStyle(
                      color: completed
                          ? AppColors.text
                          : Colors.black,
                      fontSize: context.s(15),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.s(8)),
            Icon(
              completed
                  ? Icons.chevron_right_rounded
                  : Icons.play_arrow_rounded,
              color: completed ? AppColors.textDim : Colors.black,
              size: context.s(28),
            ),
          ],
        ),
      ),
    );
  }
}
