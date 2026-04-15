import 'package:flutter/material.dart';

/// Responsive helpers for scaling the UI across phone and tablet.
///
/// Tablet = shortest side >= 600dp. On tablets we scale sizes up and
/// constrain content width so layouts don't look like a narrow phone
/// column centered in a huge empty canvas.
extension ResponsiveContext on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).shortestSide >= 600;

  /// Scale a size value: returns [v] on phones, [v * 1.55] on tablets.
  double s(double v) => isTablet ? v * 1.55 : v;

  /// Max content width used by ResponsiveContentBox on tablets.
  double get maxContentWidth => isTablet ? 680 : double.infinity;
}

/// Centers and constrains its child on tablets so full-width layouts
/// (ListViews, grids, columns) don't stretch absurdly wide on iPads.
class ResponsiveContentBox extends StatelessWidget {
  final Widget child;
  final double? tabletMaxWidth;

  const ResponsiveContentBox({
    super.key,
    required this.child,
    this.tabletMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isTablet) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tabletMaxWidth ?? 680),
        child: child,
      ),
    );
  }
}
