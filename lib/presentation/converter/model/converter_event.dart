import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:currencyconverter/presentation/common/base/base_event.dart';

part 'converter_event.freezed.dart';

@freezed
class ConverterEvent extends BaseEvent with _$ConverterEvent {
  const ConverterEvent._();

  const factory ConverterEvent.ratesRefreshed() = _RatesRefreshed;
}
