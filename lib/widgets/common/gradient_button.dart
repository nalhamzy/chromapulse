import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? emoji;
  final double? width;
  final bool fullWidth;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.text,
    required this.gradient,
    required this.onPressed,
    this.textColor = Colors.white,
    this.icon,
    this.emoji,
    this.width,
    this.fullWidth = false,
    this.enabled = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.fullWidth
        ? double.infinity
        : (widget.width != null
            ? context.s(widget.width!)
            : context.s(260));
    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                HapticFeedback.lightImpact();
                widget.onPressed();
              }
            : null,
        onTapCancel:
            widget.enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: width,
            padding: EdgeInsets.symmetric(vertical: context.s(14)),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(context.s(12)),
              boxShadow: [
                BoxShadow(
                  color: (widget.gradient is LinearGradient
                          ? (widget.gradient as LinearGradient).colors.first
                          : Colors.black)
                      .withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: TextStyle(fontSize: context.s(18))),
                  SizedBox(width: context.s(8)),
                ],
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.textColor, size: context.s(20)),
                  SizedBox(width: context.s(8)),
                ],
                Text(
                  widget.text.toUpperCase(),
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: context.s(14),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
