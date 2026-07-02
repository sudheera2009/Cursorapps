import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world/main.dart';

void main() {
  testWidgets('Hello World app displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello, World!'), findsOneWidget);
    expect(find.text('Welcome to Flutter'), findsOneWidget);
    expect(find.byIcon(Icons.flutter_dash), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}
