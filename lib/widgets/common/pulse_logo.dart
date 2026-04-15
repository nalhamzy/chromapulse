import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class PulseLogo extends StatelessWidget {
  const PulseLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final titleSize = context.s(30);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GradientText(
              'CHROMA',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
              gradient: AppTheme.logoGradient1,
            ),
            _GradientText(
              'PULSE',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
              gradient: AppTheme.logoGradient2,
            ),
          ],
        ),
        SizedBox(height: context.s(4)),
        Text(
          'TRAIN YOUR COLOR VISION',
          style: AppTheme.mono(
            fontSize: context.s(11),
            color: AppColors.textDim,
            letterSpacing: 4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText(this.text, {required this.style, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => gradient.createShader(rect),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}
