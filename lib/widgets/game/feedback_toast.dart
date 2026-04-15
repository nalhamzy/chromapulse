import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/models/feedback_kind.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class FeedbackToast extends StatefulWidget {
  final int signal;
  final FeedbackKind? kind;

  const FeedbackToast({super.key, required this.signal, required this.kind});

  @override
  State<FeedbackToast> createState() => _FeedbackToastState();
}

class _FeedbackToastState extends State<FeedbackToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 70),
    ]).animate(_ctrl);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant FeedbackToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signal != oldWidget.signal && widget.kind != null) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _colorFor(FeedbackKind k) {
    if (k == FeedbackKind.perfect || k == FeedbackKind.great ||
        k == FeedbackKind.blazing) {
      return AppColors.gold;
    }
    if (k.isPositive) return AppColors.accent;
    return AppColors.accent2;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.kind == null) return const SizedBox.shrink();
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.kind!.label,
                style: TextStyle(
                  fontSize: context.s(48),
                  fontWeight: FontWeight.w900,
                  color: _colorFor(widget.kind!),
                  letterSpacing: -1,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
