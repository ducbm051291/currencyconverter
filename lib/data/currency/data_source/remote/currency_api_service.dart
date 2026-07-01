import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:currencyconverter/core/config/env.dart';
import 'package:currencyconverter/data/currency/data_source/remote/model/response/rates_response.dart';

abstract class CurrencyApiService {
  Future<RatesResponse> getLatestRates();
}

@Injectable(as: CurrencyApiService)
class DefaultCurrencyApiService implements CurrencyApiService {
  DefaultCurrencyApiService(this._dio);

  final Dio _dio;

  @override
  Future<RatesResponse> getLatestRates() async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.currencyfreaks.com/v2.0/rates/latest',
      queryParameters: {'apikey': Env.currencyFreaksApiKey},
    );
    return RatesResponse.fromJson(response.data!);
  }
}
