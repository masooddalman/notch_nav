import 'dart:math' show pi, sqrt, atan2;

import 'package:flutter/material.dart';

import 'notch_nav_bar.dart';
import 'notch_nav_item.dart';

/// Which side of the screen the rail is placed.
enum NotchRailAlignment {
  /// Rail on the left side, notch pops right (toward content).
  left,

  /// Rail on the right side, notch pops left (toward content).
  right,
}

/// How items are distributed vertically within the rail.
enum NotchRailItemsAlignment {
  /// Items are aligned to the top with fixed spacing between them (default).
  start,

  /// Items are spread evenly across the full rail height.
  spaceEvenly,
}

/// A vertical navigation rail with a notch-style pop-out effect on the active item.
class NotchRail extends StatelessWidget {
  final List<NotchNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final Color activeColor;
  final Gradient? activeGradient;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color labelColor;
  final TextStyle? labelStyle;
  final double railWidth;
  final double railBorderRadius;
  final double circleSize;
  final double iconSize;
  final double labelFontSize;
  final double? circleOffset;
  final EdgeInsets margin;
  final double verticalPadding;
  final List<BoxShadow>? railShadow;
  final List<BoxShadow>? circleShadow;
  final Duration animationDuration;
  final Curve animationCurve;
  final NotchNavLabelBehavior labelBehavior;
  final NotchNavShape shape;
  final double notchMargin;
  final double notchCornerRadius;
  final NotchRailAlignment alignment;
  final NotchRailItemsAlignment itemsAlignment;
  final double? itemExtent;

  const NotchRail({
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
    this.railWidth = 72,
    this.railBorderRadius = 16,
    this.circleSize = 52,
    this.iconSize = 26,
    this.labelFontSize = 10,
    this.circleOffset,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
    this.verticalPadding = 16,
    this.railShadow,
    this.circleShadow,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCirc,
    this.labelBehavior = NotchNavLabelBehavior.selectedOnly,
    this.shape = NotchNavShape.circle,
    this.notchMargin = 6,
    this.notchCornerRadius = 6,
    this.alignment = NotchRailAlignment.left,
    this.itemsAlignment = NotchRailItemsAlignment.start,
    this.itemExtent,
  }) : assert(items.length >= 2, 'NotchRail requires at least 2 items'),
       assert(currentIndex >= 0, 'currentIndex must be non-negative'),
       assert(
         currentIndex < items.length,
         'currentIndex must be less than items.length',
       );

