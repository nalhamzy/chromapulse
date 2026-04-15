import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/game_provider.dart';

class TimerBar extends ConsumerWidget {
  const TimerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frac = ref.watch(gameProvider.select((g) => g.timeFraction));
    Color fill;
    if (frac < 0.2) {
      fill = AppColors.accent2;
    } else if (frac < 0.45) {
      fill = AppColors.gold;
    } else {
      fill = AppColors.accent;
    }
    return Container(
      height: context.s(6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
          width: MediaQuery.sizeOf(context).width * frac,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
