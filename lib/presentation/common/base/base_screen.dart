import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currencyconverter/presentation/common/base/base_event.dart';
import 'package:currencyconverter/presentation/common/base/base_view_model.dart';
import 'package:currencyconverter/presentation/common/base/base_view_state.dart';

abstract class BaseScreen<VM extends BaseViewModel<dynamic>> extends StatefulWidget {
  const BaseScreen({super.key});

  VM buildViewModel(BuildContext context);
}

abstract class BaseScreenState<
    SCREEN extends BaseScreen<VM>,
    VM extends BaseViewModel<UI_MODEL>,
    UI_MODEL>
    extends State<SCREEN> {
  late final VM _viewModel;
  late final StreamSubscription<BaseEvent> _eventSubscription;

  @protected
  VM get viewModel => _viewModel;

  void onEvent(BaseEvent event);

  Widget buildScreen(BuildContext context, BaseViewState<UI_MODEL> state);

  @override
  void initState() {
    super.initState();
    _viewModel = widget.buildViewModel(context);
    _eventSubscription = _viewModel.events.listen((event) {
      if (mounted) {
        onEvent(event);
      }
    });
  }

  @mustCallSuper
  @override
  void dispose() {
    _eventSubscription.cancel();
    _viewModel.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _viewModel,
        child: BlocBuilder<VM, BaseViewState<UI_MODEL>>(
          builder: buildScreen,
        ),
      );
}
