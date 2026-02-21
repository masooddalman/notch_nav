import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notch_nav/notch_nav.dart';

void main() {
  const items = [
    NotchNavItem(icon: Icons.home, label: 'Home'),
    NotchNavItem(icon: Icons.calendar_today, label: 'Journal'),
    NotchNavItem(icon: Icons.map, label: 'Maps'),
    NotchNavItem(icon: Icons.people, label: 'People'),
  ];

  testWidgets('renders all item icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NotchNav(
            items: items,
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('shows selected item label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NotchNav(
            items: items,
            currentIndex: 0,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('calls onTap with correct index', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: NotchNav(
            items: items,
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.map));
    expect(tappedIndex, 2);
  });

  testWidgets('updates selected item on rebuild', (tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return NotchNav(
                items: items,
                currentIndex: selectedIndex,
                onTap: (index) => setState(() => selectedIndex = index),
              );
            },
          ),
        ),
      ),
    );

    // Tap second item
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(find.text('Journal'), findsOneWidget);
  });
}
