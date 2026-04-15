import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/widgets/common/section_card.dart';
import 'package:chromapulse/widgets/game/result_stat_block.dart';

class GameInfoBar extends ConsumerWidget {
  const GameInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    return SectionCard(
      padding: EdgeInsets.symmetric(horizontal: context.s(18), vertical: context.s(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResultStatBlock(
            value: '${g.score}',
            label: 'Score',
            valueColor: AppColors.accent,
            valueFontSize: 20,
          ),
          ResultStatBlock(
            value: '${g.round}/${g.totalRounds}',
            label: 'Round',
            valueColor: AppColors.text,
            valueFontSize: 20,
          ),
          ResultStatBlock(
            value: g.combo > 1 ? '×${g.combo}' : '×1',
            label: 'Combo',
            valueColor: AppColors.gold,
            valueFontSize: 20,
          ),
        ],
      ),
    );
  }
}
