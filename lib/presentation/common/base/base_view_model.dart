import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:currencyconverter/presentation/common/base/base_event.dart';
import 'package:currencyconverter/presentation/common/base/base_view_state.dart';

abstract class BaseViewModel<UI_MODEL> extends Cubit<BaseViewState<UI_MODEL>> {
  BaseViewModel() : super(const BaseViewState.initial());

  final StreamController<BaseEvent> _events =
      StreamController<BaseEvent>.broadcast();

  Stream<BaseEvent> get events => _events.stream;

  UI_MODEL? get uiModel => state.uiModel;

  @protected
  void emitEvent(BaseEvent event) {
    if (!_events.isClosed) {
      _events.add(event);
    }
  }

  @protected
  void emitState(BaseViewState<UI_MODEL> state) {
    if (!isClosed) {
      emit(state);
    }
  }

  @protected
  void emitErrorEvent(Object error) => emitEvent(ErrorEvent(error));

  @protected
  void emitLoadingState({UI_MODEL? uiModel}) =>
      emitState(BaseViewState.loading(uiModel: uiModel));

  @protected
  void emitLoadedState(UI_MODEL uiModel) =>
      emitState(BaseViewState.loaded(uiModel));

  @protected
  void emitErrorState(Object error) => emitState(BaseViewState.error(error));

  @mustCallSuper
  @override
  Future<void> close() {
    _events.close();
    return super.close();
  }
}
