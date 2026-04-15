import 'package:flutter/material.dart';
import 'package:chromapulse/core/utils/responsive.dart';

class MemoryFlash extends StatelessWidget {
  final Color color;
  const MemoryFlash({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    // Compute contrasting label color from perceived luminance.
    final lum = color.computeLuminance();
    final labelColor = lum > 0.5 ? Colors.black : Colors.white;
    return Padding(
      padding: EdgeInsets.all(context.s(8)),
      child: Container(
        width: double.infinity,
        height: context.s(220),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(context.s(14)),
        ),
        alignment: Alignment.center,
        child: Text(
          'REMEMBER THIS COLOR',
          style: TextStyle(
            fontSize: context.s(14),
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
