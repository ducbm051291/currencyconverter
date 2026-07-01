import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';

class TestDataUtil {
  static final sampleRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'JPY': 150.0,
    'GBP': 0.79,
  };

  static ExchangeRateModel sampleExchangeRate({
    bool isFromCache = false,
    DateTime? apiDate,
    DateTime? fetchedAt,
  }) =>
      ExchangeRateModel(
        base: 'USD',
        rates: sampleRates,
        apiDate: apiDate ?? DateTime.utc(2026, 6, 30, 10),
        fetchedAt: fetchedAt ?? DateTime.utc(2026, 6, 30, 10, 5),
        isFromCache: isFromCache,
      );
}
