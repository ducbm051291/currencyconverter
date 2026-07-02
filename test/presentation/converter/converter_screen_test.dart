import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';
import 'package:currencyconverter/presentation/converter/widget/calculator_section.dart';
import 'package:currencyconverter/presentation/converter/widget/offline_status_banner.dart';
import 'package:currencyconverter/presentation/converter/widget/saved_currency_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../mocks/test_data_util.dart';

void main() {
  final uiModel = ConverterUiModel(
    savedCurrencyCode: 'JPY',
    savedCurrencyRate: 0.0067,
    rates: TestDataUtil.sampleRates,
    lastUpdated: DateTime.utc(2026, 6, 30, 10),
    isUsingCachedData: true,
    calculatorAmount: 1,
    calculatorFromCode: 'USD',
    calculatorToCode: 'EUR',
    calculatorResult: 0.92,
    currencies: [
      const CurrencyListItemUiModel(code: 'USD', rateLabel: '1 USD = 1.0000 USD'),
      const CurrencyListItemUiModel(code: 'EUR', rateLabel: '1 USD = 0.9200 EUR'),
    ],
  );

  group('Converter widgets', () {
    testWidgets('offline banner shows cached data message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineStatusBanner(
              lastUpdated: null,
              isUsingCachedData: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Using cached data'), findsOneWidget);
    });

    testWidgets('saved currency header shows JPY to USD rate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SavedCurrencyHeader(
              uiModel: uiModel,
              onChangeSavedCurrency: (_) {},
            ),
          ),
        ),
      );

      expect(find.textContaining('1 JPY'), findsOneWidget);
      expect(find.textContaining('USD'), findsWidgets);
    });

    testWidgets('calculator section shows converted result', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorSection(
              uiModel: uiModel,
              onAmountChanged: (_) {},
              onFromChanged: (_) {},
              onToChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Calculator'), findsOneWidget);
      expect(find.textContaining('EUR'), findsWidgets);
    });

    testWidgets('calculator from field opens searchable picker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalculatorSection(
              uiModel: uiModel,
              onAmountChanged: (_) {},
              onFromChanged: (_) {},
              onToChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('USD').first);
      await tester.pumpAndSettle();

      expect(find.text('Select currency'), findsOneWidget);
      expect(find.text('Search currency code'), findsOneWidget);
    });
  });
}
