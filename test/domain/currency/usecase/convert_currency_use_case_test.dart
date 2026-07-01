import 'package:currencyconverter/domain/currency/usecase/convert_currency_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../mocks/test_data_util.dart';

void main() {
  const useCase = ConvertCurrencyUseCase();

  group('ConvertCurrencyUseCase', () {
    group('when convert is called', () {
      group('and converting JPY to USD', () {
        test('returns converted amount', () {
          final result = useCase.convert(
            amount: 150,
            fromCurrency: 'JPY',
            toCurrency: 'USD',
            rates: TestDataUtil.sampleRates,
          );

          expect(result, closeTo(1, 0.0001));
        });
      });

      group('and currencies are the same', () {
        test('returns original amount', () {
          final result = useCase.convert(
            amount: 42,
            fromCurrency: 'USD',
            toCurrency: 'USD',
            rates: TestDataUtil.sampleRates,
          );

          expect(result, 42);
        });
      });

      group('and amount is zero', () {
        test('returns zero', () {
          final result = useCase.convert(
            amount: 0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            rates: TestDataUtil.sampleRates,
          );

          expect(result, 0);
        });
      });
    });
  });
}