  double get _circleOffset => circleOffset ?? circleSize / 2;
  /// Whether the notch cuts into the left edge of the rail.
  /// Left alignment → notch on right edge (_isLeft = false).
  /// Right alignment → notch on left edge (_isLeft = true).
  bool get _isLeft => alignment == NotchRailAlignment.right;

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
    return Padding(
      padding: margin,
      child: SizedBox(
        width: railWidth + _circleOffset,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentHeight =
                constraints.maxHeight - 2 * verticalPadding;
            final bool isSpaceEvenly =
                itemsAlignment == NotchRailItemsAlignment.spaceEvenly;
            final double itemHeight =
                isSpaceEvenly
                    ? contentHeight / items.length
                    : (itemExtent ?? circleSize + 16);
            final circleTop =
                verticalPadding +
                currentIndex * itemHeight +
                (itemHeight - circleSize) / 2;
            final circleCenterY = circleTop + circleSize / 2;

            // Horizontal positions
            final railLeft = _isLeft ? _circleOffset : 0.0;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Rail background with notch cutout
                Positioned(
                  left: railLeft,
                  top: 0,
                  bottom: 0,
                  width: railWidth,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: circleCenterY),
                    duration: animationDuration,
                    curve: animationCurve,
                    builder: (context, notchY, _) {
                      return CustomPaint(
                        painter: _NotchRailPainter(
                          notchCenterY: notchY,
                          notchRadius: circleSize / 2 + notchMargin,
                          filletRadius: notchCornerRadius,
                          backgroundColor: backgroundColor,
                          backgroundGradient: backgroundGradient,
                          borderRadius: railBorderRadius,
                          shape: shape,
                          isLeft: _isLeft,
                          shadows:
                              railShadow ??
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
                // Sliding indicator
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: animationCurve,
                  top: circleTop,
                  left: _isLeft ? 0 : railWidth - circleSize / 2,
                  width: circleSize,
                  height: circleSize,
                  child: _buildIndicator(),
                ),
                // Navigation item icons
                Positioned(
                  left: railLeft,
                  width: railWidth,
                  top: verticalPadding,
                  bottom: isSpaceEvenly ? verticalPadding : null,
                  child: Column(
                    mainAxisSize:
                        isSpaceEvenly ? MainAxisSize.max : MainAxisSize.min,
                    children: List.generate(
                      items.length,
                      (i) => _buildNavItem(i, expanded: isSpaceEvenly),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, {bool expanded = true}) {
    final item = items[index];
    final isSelected = index == currentIndex;

    // Icon horizontal positions (relative to rail)
    final selectedIconLeft =
        _isLeft
            ? -_circleOffset + (circleSize - iconSize) / 2
            : railWidth - circleSize / 2 + (circleSize - iconSize) / 2;
    final unselectedIconLeft = (railWidth - iconSize) / 2;

    final child = Semantics(
        label: item.label,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox.expand(),
              // Icon (animates horizontally)
              AnimatedPositioned(
                duration: animationDuration,
                curve: animationCurve,
                left: isSelected ? selectedIconLeft : unselectedIconLeft,
                top: 0,
                bottom: 0,
                child: Center(
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      begin:
                          isSelected ? activeIconColor : inactiveIconColor,
                      end: isSelected ? activeIconColor : inactiveIconColor,
                    ),
                    duration: animationDuration,
                    curve: animationCurve,
                    builder: (context, color, _) =>
                        Icon(item.icon, size: iconSize, color: color),
                  ),
                ),
              ),
              // Label (vertically centered, same line as icon)
              if (labelBehavior != NotchNavLabelBehavior.none)
                Positioned(
                  left: _isLeft ? circleSize / 2 : 0,
                  right: _isLeft ? 0 : circleSize / 2,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: animationDuration,
                        opacity: _showLabel(isSelected) ? 1.0 : 0.0,
                        child: Transform.rotate(
                          angle: -pi / 2,
                          child: Text(
                            item.label,
                            style: _labelStyle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

    if (expanded) {
      return Expanded(child: child);
    }
    final height = itemExtent ?? circleSize + 16;
    return SizedBox(height: height, child: child);
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

// ── Painter ─────────────────────────────────────────────────────────────────
//
// Instead of manually rotating the notch geometry (error-prone), we build the
// exact same horizontal bar path used by _NotchBarPainter, then rotate the
// finished Path 90° with Path.transform(). This guarantees pixel-identical
// notch shapes.

class _NotchRailPainter extends CustomPainter {
  final double notchCenterY;
  final double notchRadius;
  final double filletRadius;
  final Color backgroundColor;
  final Gradient? backgroundGradient;
  final double borderRadius;
  final List<BoxShadow> shadows;
  final NotchNavShape shape;
  final bool isLeft;

  const _NotchRailPainter({
    required this.notchCenterY,
    required this.notchRadius,
    required this.filletRadius,
    required this.backgroundColor,
    this.backgroundGradient,
    required this.borderRadius,
    required this.shadows,
    required this.shape,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    for (final shadow in shadows) {
      final shadowPaint = Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma);
      canvas.save();
      canvas.translate(shadow.offset.dx, shadow.offset.dy);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();
    }

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
    final w = size.width;
    final h = size.height;

    // Build a horizontal bar of size (h, w) — same as _NotchBarPainter.
    final horizontalSize = Size(h, w);
    final double cx;
    final Matrix4 xform;

    if (!isLeft) {
      // Right-edge notch: rotate horizontal top edge → vertical right edge.
      // (x, y) → (w − y, x)
      cx = notchCenterY;
      xform = Matrix4.identity()
        ..translateByDouble(w, 0.0, 0.0, 1.0)
        ..rotateZ(pi / 2);
    } else {
      // Left-edge notch: rotate horizontal top edge → vertical left edge.
      // (x, y) → (y, h − x)
      cx = h - notchCenterY;
      xform = Matrix4.identity()
        ..translateByDouble(0.0, h, 0.0, 1.0)
        ..rotateZ(-pi / 2);
    }

    final horizontalPath = switch (shape) {
      NotchNavShape.circle => _buildCircleNotch(horizontalSize, cx),
      NotchNavShape.square => _buildSquareNotch(horizontalSize, cx),
      NotchNavShape.diamond => _buildDiamondNotch(horizontalSize, cx),
    };

    return horizontalPath.transform(xform.storage);
  }

  // ── Horizontal bar path builders (identical to _NotchBarPainter) ──────────

  Path _buildCircleNotch(Size size, double cx) {
    final r = borderRadius;
    final nr = notchRadius;
    final rf = filletRadius;

    final filletOffsetX = sqrt(nr * nr + 2 * nr * rf);
    final totalDist = nr + rf;
    final tpx = nr * filletOffsetX / totalDist;
    final tpy = nr * rf / totalDist;

    final fdx = filletOffsetX - tpx;
    final fdy = tpy - rf;
    final filletAngle = atan2(fdy, fdx);
    final filletSweep = filletAngle + pi / 2;

    final notchStartAngle = atan2(tpy, -tpx);
    final notchSweep = atan2(tpy, tpx) - notchStartAngle;

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(cx - filletOffsetX, 0);

    path.arcTo(
      Rect.fromCircle(center: Offset(cx - filletOffsetX, rf), radius: rf),
      -pi / 2,
      filletSweep,
      false,
    );

    path.arcTo(
      Rect.fromCircle(center: Offset(cx, 0), radius: nr),
      notchStartAngle,
      notchSweep,
      false,
    );

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

  Path _buildSquareNotch(Size size, double cx) {
    final r = borderRadius;
    final nr = notchRadius;
    final rf = filletRadius;
    final depth = nr;

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(cx - nr - rf, 0);

    path.arcTo(
      Rect.fromCircle(center: Offset(cx - nr - rf, rf), radius: rf),
      -pi / 2,
      pi / 2,
      false,
    );

    path.lineTo(cx - nr, depth - rf);

    path.arcTo(
      Rect.fromCircle(center: Offset(cx - nr + rf, depth - rf), radius: rf),
      pi,
      -pi / 2,
      false,
    );

    path.lineTo(cx + nr - rf, depth);

    path.arcTo(
      Rect.fromCircle(center: Offset(cx + nr - rf, depth - rf), radius: rf),
      pi / 2,
      -pi / 2,
      false,
    );

    path.lineTo(cx + nr, rf);

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

  Path _buildDiamondNotch(Size size, double cx) {
    final r = borderRadius;
    final nr = notchRadius;
    final rf = filletRadius;
    final sqrt2 = sqrt(2);
    final sqrt2h = sqrt2 / 2;

    final leftFilletCx = cx - nr - rf * (sqrt2 - 1);
    final rightFilletCx = cx + nr + rf * (sqrt2 - 1);
    final bottomFilletCy = nr - rf * sqrt2;

    final leftDiagEndX = cx - rf * sqrt2h;
    final leftDiagEndY = nr - rf * sqrt2h;

    final rightDiagEndX = cx + nr - rf * (1 - sqrt2h);
    final rightDiagEndY = rf * (1 - sqrt2h);

    final path = Path();

    path.moveTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    path.lineTo(leftFilletCx, 0);

    path.arcTo(
      Rect.fromCircle(center: Offset(leftFilletCx, rf), radius: rf),
      -pi / 2,
      pi / 4,
      false,
    );

    path.lineTo(leftDiagEndX, leftDiagEndY);

    path.arcTo(
      Rect.fromCircle(center: Offset(cx, bottomFilletCy), radius: rf),
      3 * pi / 4,
      -pi / 2,
      false,
    );

    path.lineTo(rightDiagEndX, rightDiagEndY);

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
  bool shouldRepaint(_NotchRailPainter old) =>
      old.notchCenterY != notchCenterY ||
      old.notchRadius != notchRadius ||
      old.filletRadius != filletRadius ||
      old.backgroundColor != backgroundColor ||
      old.backgroundGradient != backgroundGradient ||
      old.borderRadius != borderRadius ||
      old.shape != shape ||
      old.isLeft != isLeft;
}
