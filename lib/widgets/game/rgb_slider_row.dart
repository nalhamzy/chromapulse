import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class RgbSliderRow extends StatelessWidget {
  final String label;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  const RgbSliderRow({
    super.key,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: context.s(20),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.mono(
              fontSize: context.s(13),
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: context.s(8)),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.surface2,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              trackHeight: 8,
            ),
            child: Slider(
              min: 0,
              max: 255,
              value: value.toDouble(),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ),
        SizedBox(
          width: context.s(36),
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: AppTheme.mono(
              fontSize: context.s(12),
              color: AppColors.textDim,
            ),
          ),
        ),
      ],
    );
  }
}
