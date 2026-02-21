import 'package:flutter/material.dart';
import 'package:notch_nav/notch_nav.dart';

// ── Preset model ────────────────────────────────────────────────────────────

class Preset {
  final String name;
  final NotchNavShape shape;
  final NotchNavLabelBehavior labelBehavior;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? activeColor;
  final Gradient? activeGradient;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? labelColor;
  final Duration animationDuration;
  final Curve animationCurve;
  final double notchMargin;
  final double notchCornerRadius;
  final double barBorderRadius;
  final double circleSize;
  final EdgeInsets margin;
  final Color scaffoldColor;

  const Preset({
    required this.name,
    this.shape = NotchNavShape.circle,
    this.labelBehavior = NotchNavLabelBehavior.selectedOnly,
    this.backgroundColor,
    this.backgroundGradient,
    this.activeColor,
    this.activeGradient,
    this.activeIconColor,
    this.inactiveIconColor,
    this.labelColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCirc,
    this.notchMargin = 6,
    this.notchCornerRadius = 6,
    this.barBorderRadius = 16,
    this.circleSize = 52,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.scaffoldColor = const Color(0xFFF5F5F5),
  });

  String get subtitle {
    final parts = <String>[
      shape.name,
      if (backgroundGradient != null || activeGradient != null) 'gradient',
      if (labelBehavior == NotchNavLabelBehavior.none) 'no labels',
      if (animationDuration.inMilliseconds != 300)
        '${animationDuration.inMilliseconds}ms',
    ];
    return parts.join(' · ');
  }
}

// ── Presets ──────────────────────────────────────────────────────────────────

final presets = [
  const Preset(
    name: 'Default',
    scaffoldColor: Color(0xFFF0F0F5),
  ),
  Preset(
    name: 'Ocean Gradient',
    backgroundGradient: LinearGradient(
      colors: [Colors.blue.shade50, Colors.cyan.shade50],
    ),
    activeGradient: const LinearGradient(
      colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    inactiveIconColor: Colors.blueGrey.shade400,
    labelColor: Colors.blueGrey.shade700,
    scaffoldColor: const Color(0xFFE8F4FD),
  ),
  Preset(
    name: 'Square Sunset',
    shape: NotchNavShape.square,
    backgroundGradient: const LinearGradient(
      colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    ),
    activeGradient: const LinearGradient(
      colors: [Color(0xFFFF6B35), Color(0xFFFF3C83)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    inactiveIconColor: const Color(0xFFBF8B60),
    labelColor: const Color(0xFF8B5E3C),
    notchCornerRadius: 8,
    scaffoldColor: const Color(0xFFFFF8F0),
  ),
  const Preset(
    name: 'Diamond Dark',
    shape: NotchNavShape.diamond,
    backgroundColor: Color(0xFF1E1E2E),
    activeColor: Color(0xFFBB86FC),
    activeIconColor: Colors.white,
    inactiveIconColor: Color(0xFF666680),
    labelColor: Color(0xFF9999B3),
    notchCornerRadius: 4,
    scaffoldColor: Color(0xFF121218),
  ),
  const Preset(
    name: 'Square Minimal',
    shape: NotchNavShape.square,
    backgroundColor: Colors.white,
    activeColor: Color(0xFF212121),
    activeIconColor: Colors.white,
    inactiveIconColor: Color(0xFFBDBDBD),
    labelColor: Color(0xFF757575),
    labelBehavior: NotchNavLabelBehavior.none,
    notchCornerRadius: 4,
    barBorderRadius: 0,
    margin: EdgeInsets.zero,
    scaffoldColor: Color(0xFFFAFAFA),
  ),
  Preset(
    name: 'Diamond Emerald',
    shape: NotchNavShape.diamond,
    backgroundGradient: LinearGradient(
      colors: [Colors.green.shade50, Colors.teal.shade50],
    ),
    activeGradient: const LinearGradient(
      colors: [Color(0xFF00C853), Color(0xFF009688)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    inactiveIconColor: Colors.teal.shade300,
    labelColor: Colors.teal.shade700,
    notchCornerRadius: 3,
    scaffoldColor: const Color(0xFFE8F5E9),
  ),
  const Preset(
    name: 'Bouncy Circle',
    animationDuration: Duration(milliseconds: 600),
    animationCurve: Curves.elasticOut,
    activeColor: Color(0xFFE91E63),
    inactiveIconColor: Color(0xFFCE93D8),
    labelColor: Color(0xFF880E4F),
    circleSize: 58,
    notchMargin: 8,
    scaffoldColor: Color(0xFFFCE4EC),
  ),
  Preset(
    name: 'Slow Square',
    shape: NotchNavShape.square,
    animationDuration: const Duration(milliseconds: 800),
    animationCurve: Curves.easeInOutCubic,
    backgroundColor: Colors.indigo.shade900,
    activeColor: Colors.amber,
    activeIconColor: Colors.indigo.shade900,
    inactiveIconColor: Colors.indigo.shade300,
    labelColor: Colors.indigo.shade200,
    notchCornerRadius: 12,
    barBorderRadius: 24,
    scaffoldColor: const Color(0xFF1A1A3E),
  ),
];

// ── Preset list widget ──────────────────────────────────────────────────────

class PresetList extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final bool isDark;

  const PresetList({
    super.key,
    required this.activeIndex,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white60 : Colors.black54;
    final chipBg =
        isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06);
    final chipSelectedBg =
        isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Text(
            'NotchNav Playground',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Tap a style below to preview it',
            style: TextStyle(fontSize: 14, color: subtextColor),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: presets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = presets[index];
              final isActive = index == activeIndex;

              return GestureDetector(
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? chipSelectedBg : chipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(
                            color: isDark ? Colors.white30 : Colors.black26,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      _ShapeIcon(
                        shape: p.shape,
                        color: p.activeColor ?? const Color(0xFF6C63FF),
                        gradient: p.activeGradient,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Icon(
                          Icons.check_circle_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shape preview icon ──────────────────────────────────────────────────────

class _ShapeIcon extends StatelessWidget {
  final NotchNavShape shape;
  final Color color;
  final Gradient? gradient;

  const _ShapeIcon({
    required this.shape,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    const size = 28.0;

    final decoration = BoxDecoration(
      gradient: gradient,
      color: gradient == null ? color : null,
      shape:
          shape == NotchNavShape.circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: shape != NotchNavShape.circle
          ? BorderRadius.circular(shape == NotchNavShape.square ? 6 : 4)
          : null,
    );

    Widget box = SizedBox(
      width: shape == NotchNavShape.diamond ? size * 0.7 : size,
      height: shape == NotchNavShape.diamond ? size * 0.7 : size,
      child: DecoratedBox(decoration: decoration),
    );

    if (shape == NotchNavShape.diamond) {
      box = SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Transform.rotate(angle: 3.14159 / 4, child: box),
        ),
      );
    }

    return box;
  }
}
