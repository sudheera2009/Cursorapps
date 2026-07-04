import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:image_toolbox/widgets/glass_card.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: Icon(Icons.check, key: Key('child'))),
          ),
        ),
      );
      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassCard(
              onTap: () => tapped++,
              child: const Icon(Icons.check),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(GlassCard));
      await tester.pump();
      expect(tapped, 1);
    });
  });
}
