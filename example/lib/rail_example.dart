import 'package:flutter/material.dart';
import 'package:notch_nav/notch_nav.dart';

class RailExampleScreen extends StatefulWidget {
  const RailExampleScreen({super.key});

  @override
  State<RailExampleScreen> createState() => _RailExampleScreenState();
}

class _RailExampleScreenState extends State<RailExampleScreen> {
  int _selectedIndex = 0;
  NotchRailAlignment _alignment = NotchRailAlignment.left;
  NotchNavShape _shape = NotchNavShape.circle;

  static const _items = [
    NotchNavItem(icon: Icons.home_rounded, label: 'Home'),
    NotchNavItem(icon: Icons.search_rounded, label: 'Search'),
    NotchNavItem(icon: Icons.favorite_rounded, label: 'Likes'),
    NotchNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  static const _pages = ['Home', 'Search', 'Likes', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final rail = NotchRail(
      items: _items,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      alignment: _alignment,
      shape: _shape,
      activeColor: const Color(0xFF6C63FF),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
    );

    final body = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _pages[_selectedIndex],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          // Controls
          SegmentedButton<NotchRailAlignment>(
            segments: const [
              ButtonSegment(value: NotchRailAlignment.left, label: Text('Left')),
              ButtonSegment(
                value: NotchRailAlignment.right,
                label: Text('Right'),
              ),
            ],
            selected: {_alignment},
            onSelectionChanged: (v) => setState(() => _alignment = v.first),
          ),
          const SizedBox(height: 12),
          SegmentedButton<NotchNavShape>(
            segments: const [
              ButtonSegment(value: NotchNavShape.circle, label: Text('Circle')),
              ButtonSegment(value: NotchNavShape.square, label: Text('Square')),
              ButtonSegment(
                value: NotchNavShape.diamond,
                label: Text('Diamond'),
              ),
            ],
            selected: {_shape},
            onSelectionChanged: (v) => setState(() => _shape = v.first),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('NotchRail Example'),
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
