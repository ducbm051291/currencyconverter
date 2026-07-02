import 'package:currencyconverter/presentation/converter/widget/currency_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleCodes = ['USD', 'EUR', 'GBP', 'JPY', 'VND', 'AUD'];

  Future<void> pumpPicker(
    WidgetTester tester, {
    List<String> codes = sampleCodes,
    String? selectedCode,
    List<String> suggestedCodes = kSuggestedCurrencyCodes,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurrencyPickerSheet(
            codes: codes,
            selectedCode: selectedCode,
            suggestedCodes: suggestedCodes,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('CurrencyPickerSheet', () {
    testWidgets('renders search field and currency codes', (tester) async {
      await pumpPicker(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('Select currency'), findsOneWidget);
    });

    testWidgets('shows suggested section with USD', (tester) async {
      await pumpPicker(tester);

      expect(find.text('Suggested'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(suggestedCodesFor(sampleCodes), contains('VND'));
    });

    testWidgets('search finds VND by code', (tester) async {
      await pumpPicker(tester);

      await tester.enterText(find.byType(TextField), 'VN');
      await tester.pumpAndSettle();

      expect(find.text('VND'), findsOneWidget);
    });

    testWidgets('search filters list by code', (tester) async {
      await pumpPicker(tester);

      await tester.enterText(find.byType(TextField), 'JP');
      await tester.pumpAndSettle();

      expect(find.text('JPY'), findsOneWidget);
      expect(find.text('EUR'), findsNothing);
      expect(find.text('Suggested'), findsNothing);
    });

    testWidgets('empty search shows no currencies found', (tester) async {
      await pumpPicker(tester);

      await tester.enterText(find.byType(TextField), 'ZZZZZ');
      await tester.pumpAndSettle();

      expect(find.text('No currencies found'), findsOneWidget);
    });

    testWidgets('tap returns selected currency', (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showCurrencyPickerSheet(
                    context,
                    codes: sampleCodes,
                    suggestedCodes: suggestedCodesFor(sampleCodes),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('EUR').last);
      await tester.pumpAndSettle();

      expect(result, 'EUR');
    });

    testWidgets('shows checkmark on selected code', (tester) async {
      await pumpPicker(tester, selectedCode: 'EUR');

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
