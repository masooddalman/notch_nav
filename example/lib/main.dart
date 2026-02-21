import 'package:flutter/material.dart';
import 'package:notch_nav/notch_nav.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotchNav Example',
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

  static const _items = [
    NotchNavItem(icon: Icons.list_rounded, label: 'Home'),
    NotchNavItem(icon: Icons.calendar_month_rounded, label: 'Journal'),
    NotchNavItem(icon: Icons.map_rounded, label: 'Maps'),
    NotchNavItem(icon: Icons.people_rounded, label: 'People'),
  ];

  static const _pages = ['Home', 'Journal', 'Maps', 'People'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F0),
      body: Center(
        child: Text(
          _pages[_selectedIndex],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: NotchNav(
        items: _items,
        labelBehavior: NotchNavLabelBehavior.selectedOnly,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
