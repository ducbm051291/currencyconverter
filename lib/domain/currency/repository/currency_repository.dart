import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';

abstract class CurrencyRepository {
  Future<ExchangeRateModel> fetchLatestRates();

  Future<ExchangeRateModel?> getCachedRates();

  Future<String> getSavedCurrencyCode();

  Future<void> setSavedCurrencyCode(String code);
}
