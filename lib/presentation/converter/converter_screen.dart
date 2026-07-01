import 'package:flutter/material.dart';

import 'package:currencyconverter/core/di/di.dart';
import 'package:currencyconverter/domain/currency/repository/currency_repository.dart';
import 'package:currencyconverter/domain/currency/usecase/convert_currency_use_case.dart';
import 'package:currencyconverter/domain/currency/usecase/get_exchange_rates_use_case.dart';
import 'package:currencyconverter/presentation/common/base/base_event.dart';
import 'package:currencyconverter/presentation/common/base/base_screen.dart';
import 'package:currencyconverter/presentation/common/base/base_view_state.dart';
import 'package:currencyconverter/presentation/converter/converter_view_model.dart';
import 'package:currencyconverter/presentation/converter/model/converter_event.dart';
import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';
import 'package:currencyconverter/presentation/converter/widget/calculator_section.dart';
import 'package:currencyconverter/presentation/converter/widget/currency_list_section.dart';
import 'package:currencyconverter/presentation/converter/widget/offline_status_banner.dart';
import 'package:currencyconverter/presentation/converter/widget/saved_currency_header.dart';

class ConverterScreen extends BaseScreen<ConverterViewModel> {
  const ConverterScreen({super.key});

  @override
  ConverterViewModel buildViewModel(BuildContext context) => ConverterViewModel(
        getExchangeRatesUseCase: GetExchangeRatesUseCase(
          getIt<CurrencyRepository>(),
        ),
        convertCurrencyUseCase: const ConvertCurrencyUseCase(),
        currencyRepository: getIt<CurrencyRepository>(),
      );

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState
    extends BaseScreenState<ConverterScreen, ConverterViewModel, ConverterUiModel> {
  @override
  void initState() {
    super.initState();
    viewModel.onLaunch();
  }

  @override
  void onEvent(BaseEvent event) {
    switch (event) {
      case ConverterEvent():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rates refreshed')),
        );
      case ErrorEvent(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
    }
  }

  @override
  Widget buildScreen(BuildContext context, BaseViewState<ConverterUiModel> state) =>
      Scaffold(
        appBar: AppBar(
          title: const Text('Currency Converter'),
          actions: [
            IconButton(
              onPressed: viewModel.onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh rates',
            ),
          ],
        ),
        body: state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: (_) => const Center(child: CircularProgressIndicator()),
          loaded: (uiModel) => RefreshIndicator(
            onRefresh: viewModel.onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: OfflineStatusBanner(
                    lastUpdated: uiModel.lastUpdated,
                    isUsingCachedData: uiModel.isUsingCachedData,
                  ),
                ),
                SliverToBoxAdapter(
                  child: SavedCurrencyHeader(
                    uiModel: uiModel,
                    onChangeSavedCurrency: viewModel.onSavedCurrencyChanged,
                  ),
                ),
                SliverToBoxAdapter(
                  child: CalculatorSection(
                    uiModel: uiModel,
                    onAmountChanged: viewModel.onCalculatorAmountChanged,
                    onFromChanged: viewModel.onCalculatorFromChanged,
                    onToChanged: viewModel.onCalculatorToChanged,
                  ),
                ),
                SliverToBoxAdapter(
                  child: CurrencyListSection(
                    uiModel: uiModel,
                    onSearchChanged: viewModel.onSearchQueryChanged,
                  ),
                ),
                SliverList.separated(
                  itemCount: uiModel.currencies.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final currency = uiModel.currencies[index];
                    return ListTile(
                      title: Text(currency.code),
                      subtitle: Text(currency.rateLabel),
                    );
                  },
                ),
              ],
            ),
          ),
          error: (error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: viewModel.onLaunch,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
