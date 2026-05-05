import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';

/// Stable identifier strings for achievements. Persisted in [PlayerStats]
/// so renaming an enum entry would break existing saves — only add to the
/// end and never reuse retired IDs.
enum AchievementId {
  // Onboarding
  firstPulse('first_pulse'),
  curiousEye('curious_eye'),
  perfectionist('perfectionist'),

  // Skill (per mode)
  sharpShade('sharp_shade'),
  hueHunter('hue_hunter'),
  memoryMaster('memory_master'),
  trueMixer('true_mixer'),
  comboKing('combo_king'),

  // Habit
  dailyDose('daily_dose'),
  weekStreak('week_streak'),
  monthStreak('month_streak'),
  centurion('centurion'),
  chromatic('chromatic'),

  // Premium / Social
  vipVision('vip_vision'),
  palettePro('palette_pro'),
  sharer('sharer'),
  generous('generous'),
  allStar('all_star');

  final String key;
  const AchievementId(this.key);

  static AchievementId? fromKey(String key) {
    for (final a in values) {
      if (a.key == key) return a;
    }
    return null;
  }
}

/// Static metadata for a single achievement.
@immutable
class Achievement {
  final AchievementId id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementTier tier;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tier,
  });
}

enum AchievementTier { onboarding, skill, habit, premium }

/// Catalog of all achievements. Order here is the display order on the
/// Achievements screen.
class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    // Onboarding
    Achievement(
      id: AchievementId.firstPulse,
      title: 'First Pulse',
      description: 'Play your first game.',
      icon: Icons.play_circle_filled_rounded,
      color: AppColors.accent,
      tier: AchievementTier.onboarding,
    ),
    Achievement(
      id: AchievementId.curiousEye,
      title: 'Curious Eye',
      description: 'Try every game mode at least once.',
      icon: Icons.visibility_rounded,
      color: AppColors.accent,
      tier: AchievementTier.onboarding,
    ),
    Achievement(
      id: AchievementId.perfectionist,
      title: 'Perfectionist',
      description: 'Score 100% in any mode.',
      icon: Icons.star_rounded,
      color: AppColors.gold,
      tier: AchievementTier.onboarding,
    ),

    // Skill
    Achievement(
      id: AchievementId.sharpShade,
      title: 'Sharp Shade',
      description: 'Score 1500+ in Shade Hunter.',
      icon: Icons.invert_colors_rounded,
      color: AppColors.accent,
      tier: AchievementTier.skill,
    ),
    Achievement(
      id: AchievementId.hueHunter,
      title: 'Hue Hunter',
      description: 'Score 1500+ in Odd Chroma.',
      icon: Icons.gps_fixed_rounded,
      color: AppColors.accent3,
      tier: AchievementTier.skill,
    ),
    Achievement(
      id: AchievementId.memoryMaster,
      title: 'Memory Master',
      description: 'Score 1500+ in Chroma Recall.',
      icon: Icons.psychology_rounded,
      color: AppColors.accent2,
      tier: AchievementTier.skill,
    ),
    Achievement(
      id: AchievementId.trueMixer,
      title: 'True Mixer',
      description: 'Score 800+ in Color Alchemist.',
      icon: Icons.tune_rounded,
      color: AppColors.gold,
      tier: AchievementTier.skill,
    ),
    Achievement(
      id: AchievementId.comboKing,
      title: 'Combo King',
      description: 'Hit a 10× combo streak in any mode.',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.accent2,
      tier: AchievementTier.skill,
    ),

    // Habit
    Achievement(
      id: AchievementId.dailyDose,
      title: 'Daily Dose',
      description: 'Complete your first Daily Challenge.',
      icon: Icons.today_rounded,
      color: AppColors.accent,
      tier: AchievementTier.habit,
    ),
    Achievement(
      id: AchievementId.weekStreak,
      title: 'Week Streak',
      description: 'Keep a Daily Challenge streak alive for 7 days.',
      icon: Icons.whatshot_rounded,
      color: AppColors.accent2,
      tier: AchievementTier.habit,
    ),
    Achievement(
      id: AchievementId.monthStreak,
      title: 'Month Streak',
      description: 'Keep a streak alive for 30 days.',
      icon: Icons.emoji_events_rounded,
      color: AppColors.gold,
      tier: AchievementTier.habit,
    ),
    Achievement(
      id: AchievementId.centurion,
      title: 'Centurion',
      description: 'Play 100 games.',
      icon: Icons.military_tech_rounded,
      color: AppColors.silver,
      tier: AchievementTier.habit,
    ),
    Achievement(
      id: AchievementId.chromatic,
      title: 'Chromatic',
      description: 'Earn 10,000 lifetime points.',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.accent3,
      tier: AchievementTier.habit,
    ),

    // Premium / Social
    Achievement(
      id: AchievementId.vipVision,
      title: 'VIP Vision',
      description: 'Unlock the VIP Pass.',
      icon: Icons.workspace_premium_rounded,
      color: AppColors.gold,
      tier: AchievementTier.premium,
    ),
    Achievement(
      id: AchievementId.palettePro,
      title: 'Palette Pro',
      description: 'Score 600+ in Palette Match (VIP).',
      icon: Icons.palette_rounded,
      color: AppColors.gold,
      tier: AchievementTier.premium,
    ),
    Achievement(
      id: AchievementId.sharer,
      title: 'Sharer',
      description: 'Share a result with friends.',
      icon: Icons.ios_share_rounded,
      color: AppColors.accent3,
      tier: AchievementTier.premium,
    ),
    Achievement(
      id: AchievementId.generous,
      title: 'Generous',
      description: 'Watch 5 rewarded ads.',
      icon: Icons.favorite_rounded,
      color: AppColors.accent2,
      tier: AchievementTier.premium,
    ),
    Achievement(
      id: AchievementId.allStar,
      title: 'All-Star',
      description: 'Unlock every other achievement.',
      icon: Icons.auto_awesome_motion_rounded,
      color: AppColors.gold,
      tier: AchievementTier.premium,
    ),
  ];

  static Achievement byId(AchievementId id) =>
      all.firstWhere((a) => a.id == id);
}
