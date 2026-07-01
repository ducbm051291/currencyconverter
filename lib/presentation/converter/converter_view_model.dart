import 'package:currencyconverter/core/util/safe.dart';
import 'package:currencyconverter/domain/currency/repository/currency_repository.dart';
import 'package:currencyconverter/domain/currency/usecase/convert_currency_use_case.dart';
import 'package:currencyconverter/domain/currency/usecase/get_exchange_rates_use_case.dart';
import 'package:currencyconverter/presentation/common/base/base_view_model.dart';
import 'package:currencyconverter/presentation/converter/model/converter_event.dart';
import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';

class ConverterViewModel extends BaseViewModel<ConverterUiModel> {
  ConverterViewModel({
    required GetExchangeRatesUseCase getExchangeRatesUseCase,
    required ConvertCurrencyUseCase convertCurrencyUseCase,
    required CurrencyRepository currencyRepository,
  })  : _getExchangeRatesUseCase = getExchangeRatesUseCase,
        _convertCurrencyUseCase = convertCurrencyUseCase,
        _currencyRepository = currencyRepository;

  static const _safe = Safe('ConverterViewModel');
  static const _defaultTargetCurrency = 'USD';

  final GetExchangeRatesUseCase _getExchangeRatesUseCase;
  final ConvertCurrencyUseCase _convertCurrencyUseCase;
  final CurrencyRepository _currencyRepository;

  Future<void> onLaunch() => _loadRates();

  Future<void> onRefresh() => _loadRates(forceRefresh: true);

  Future<void> onSavedCurrencyChanged(String code) async {
    await _currencyRepository.setSavedCurrencyCode(code);
    final current = uiModel;
    if (current == null) {
      return;
    }
    emitLoadedState(
      _buildUiModel(
        rates: current.rates,
        lastUpdated: current.lastUpdated,
        isUsingCachedData: current.isUsingCachedData,
        savedCurrencyCode: code,
        calculatorAmount: current.calculatorAmount,
        calculatorFromCode: current.calculatorFromCode,
        calculatorToCode: current.calculatorToCode,
        searchQuery: current.searchQuery,
      ),
    );
  }

  void onCalculatorAmountChanged(String value) {
    final current = uiModel;
    if (current == null) {
      return;
    }
    final amount = double.tryParse(value) ?? 0;
    emitLoadedState(
      _buildUiModel(
        rates: current.rates,
        lastUpdated: current.lastUpdated,
        isUsingCachedData: current.isUsingCachedData,
        savedCurrencyCode: current.savedCurrencyCode,
        calculatorAmount: amount,
        calculatorFromCode: current.calculatorFromCode,
        calculatorToCode: current.calculatorToCode,
        searchQuery: current.searchQuery,
      ),
    );
  }

  void onCalculatorFromChanged(String code) {
    final current = uiModel;
    if (current == null) {
      return;
    }
    emitLoadedState(
      _buildUiModel(
        rates: current.rates,
        lastUpdated: current.lastUpdated,
        isUsingCachedData: current.isUsingCachedData,
        savedCurrencyCode: current.savedCurrencyCode,
        calculatorAmount: current.calculatorAmount,
        calculatorFromCode: code,
        calculatorToCode: current.calculatorToCode,
        searchQuery: current.searchQuery,
      ),
    );
  }

  void onCalculatorToChanged(String code) {
    final current = uiModel;
    if (current == null) {
      return;
    }
    emitLoadedState(
      _buildUiModel(
        rates: current.rates,
        lastUpdated: current.lastUpdated,
        isUsingCachedData: current.isUsingCachedData,
        savedCurrencyCode: current.savedCurrencyCode,
        calculatorAmount: current.calculatorAmount,
        calculatorFromCode: current.calculatorFromCode,
        calculatorToCode: code,
        searchQuery: current.searchQuery,
      ),
    );
  }

  void onSearchQueryChanged(String query) {
    final current = uiModel;
    if (current == null) {
      return;
    }
    emitLoadedState(
      _buildUiModel(
        rates: current.rates,
        lastUpdated: current.lastUpdated,
        isUsingCachedData: current.isUsingCachedData,
        savedCurrencyCode: current.savedCurrencyCode,
        calculatorAmount: current.calculatorAmount,
        calculatorFromCode: current.calculatorFromCode,
        calculatorToCode: current.calculatorToCode,
        searchQuery: query,
      ),
    );
  }

  Future<void> _loadRates({bool forceRefresh = false}) async {
    await _safe.runAsync(
      () async {
        emitLoadingState(uiModel: uiModel);
        final savedCurrencyCode = await _currencyRepository.getSavedCurrencyCode();

        try {
          final rates = forceRefresh
              ? await _getExchangeRatesUseCase.fetchLatestRates()
              : await _getExchangeRatesUseCase.fetchLatestRates();
          emitLoadedState(
            _buildUiModel(
              rates: rates.rates,
              lastUpdated: rates.apiDate,
              isUsingCachedData: false,
              savedCurrencyCode: savedCurrencyCode,
            ),
          );
          if (forceRefresh) {
            emitEvent(const ConverterEvent.ratesRefreshed());
          }
        } catch (_) {
          final cached = await _getExchangeRatesUseCase.getCachedRates();
          if (cached == null) {
            emitErrorState('Unable to load exchange rates. Check your connection.');
            return;
          }
          emitLoadedState(
            _buildUiModel(
              rates: cached.rates,
              lastUpdated: cached.fetchedAt,
              isUsingCachedData: true,
              savedCurrencyCode: savedCurrencyCode,
            ),
          );
        }
      },
      errorMessage: 'Load rates failed',
      onError: (error, _) => emitErrorState(error.toString()),
    );
  }

  ConverterUiModel _buildUiModel({
    required Map<String, double> rates,
    required DateTime? lastUpdated,
    required bool isUsingCachedData,
    required String savedCurrencyCode,
    double calculatorAmount = 1,
    String calculatorFromCode = _defaultTargetCurrency,
    String calculatorToCode = 'EUR',
    String searchQuery = '',
  }) {
    final savedCurrencyRate = _convertCurrencyUseCase.convert(
      amount: 1,
      fromCurrency: savedCurrencyCode,
      toCurrency: _defaultTargetCurrency,
      rates: rates,
    );

    final calculatorResult = _convertCurrencyUseCase.convert(
      amount: calculatorAmount,
      fromCurrency: calculatorFromCode,
      toCurrency: calculatorToCode,
      rates: rates,
    );

    final currencies = rates.entries
        .map(
          (entry) => CurrencyListItemUiModel(
            code: entry.key,
            rateLabel: '1 USD = ${entry.value.toStringAsFixed(4)} ${entry.key}',
          ),
        )
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    final filteredCurrencies = searchQuery.isEmpty
        ? currencies
        : currencies
            .where(
              (currency) =>
                  currency.code.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    return ConverterUiModel(
      savedCurrencyCode: savedCurrencyCode,
      savedCurrencyRate: savedCurrencyRate,
      rates: rates,
      lastUpdated: lastUpdated,
      isUsingCachedData: isUsingCachedData,
      calculatorAmount: calculatorAmount,
      calculatorFromCode: calculatorFromCode,
      calculatorToCode: calculatorToCode,
      calculatorResult: calculatorResult,
      currencies: filteredCurrencies,
      searchQuery: searchQuery,
    );
  }
}
