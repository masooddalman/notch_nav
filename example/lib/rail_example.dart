import 'package:flutter/material.dart';
import 'package:notch_nav/notch_nav.dart';

import 'playground.dart';

class RailExampleScreen extends StatefulWidget {
  const RailExampleScreen({super.key});

  @override
  State<RailExampleScreen> createState() => _RailExampleScreenState();
}

class _RailExampleScreenState extends State<RailExampleScreen> {
  int _selectedIndex = 0;
  int _presetIndex = 0;
  NotchRailAlignment _alignment = NotchRailAlignment.left;

  static const _items = [
    NotchNavItem(icon: Icons.home_rounded, label: 'Home'),
    NotchNavItem(icon: Icons.search_rounded, label: 'Search'),
    NotchNavItem(icon: Icons.favorite_rounded, label: 'Likes'),
    NotchNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  Preset get _preset => presets[_presetIndex];

  @override
  Widget build(BuildContext context) {
    final preset = _preset;
    final isDark = preset.scaffoldColor.computeLuminance() < 0.3;

    final rail = NotchRail(
      items: _items,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      alignment: _alignment,
      shape: preset.shape,
      labelBehavior: preset.labelBehavior,
      backgroundColor: preset.backgroundColor ?? Colors.white,
      backgroundGradient: preset.backgroundGradient,
      activeColor: preset.activeColor ?? const Color(0xFF6C63FF),
      activeGradient: preset.activeGradient,
      activeIconColor: preset.activeIconColor ?? Colors.white,
      inactiveIconColor: preset.inactiveIconColor ?? const Color(0xFF9E9E9E),
      labelColor: preset.labelColor ?? const Color(0xFF424242),
      animationDuration: preset.animationDuration,
      animationCurve: preset.animationCurve,
      notchMargin: preset.notchMargin,
      notchCornerRadius: preset.notchCornerRadius,
      railBorderRadius: preset.barBorderRadius,
      circleSize: preset.circleSize,
      margin: EdgeInsets.symmetric(
        horizontal: preset.margin.vertical / 2,
        vertical: preset.margin.horizontal / 2,
      ),
    );

    final body = Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: preset.scaffoldColor,
        child: Column(
          children: [
            // Alignment toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SegmentedButton<NotchRailAlignment>(
                segments: const [
                  ButtonSegment(
                    value: NotchRailAlignment.left,
                    label: Text('Left'),
                  ),
                  ButtonSegment(
                    value: NotchRailAlignment.right,
                    label: Text('Right'),
                  ),
                ],
                selected: {_alignment},
                onSelectionChanged: (v) =>
                    setState(() => _alignment = v.first),
              ),
            ),
            // Preset list
            Expanded(
              child: PresetList(
                activeIndex: _presetIndex,
                isDark: isDark,
                onSelect: (index) => setState(() {
                  _presetIndex = index;
                  _selectedIndex = 0;
                }),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: preset.scaffoldColor,
      appBar: AppBar(
        title: const Text('NotchRail Playground'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: SafeArea(
        child: Row(
          children: _alignment == NotchRailAlignment.left
              ? [rail, body]
              : [body, rail],
        ),
      ),
    );
  }
}
