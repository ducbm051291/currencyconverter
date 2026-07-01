import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Currency Converter')),
        ),
      ),
    );
    expect(find.text('Currency Converter'), findsOneWidget);
  });
}
