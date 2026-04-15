import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/widgets/game/color_cell.dart';

class ColorGrid extends ConsumerWidget {
  const ColorGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final resolved = g.phase == GamePhase.resolved;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: context.s(8)),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: g.cells.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: g.gridColumns,
        childAspectRatio: 1,
        mainAxisSpacing: context.s(10),
        crossAxisSpacing: context.s(10),
      ),
      itemBuilder: (context, i) {
        ColorCellState state;
        if (g.revealedTargetIndex != null) {
          if (i == g.targetIndex) {
            state = ColorCellState.fadedRevealTarget;
          } else if (i == g.pickedIndex) {
            state = ColorCellState.wrong;
          } else {
            state = ColorCellState.fadedReveal;
          }
        } else if (g.pickedIndex == i && resolved) {
          state = ColorCellState.correct;
        } else {
          state = ColorCellState.idle;
        }
        return ColorCell(
          color: g.cells[i],
          cellState: state,
          onTap: g.phase == GamePhase.playing
              ? () => notifier.handlePick(i)
              : null,
        );
      },
    );
  }
}
