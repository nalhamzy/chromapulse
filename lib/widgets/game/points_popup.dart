import 'package:flutter/material.dart';
import 'package:chromapulse/core/constants/app_colors.dart';
import 'package:chromapulse/core/constants/theme.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class PointsPopup extends StatefulWidget {
  final int signal;
  final int points;

  const PointsPopup({super.key, required this.signal, required this.points});

  @override
  State<PointsPopup> createState() => _PointsPopupState();
}

class _PointsPopupState extends State<PointsPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_ctrl);
    _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.6))
        .animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant PointsPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signal != oldWidget.signal && widget.points > 0) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.25),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => Opacity(
            opacity: _opacity.value,
            child: FractionalTranslation(
              translation: _offset.value,
              child: Text(
                '+${widget.points}',
                style: AppTheme.mono(
                  fontSize: context.s(26),
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
