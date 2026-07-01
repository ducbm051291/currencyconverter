import 'package:currencyconverter/app/app.dart';
import 'package:currencyconverter/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(configureInjection);

  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const CurrencyConverterApp());
    expect(find.text('Currency Converter'), findsOneWidget);
  });
}
