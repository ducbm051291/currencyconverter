import 'package:injectable/injectable.dart';

import 'package:currencyconverter/data/currency/data_source/local/app_database.dart';
import 'package:currencyconverter/data/currency/data_source/remote/currency_remote_data_source.dart';
import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';
import 'package:currencyconverter/domain/currency/repository/currency_repository.dart';

@Injectable(as: CurrencyRepository)
class DefaultCurrencyRepository implements CurrencyRepository {
  DefaultCurrencyRepository(
    this._remoteDataSource,
    this._localDataSource,
  );

  final CurrencyRemoteDataSource _remoteDataSource;
  final CurrencyLocalDataSource _localDataSource;

  @override
  Future<ExchangeRateModel> fetchLatestRates() async {
    final rates = await _remoteDataSource.getLatestRates();
    await _localDataSource.saveRates(rates);
    return rates;
  }

  @override
  Future<ExchangeRateModel?> getCachedRates() => _localDataSource.getCachedRates();

  @override
  Future<String> getSavedCurrencyCode() => _localDataSource.getSavedCurrencyCode();

  @override
  Future<void> setSavedCurrencyCode(String code) =>
      _localDataSource.setSavedCurrencyCode(code);
}
