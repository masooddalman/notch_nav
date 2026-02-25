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

  Widget buildRail({
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    NotchRailAlignment alignment = NotchRailAlignment.left,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            NotchRail(
              items: items,
              currentIndex: currentIndex,
              onTap: onTap ?? (_) {},
              alignment: alignment,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }

  testWidgets('renders all item icons', (tester) async {
    await tester.pumpWidget(buildRail());

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('shows selected item label', (tester) async {
    await tester.pumpWidget(buildRail());

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('calls onTap with correct index', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      buildRail(onTap: (index) => tappedIndex = index),
    );

    await tester.tap(find.byIcon(Icons.map));
    expect(tappedIndex, 2);
  });

  testWidgets('updates selected item on rebuild', (tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return NotchRail(
                    items: items,
                    currentIndex: selectedIndex,
                    onTap: (index) => setState(() => selectedIndex = index),
                  );
                },
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    expect(selectedIndex, 1);
    expect(find.text('Journal'), findsOneWidget);
  });

  testWidgets('works with right alignment', (tester) async {
    await tester.pumpWidget(
      buildRail(alignment: NotchRailAlignment.right),
    );

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
