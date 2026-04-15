import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Border? border;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(context.s(16)),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(context.s(16)),
        border: border ??
            Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1),
      ),
      child: child,
    );
  }
}
