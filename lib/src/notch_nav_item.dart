import 'package:flutter/widgets.dart';

/// Represents a single item in the [NotchNav] bar.
class NotchNavItem {
  /// The icon to display for this navigation item.
  final IconData icon;

  /// The label text shown when this item is selected.
  final String label;

  /// Creates a [NotchNavItem].
  const NotchNavItem({
    required this.icon,
    required this.label,
  });
}
