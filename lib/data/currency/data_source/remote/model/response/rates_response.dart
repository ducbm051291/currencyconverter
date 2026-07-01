import 'package:json_annotation/json_annotation.dart';

import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';

part 'rates_response.g.dart';

@JsonSerializable()
class RatesResponse {
  const RatesResponse({
    required this.date,
    required this.base,
    required this.rates,
  });

  factory RatesResponse.fromJson(Map<String, dynamic> json) =>
      _$RatesResponseFromJson(json);

  final String date;
  final String base;
  final Map<String, dynamic> rates;

  ExchangeRateModel toDomain({required DateTime fetchedAt}) {
    final parsedRates = rates.map(
      (key, value) => MapEntry(key, double.parse(value.toString())),
    );

    return ExchangeRateModel(
      base: base,
      rates: parsedRates,
      apiDate: DateTime.parse(date),
      fetchedAt: fetchedAt,
    );
  }
}
