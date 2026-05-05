import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/widgets/game/color_cell.dart';

/// VIP "Palette Match" — top strip shows 4 target swatches; bottom 3×3 grid
/// is the noise pool. Player taps tiles whose color is in the target palette.
/// Already-found targets are dimmed in the strip; correct picks are
/// highlighted in the grid; wrong pick instantly fails the round.
class PaletteMatchArea extends ConsumerWidget {
  const PaletteMatchArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final resolved = g.phase == GamePhase.resolved;

    // Compute which target swatches have already been matched.
    final foundColors = <Color>{};
    for (final i in g.palettePicks) {
      if (i >= 0 && i < g.cells.length) foundColors.add(g.cells[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.s(8),
            vertical: context.s(6),
          ),
          child: Text(
            'TARGET PALETTE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: context.s(10),
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: context.s(54),
          child: Row(
            children: [
              for (final t in g.paletteTargets) ...[
                Expanded(child: _TargetSwatch(color: t, found: foundColors.contains(t))),
                SizedBox(width: context.s(8)),
              ],
            ]..removeLast(),
          ),
        ),
        SizedBox(height: context.s(12)),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(vertical: context.s(4)),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: g.cells.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: g.gridColumns,
              childAspectRatio: 1,
              mainAxisSpacing: context.s(10),
              crossAxisSpacing: context.s(10),
            ),
            itemBuilder: (context, i) {
              final isPicked = g.palettePicks.contains(i);
              final isWrong = resolved &&
                  g.pickedIndex == i &&
                  !isPicked; // last pick that triggered fail
              ColorCellState state;
              if (isPicked) {
                state = ColorCellState.correct;
              } else if (isWrong) {
                state = ColorCellState.wrong;
              } else if (resolved) {
                state = ColorCellState.fadedReveal;
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
          ),
        ),
      ],
    );
  }
}

class _TargetSwatch extends StatelessWidget {
  final Color color;
  final bool found;
  const _TargetSwatch({required this.color, required this.found});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: color.withValues(alpha: found ? 0.35 : 1.0),
        borderRadius: BorderRadius.circular(context.s(10)),
        border: Border.all(
          color: found ? AppColors.accent : Colors.white.withValues(alpha: 0.05),
          width: found ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: found
          ? Icon(Icons.check_rounded,
              color: Colors.white, size: context.s(20))
          : null,
    );
  }
}
