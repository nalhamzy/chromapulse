import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class ResultStatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final double? valueFontSize;

  const ResultStatBlock({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = AppColors.text,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.mono(
            fontSize: context.s(valueFontSize ?? 22),
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: context.s(2)),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: context.s(10),
            color: AppColors.textDim,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
