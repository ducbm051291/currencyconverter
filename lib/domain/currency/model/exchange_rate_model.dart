import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate_model.freezed.dart';

@freezed
class ExchangeRateModel with _$ExchangeRateModel {
  const factory ExchangeRateModel({
    required String base,
    required Map<String, double> rates,
    required DateTime apiDate,
    required DateTime fetchedAt,
    @Default(false) bool isFromCache,
  }) = _ExchangeRateModel;
}
