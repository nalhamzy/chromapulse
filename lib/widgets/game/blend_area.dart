import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/game_state.dart';
import 'package:chromapulse/core/utils/responsive.dart';
import 'package:chromapulse/providers/game_provider.dart';
import 'package:chromapulse/widgets/common/gradient_button.dart';
import 'package:chromapulse/widgets/game/rgb_slider_row.dart';

class BlendArea extends ConsumerWidget {
  const BlendArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final picked = Color.fromARGB(255, g.blendR, g.blendG, g.blendB);
    final target = g.blendTarget ?? Colors.transparent;
    final canSubmit = g.phase == GamePhase.playing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Swatch(color: target),
            SizedBox(width: context.s(16)),
            Text('→',
                style: TextStyle(
                    color: AppColors.textDim, fontSize: context.s(24))),
            SizedBox(width: context.s(16)),
            _Swatch(color: picked, dashed: g.phase != GamePhase.resolved),
          ],
        ),
        if (g.lastAccuracyPct != null) ...[
          SizedBox(height: context.s(12)),
          Text(
            'Accuracy: ${g.lastAccuracyPct}%',
            style: AppTheme.mono(
              fontSize: context.s(14),
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        SizedBox(height: context.s(20)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.s(8)),
          child: Column(
            children: [
              RgbSliderRow(
                label: 'R',
                color: AppColors.sliderR,
                value: g.blendR,
                onChanged: canSubmit ? (v) => notifier.updateBlend(r: v) : (_) {},
              ),
              SizedBox(height: context.s(8)),
              RgbSliderRow(
                label: 'G',
                color: AppColors.sliderG,
                value: g.blendG,
                onChanged: canSubmit ? (v) => notifier.updateBlend(g: v) : (_) {},
              ),
              SizedBox(height: context.s(8)),
              RgbSliderRow(
                label: 'B',
                color: AppColors.sliderB,
                value: g.blendB,
                onChanged: canSubmit ? (v) => notifier.updateBlend(b: v) : (_) {},
              ),
            ],
          ),
        ),
        SizedBox(height: context.s(20)),
        GradientButton(
          text: 'Lock In Color',
          width: 220,
          gradient: AppTheme.logoGradient1,
          textColor: Colors.black,
          enabled: canSubmit,
          onPressed: notifier.submitBlend,
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool dashed;
  const _Swatch({required this.color, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    final size = context.s(80);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context.s(14)),
        border: Border.all(
          color: Colors.white.withValues(alpha: dashed ? 0.15 : 0.08),
          width: dashed ? 3 : 2,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}
