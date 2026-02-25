import 'package:flutter/material.dart';
import 'package:notch_nav/notch_nav.dart';

import 'playground.dart';
import 'rail_example.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotchNav Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _presetIndex = 0;

  static const _items = [
    NotchNavItem(icon: Icons.list_rounded, label: 'Home'),
    NotchNavItem(icon: Icons.calendar_month_rounded, label: 'Journal'),
    NotchNavItem(icon: Icons.map_rounded, label: 'Maps'),
    NotchNavItem(icon: Icons.people_rounded, label: 'People'),
  ];

  Preset get _preset => presets[_presetIndex];

  @override
  Widget build(BuildContext context) {
    final preset = _preset;
    final isDark = preset.scaffoldColor.computeLuminance() < 0.3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: preset.scaffoldColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: PresetList(
            activeIndex: _presetIndex,
            isDark: isDark,
            onSelect: (index) => setState(() {
              _presetIndex = index;
              _selectedIndex = 0;
            }),
            trailing: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RailExampleScreen(),
                  ),
                ),
                icon: Icon(Icons.view_sidebar_rounded, color: isDark ? Colors.white70 : Colors.black54),
                label: Text(
                  'Try NotchRail',
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: NotchNav(
          items: _items,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          shape: preset.shape,
          labelBehavior: preset.labelBehavior,
          backgroundColor: preset.backgroundColor ?? Colors.white,
          backgroundGradient: preset.backgroundGradient,
          activeColor: preset.activeColor ?? const Color(0xFF6C63FF),
          activeGradient: preset.activeGradient,
          activeIconColor: preset.activeIconColor ?? Colors.white,
          inactiveIconColor:
              preset.inactiveIconColor ?? const Color(0xFF9E9E9E),
          labelColor: preset.labelColor ?? const Color(0xFF424242),
          animationDuration: preset.animationDuration,
          animationCurve: preset.animationCurve,
          notchMargin: preset.notchMargin,
          notchCornerRadius: preset.notchCornerRadius,
          barBorderRadius: preset.barBorderRadius,
          circleSize: preset.circleSize,
          margin: preset.margin,
        ),
      ),
    );
  }
}
