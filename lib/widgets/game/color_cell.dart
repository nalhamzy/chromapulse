import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/utils/responsive.dart';

enum ColorCellState { idle, correct, wrong, fadedReveal, fadedRevealTarget }

class ColorCell extends StatefulWidget {
  final Color color;
  final ColorCellState cellState;
  final VoidCallback? onTap;

  const ColorCell({
    super.key,
    required this.color,
    this.cellState = ColorCellState.idle,
    this.onTap,
  });

  @override
  State<ColorCell> createState() => _ColorCellState();
}

class _ColorCellState extends State<ColorCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (widget.cellState) {
      ColorCellState.correct => AppColors.accent,
      ColorCellState.wrong => AppColors.accent2,
      ColorCellState.fadedRevealTarget => AppColors.accent,
      _ => Colors.transparent,
    };
    final showGlow = widget.cellState == ColorCellState.correct;
    final opacity = switch (widget.cellState) {
      ColorCellState.fadedReveal => 0.3,
      _ => 1.0,
    };
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(context.s(14)),
            border: Border.all(color: borderColor, width: 3),
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.45),
                      blurRadius: 24,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
