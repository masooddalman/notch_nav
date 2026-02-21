import 'package:flutter/material.dart';

import 'notch_nav_item.dart';

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
  final Color backgroundColor;

  /// Color of the selected item's circle.
  final Color activeColor;

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

  /// Creates a [NotchNav] widget.
  const NotchNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.activeColor = const Color(0xFF6C63FF),
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
    this.animationCurve = Curves.easeInOut,
    this.labelBehavior = NotchNavLabelBehavior.selectedOnly,
    this.alignSelectedLabel = true,
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

            return Stack(
              children: [
                // Bar background
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: barHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(barBorderRadius),
                      boxShadow:
                          barShadow ??
                          const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                    ),
                  ),
                ),
                // Sliding circle (always at top, moves horizontally)
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: animationCurve,
                  top: circleTop,
                  left: circleLeft,
                  width: circleSize,
                  height: circleSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                      boxShadow:
                          circleShadow ??
                          [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                    ),
                  ),
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
}
