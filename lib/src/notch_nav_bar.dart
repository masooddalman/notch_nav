import 'dart:math' show atan2, pi, sqrt;

import 'package:flutter/material.dart';

import 'notch_nav_item.dart';

/// Shape of the active item indicator in [NotchNav].
enum NotchNavShape {
  /// A circle (default).
  circle,

  /// A rounded square.
  square,

  /// A diamond (45° rotated square).
  diamond,
}

/// Controls which item labels are visible in [NotchNav].
enum NotchNavLabelBehavior {
  /// Only the selected item shows its label.
  selectedOnly,

  /// No labels are shown.
  none,
}

/// A bottom navigation bar with a notch-style pop-up effect on the active item.
///
/// The selected item's icon rises above the bar inside a colored circle,
/// and its label appears below the icon.
///
/// {@tool snippet}
/// ```dart
/// NotchNav(
///   items: const [
///     NotchNavItem(icon: Icons.home, label: 'Home'),
///     NotchNavItem(icon: Icons.search, label: 'Search'),
///     NotchNavItem(icon: Icons.person, label: 'Profile'),
///   ],
///   currentIndex: _selectedIndex,
///   onTap: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
/// {@end-tool}
class NotchNav extends StatelessWidget {
  /// The navigation items to display. Must contain at least 2 items.
  final List<NotchNavItem> items;

  /// Index of the currently selected item.
  final int currentIndex;

  /// Called when a navigation item is tapped.
  final ValueChanged<int> onTap;

  /// Background color of the bar. Defaults to [Colors.white].
  /// Ignored when [backgroundGradient] is provided.
  final Color backgroundColor;

  /// Optional gradient for the bar background. Takes precedence over [backgroundColor].
  final Gradient? backgroundGradient;

  /// Color of the selected item's circle.
  /// Ignored when [activeGradient] is provided.
  final Color activeColor;

  /// Optional gradient for the active indicator. Takes precedence over [activeColor].
  final Gradient? activeGradient;

  /// Icon color of the selected item.
  final Color activeIconColor;

  /// Icon color of unselected items.
  final Color inactiveIconColor;

  /// Label text color.
  final Color labelColor;

  /// Label text style. Overrides [labelColor] and [labelFontSize].
  final TextStyle? labelStyle;

  /// Height of the bar.
  final double barHeight;

  /// Corner radius of the bar.
  final double barBorderRadius;

  /// Diameter of the selected item's circle.
  final double circleSize;

  /// Size of the navigation icons.
  final double iconSize;

  /// Font size of the label text.
  final double labelFontSize;

  /// How far the circle rises above the bar. Defaults to `circleSize / 2`.
  final double? circleOffset;

  /// Outer margin around the widget.
  final EdgeInsets margin;

  /// Horizontal padding inside the bar.
  final double horizontalPadding;

  /// Box shadows for the bar.
  final List<BoxShadow>? barShadow;

  /// Box shadows for the active circle.
  final List<BoxShadow>? circleShadow;

  /// Duration of the selection animation.
  final Duration animationDuration;

  /// Curve of the selection animation.
  final Curve animationCurve;

  /// Controls which labels are shown. Defaults to [NotchNavLabelBehavior.selectedOnly].
  final NotchNavLabelBehavior labelBehavior;

  /// Whether the selected item's label shifts up to align with unselected items' icons.
  final bool alignSelectedLabel;

  /// Shape of the active item indicator. Defaults to [NotchNavShape.circle].
  final NotchNavShape shape;

  /// Gap between the active circle and the notch edge in the bar.
  final double notchMargin;

  /// Corner radius of the notch where it meets the bar edge.
  /// Defaults to [notchMargin].
  final double notchCornerRadius;

