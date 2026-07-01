import 'package:injectable/injectable.dart';

import 'package:currencyconverter/data/currency/data_source/remote/currency_api_service.dart';
import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<ExchangeRateModel> getLatestRates();
}

@Injectable(as: CurrencyRemoteDataSource)
class DefaultCurrencyRemoteDataSource implements CurrencyRemoteDataSource {
  DefaultCurrencyRemoteDataSource(this._apiService);

  final CurrencyApiService _apiService;

  @override
  Future<ExchangeRateModel> getLatestRates() async {
    final response = await _apiService.getLatestRates();
    return response.toDomain(fetchedAt: DateTime.now().toUtc());
  }
}
