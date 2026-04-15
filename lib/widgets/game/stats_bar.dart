import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/player_provider.dart';
import 'package:chromapulse/widgets/common/section_card.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

class StatsBar extends ConsumerWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(playerProvider);
    return SectionCard(
      padding: EdgeInsets.symmetric(horizontal: context.s(24), vertical: context.s(16)),
      child: Row(
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
            valueColor: AppColors.accent,
          ),
          ResultStatBlock(
            value: '${p.accuracyPct}%',
            label: 'Accuracy',
            valueColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