  /// Creates a [NotchNav] widget.
  const NotchNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.backgroundGradient,
    this.activeColor = const Color(0xFF6C63FF),
    this.activeGradient,
    this.activeIconColor = Colors.white,
    this.inactiveIconColor = const Color(0xFF9E9E9E),
    this.labelColor = const Color(0xFF424242),
    this.labelStyle,
    this.barHeight = 96,
    this.barBorderRadius = 16,
    this.circleSize = 52,
    this.iconSize = 26,
    this.labelFontSize = 12,
    this.circleOffset,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.horizontalPadding = 16,
    this.barShadow,
    this.circleShadow,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCirc,
    this.labelBehavior = NotchNavLabelBehavior.selectedOnly,
    this.alignSelectedLabel = true,
    this.shape = NotchNavShape.circle,
    this.notchMargin = 6,
    this.notchCornerRadius = 6,
  }) : assert(items.length >= 2, 'NotchNav requires at least 2 items'),
       assert(currentIndex >= 0, 'currentIndex must be non-negative'),
       assert(
         currentIndex < items.length,
         'currentIndex must be less than items.length',
       );

  double get _circleOffset => circleOffset ?? circleSize / 2;

  bool _showLabel(bool isSelected) {
    return switch (labelBehavior) {
      NotchNavLabelBehavior.selectedOnly => isSelected,
      NotchNavLabelBehavior.none => false,
    };
  }

  TextStyle get _labelStyle =>
      labelStyle ??
      TextStyle(
        color: labelColor,
        fontSize: labelFontSize,
        fontWeight: FontWeight.w600,
      );

  @override
  Widget build(BuildContext context) {
    final circleTop = _circleOffset - circleSize / 2;

    return Padding(
      padding: margin,
      child: SizedBox(
        height: barHeight + _circleOffset,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth - 2 * horizontalPadding;
            final itemWidth = contentWidth / items.length;
            final circleLeft =
                horizontalPadding +
                currentIndex * itemWidth +
                (itemWidth - circleSize) / 2;
            final circleCenterX = circleLeft + circleSize / 2;

            return Stack(
              children: [
                // Bar background with notch cutout
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: barHeight,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: circleCenterX),
                    duration: animationDuration,
                    curve: animationCurve,
                    builder: (context, notchX, _) {
                      return CustomPaint(
                        painter: _NotchBarPainter(
                          notchCenterX: notchX,
                          notchRadius: circleSize / 2 + notchMargin,
                          filletRadius: notchCornerRadius,
                          backgroundColor: backgroundColor,
                          backgroundGradient: backgroundGradient,
                          borderRadius: barBorderRadius,
                          shape: shape,
                          shadows:
                              barShadow ??
                              const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                        ),
                      );
                    },
                  ),
                ),
                // Sliding indicator (always at top, moves horizontally)
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: animationCurve,
                  top: circleTop,
                  left: circleLeft,
                  width: circleSize,
                  height: circleSize,
                  child: _buildIndicator(),
                ),
                // Navigation item icons
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: List.generate(items.length, _buildNavItem),
                  ),
                ),
                // Labels (single shared row for perfect alignment)
                if (labelBehavior != NotchNavLabelBehavior.none)
                  Positioned(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 8,
                    child: Row(
                      children: List.generate(items.length, _buildLabel),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final isSelected = index == currentIndex;

    // Icon positions
    final selectedIconTop =
        (_circleOffset - circleSize / 2) + (circleSize - iconSize) / 2;
    final unselectedIconTop = _circleOffset + (barHeight - iconSize) / 2;

    return Expanded(
      child: Semantics(
        label: item.label,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox.expand(),
              // Icon (animates vertically)
              AnimatedPositioned(
                duration: animationDuration,
                curve: animationCurve,
                top: isSelected ? selectedIconTop : unselectedIconTop,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      begin: isSelected ? activeIconColor : inactiveIconColor,
                      end: isSelected ? activeIconColor : inactiveIconColor,
                    ),
                    duration: animationDuration,
                    curve: animationCurve,
                    builder: (context, color, _) =>
                        Icon(item.icon, size: iconSize, color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(int index) {
    final isSelected = index == currentIndex;

    // Shift selected label up to align with unselected icons' center
    double yOffset = 0;
    if (alignSelectedLabel && isSelected) {
      final iconCenterY = _circleOffset + barHeight / 2;
      final widgetHeight = barHeight + _circleOffset;
      final labelCenterY = widgetHeight - 8 - labelFontSize / 2;
      yOffset = iconCenterY - labelCenterY;
    }

    return Expanded(
      child: Center(
        child: AnimatedOpacity(
          duration: animationDuration,
          opacity: _showLabel(isSelected) ? 1.0 : 0.0,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: animationCurve,
            transform: Matrix4.translationValues(0, yOffset, 0),
            child: Text(
              items[index].label,
              style: _labelStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    final shadow =
        circleShadow ??
        [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

    switch (shape) {
      case NotchNavShape.circle:
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: activeGradient,
            color: activeGradient == null ? activeColor : null,
            boxShadow: shadow,
          ),
        );
      case NotchNavShape.square:
        final cornerRadius = notchCornerRadius;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cornerRadius),
            gradient: activeGradient,
            color: activeGradient == null ? activeColor : null,
            boxShadow: shadow,
          ),
        );
      case NotchNavShape.diamond:
        final cornerRadius = notchCornerRadius;
        // Shrink by 1/sqrt(2) so the rotated square fits within circleSize
        final diamondSize = circleSize / sqrt(2);
        return Center(
          child: Transform.rotate(
            angle: pi / 4,
            child: SizedBox(
              width: diamondSize,
              height: diamondSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  gradient: activeGradient,
                  color: activeGradient == null ? activeColor : null,
                  boxShadow: shadow,
                ),
              ),
            ),
          ),
        );
    }
  }
}

class _NotchBarPainter extends CustomPainter {
  final double notchCenterX;
  final double notchRadius;
  final double filletRadius;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final double borderRadius;
  final List<BoxShadow> shadows;
  final NotchNavShape shape;

  const _NotchBarPainter({
    required this.notchCenterX,
    required this.notchRadius,
    required this.filletRadius,
    required this.backgroundColor,
    this.backgroundGradient,
    required this.borderRadius,
    required this.shadows,
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    // Draw shadows
    for (final shadow in shadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);
      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

    // Draw fill
    final fillPaint = Paint();
    if (backgroundGradient != null) {
      fillPaint.shader = backgroundGradient!.createShader(
        Offset.zero & size,
      );
    } else {
      fillPaint.color = backgroundColor;
    }
    canvas.drawPath(path, fillPaint);
  }

  Path _buildPath(Size size) {
    return switch (shape) {
      NotchNavShape.circle => _buildCircleNotch(size),
      NotchNavShape.square => _buildSquareNotch(size),
      NotchNavShape.diamond => _buildDiamondNotch(size),
    };
  }

  Path _buildCircleNotch(Size size) {
    final r = borderRadius;
    final nr = notchRadius;
    final cx = notchCenterX;
    final rf = filletRadius;

    // Fillet center is at (fx, rf), tangent to y=0 and externally tangent
    // to the notch circle. Distance from notch center to fillet center = nr + rf.
    final filletOffsetX = sqrt(nr * nr + 2 * nr * rf);

    // Tangent point where fillet meets the notch arc
    final totalDist = nr + rf;
    final tpx = nr * filletOffsetX / totalDist;
    final tpy = nr * rf / totalDist;

    // Fillet arc: direction from fillet center to tangent point
    final fdx = filletOffsetX - tpx;
    final fdy = tpy - rf;
    final filletAngle = atan2(fdy, fdx);
    final filletSweep = filletAngle + pi / 2; // CW from top to tangent point

    // Notch arc: CCW sweep through the bottom
    final notchStartAngle = atan2(tpy, -tpx);
    final notchSweep = atan2(tpy, tpx) - notchStartAngle; // negative = CCW

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.lineTo(cx - filletOffsetX, 0);

    // Left fillet arc
    path.arcTo(
      Rect.fromCircle(center: Offset(cx - filletOffsetX, rf), radius: rf),
      -pi / 2,
      filletSweep,
      false,
    );

    // Main notch arc
    path.arcTo(
      Rect.fromCircle(center: Offset(cx, 0), radius: nr),
      notchStartAngle,
      notchSweep,
      false,
    );

    // Right fillet arc
    path.arcTo(
      Rect.fromCircle(center: Offset(cx + filletOffsetX, rf), radius: rf),
      atan2(fdy, -fdx),
      filletSweep,
      false,
    );

    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r));
    path.close();

    return path;
  }

  Path _buildSquareNotch(Size size) {
    final r = borderRadius;
    final nr = notchRadius;
    final cx = notchCenterX;
    final rf = filletRadius;
    final depth = nr;

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    // Top edge to left fillet start
    path.lineTo(cx - nr - rf, 0);

    // Left top fillet: center at (cx-nr-rf, rf), from horizontal into left wall
    path.arcTo(
      Rect.fromCircle(center: Offset(cx - nr - rf, rf), radius: rf),
      -pi / 2,
      pi / 2,
      false,
    );

    // Left wall down
    path.lineTo(cx - nr, depth - rf);

    // Bottom-left corner: center at (cx-nr+rf, depth-rf)
    path.arcTo(
      Rect.fromCircle(center: Offset(cx - nr + rf, depth - rf), radius: rf),
      pi,
      -pi / 2,
      false,
    );

    // Bottom edge
    path.lineTo(cx + nr - rf, depth);

    // Bottom-right corner: center at (cx+nr-rf, depth-rf)
    path.arcTo(
      Rect.fromCircle(center: Offset(cx + nr - rf, depth - rf), radius: rf),
      pi / 2,
      -pi / 2,
      false,
    );

    // Right wall up
    path.lineTo(cx + nr, rf);

    // Right top fillet: center at (cx+nr+rf, rf), from right wall into horizontal
    path.arcTo(
      Rect.fromCircle(center: Offset(cx + nr + rf, rf), radius: rf),
      pi,
      pi / 2,
      false,
    );

    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r));
    path.close();

    return path;
  }

  Path _buildDiamondNotch(Size size) {
    final r = borderRadius;
    final nr = notchRadius;
    final cx = notchCenterX;
    final rf = filletRadius;
    final sqrt2 = sqrt(2);
    final sqrt2h = sqrt2 / 2; // √2/2

    // Top fillet centers (tangent to y=0 and to the 45° diagonal)
    final leftFilletCx = cx - nr - rf * (sqrt2 - 1);
    final rightFilletCx = cx + nr + rf * (sqrt2 - 1);

    // Bottom point fillet center (tangent to both 45° diagonals)
    final bottomFilletCy = nr - rf * sqrt2;

    // Tangent points: left diagonal → bottom fillet
    final leftDiagEndX = cx - rf * sqrt2h;
    final leftDiagEndY = nr - rf * sqrt2h;

    // Tangent points: right diagonal → right fillet
    final rightDiagEndX = cx + nr - rf * (1 - sqrt2h);
    final rightDiagEndY = rf * (1 - sqrt2h);

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    // Top edge to left fillet start
    path.lineTo(leftFilletCx, 0);

    // Left top fillet: from horizontal edge into 45° diagonal
    path.arcTo(
      Rect.fromCircle(center: Offset(leftFilletCx, rf), radius: rf),
      -pi / 2,
      pi / 4,
      false,
    );

    // Left diagonal down to bottom fillet
    path.lineTo(leftDiagEndX, leftDiagEndY);

    // Bottom point fillet: sweeps from left diagonal to right diagonal
    path.arcTo(
      Rect.fromCircle(center: Offset(cx, bottomFilletCy), radius: rf),
      3 * pi / 4,
      -pi / 2,
      false,
    );

    // Right diagonal up to right fillet
    path.lineTo(rightDiagEndX, rightDiagEndY);

    // Right top fillet: from 45° diagonal back to horizontal edge
    path.arcTo(
      Rect.fromCircle(center: Offset(rightFilletCx, rf), radius: rf),
      -3 * pi / 4,
      pi / 4,
      false,
    );

    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r));
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(_NotchBarPainter old) =>
      old.notchCenterX != notchCenterX ||
      old.notchRadius != notchRadius ||
      old.filletRadius != filletRadius ||
      old.backgroundColor != backgroundColor ||
      old.backgroundGradient != backgroundGradient ||
      old.borderRadius != borderRadius ||
      old.shape != shape;
}
