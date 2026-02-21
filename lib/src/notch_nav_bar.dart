import 'package:flutter/material.dart';

import 'notch_nav_item.dart';

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
    this.barHeight = 64,
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
  }) : assert(items.length >= 2, 'NotchNav requires at least 2 items'),
       assert(currentIndex >= 0, 'currentIndex must be non-negative'),
       assert(
         currentIndex < items.length,
         'currentIndex must be less than items.length',
       );

  double get _circleOffset => circleOffset ?? circleSize / 2;

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
        height: barHeight + _circleOffset,
        child: Stack(
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
            // Navigation items
            Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 0,
              bottom: 0,
              child: Row(children: List.generate(items.length, _buildNavItem)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = items[index];
    final isSelected = index == currentIndex;
    final selectedTop = _circleOffset - circleSize / 2;
    final unselectedTop = _circleOffset + (barHeight - circleSize) / 2;

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
              AnimatedPositioned(
                duration: animationDuration,
                curve: animationCurve,
                top: isSelected ? selectedTop : unselectedTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Circle with icon
                      AnimatedContainer(
                        duration: animationDuration,
                        curve: animationCurve,
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? activeColor : Colors.transparent,
                          boxShadow: isSelected
                              ? (circleShadow ??
                                    [
                                      BoxShadow(
                                        color: activeColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ])
                              : null,
                        ),
                        child: Center(
                          child: TweenAnimationBuilder<Color?>(
                            tween: ColorTween(
                              begin: isSelected
                                  ? activeIconColor
                                  : inactiveIconColor,
                              end: isSelected
                                  ? activeIconColor
                                  : inactiveIconColor,
                            ),
                            duration: animationDuration,
                            curve: animationCurve,
                            builder: (context, color, _) =>
                                Icon(item.icon, size: iconSize, color: color),
                          ),
                        ),
                      ),
                      // Label (animated reveal)
                      ClipRect(
                        child: AnimatedAlign(
                          duration: animationDuration,
                          curve: animationCurve,
                          heightFactor: isSelected ? 1.0 : 0.0,
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              item.label,
                              style: _labelStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
