import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/models/game_mode.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class ModeCard extends StatefulWidget {
  final GameMode mode;
  final int bestScore;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.bestScore,
    required this.onTap,
  });

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.mode.accent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: EdgeInsets.all(context.s(20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                Color.lerp(AppColors.surface, accent, 0.04)!,
              ],
            ),
            borderRadius: BorderRadius.circular(context.s(16)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: context.s(40),
                    height: context.s(40),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(context.s(10)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.mode.iconGlyph,
                      style: TextStyle(
                        fontSize: context.s(20),
                        color: accent,
                      ),
                    ),
                  ),
                  SizedBox(width: context.s(12)),
                  Text(
                    widget.mode.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: context.s(16),
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.s(8)),
              Text(
                widget.mode.description,
                style: TextStyle(
                  fontSize: context.s(13),
                  color: AppColors.textDim,
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.s(10)),
              Row(
                children: [
                  Text(
                    'BEST: ',
                    style: AppTheme.mono(
                      fontSize: context.s(11),
                      color: AppColors.textDim,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${widget.bestScore}',
                    style: AppTheme.mono(
                      fontSize: context.s(13),
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
