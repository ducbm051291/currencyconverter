import 'package:freezed_annotation/freezed_annotation.dart';

part 'converter_ui_model.freezed.dart';

@freezed
class CurrencyListItemUiModel with _$CurrencyListItemUiModel {
  const factory CurrencyListItemUiModel({
    required String code,
    required String rateLabel,
  }) = _CurrencyListItemUiModel;
}

@freezed
class ConverterUiModel with _$ConverterUiModel {
  const factory ConverterUiModel({
    required String savedCurrencyCode,
    @Default('USD') String targetCurrencyCode,
    required double savedCurrencyRate,
    required Map<String, double> rates,
    required DateTime? lastUpdated,
    required bool isUsingCachedData,
    @Default(1) double calculatorAmount,
    @Default('USD') String calculatorFromCode,
    @Default('EUR') String calculatorToCode,
    @Default(0) double calculatorResult,
    @Default([]) List<CurrencyListItemUiModel> currencies,
    @Default('') String searchQuery,
  }) = _ConverterUiModel;
}
