import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_view_state.freezed.dart';

@freezed
class BaseViewState<T> with _$BaseViewState<T> {
  const factory BaseViewState.initial() = _Initial<T>;

  const factory BaseViewState.loading({T? uiModel}) = _Loading<T>;

  const factory BaseViewState.loaded(T uiModel) = _Loaded<T>;

  const factory BaseViewState.error(Object error) = _Error<T>;
}

extension BaseViewStateExtensions<T> on BaseViewState<T> {
  bool get isLoading => maybeWhen(loading: (_) => true, orElse: () => false);

  T? get uiModel => maybeWhen(
        loading: (uiModel) => uiModel,
        loaded: (uiModel) => uiModel,
        orElse: () => null,
      );
}
