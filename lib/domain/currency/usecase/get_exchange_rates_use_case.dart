import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';
import 'package:currencyconverter/domain/currency/repository/currency_repository.dart';

class GetExchangeRatesUseCase {
  const GetExchangeRatesUseCase(this._repository);

  final CurrencyRepository _repository;

  Future<ExchangeRateModel> fetchLatestRates() => _repository.fetchLatestRates();

  Future<ExchangeRateModel?> getCachedRates() => _repository.getCachedRates();
}
