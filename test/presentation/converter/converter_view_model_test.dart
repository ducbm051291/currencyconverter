import 'package:bloc_test/bloc_test.dart';
import 'package:currencyconverter/domain/currency/usecase/convert_currency_use_case.dart';
import 'package:currencyconverter/domain/currency/usecase/get_exchange_rates_use_case.dart';
import 'package:currencyconverter/presentation/common/base/base_view_state.dart';
import 'package:currencyconverter/presentation/converter/converter_view_model.dart';
import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_util.dart';
import '../../mocks/test_data_util.dart';

void main() {
  late MockCurrencyRepository repository;

  setUp(() {
    repository = MockCurrencyRepository();
  });

  ConverterViewModel buildViewModel() => ConverterViewModel(
        getExchangeRatesUseCase: GetExchangeRatesUseCase(repository),
        convertCurrencyUseCase: const ConvertCurrencyUseCase(),
        currencyRepository: repository,
      );

  group('ConverterViewModel', () {
    group('when onLaunch is called', () {
      group('and remote fetch succeeds', () {
        blocTest<ConverterViewModel, BaseViewState<ConverterUiModel>>(
          'emits loaded state with fresh data',
          build: () {
            when(() => repository.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');
            when(() => repository.fetchLatestRates()).thenAnswer(
              (_) async => TestDataUtil.sampleExchangeRate(),
            );
            return buildViewModel();
          },
          act: (viewModel) => viewModel.onLaunch(),
          expect: () => [
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.isLoading,
              'loading',
              true,
            ),
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.maybeWhen(
                loaded: (uiModel) => uiModel.isUsingCachedData,
                orElse: () => null,
              ),
              'isUsingCachedData',
              false,
            ),
          ],
        );
      });

      group('and remote fetch fails with cache available', () {
        blocTest<ConverterViewModel, BaseViewState<ConverterUiModel>>(
          'emits loaded state with cached data',
          build: () {
            when(() => repository.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');
            when(() => repository.fetchLatestRates()).thenThrow(
              DioException(
                requestOptions: RequestOptions(),
                type: DioExceptionType.connectionError,
              ),
            );
            when(() => repository.getCachedRates()).thenAnswer(
              (_) async => TestDataUtil.sampleExchangeRate(isFromCache: true),
            );
            return buildViewModel();
          },
          act: (viewModel) => viewModel.onLaunch(),
          expect: () => [
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.isLoading,
              'loading',
              true,
            ),
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.maybeWhen(
                loaded: (uiModel) => uiModel.isUsingCachedData,
                orElse: () => null,
              ),
              'isUsingCachedData',
              true,
            ),
          ],
        );
      });

      group('and remote fetch fails without cache', () {
        blocTest<ConverterViewModel, BaseViewState<ConverterUiModel>>(
          'emits error state',
          build: () {
            when(() => repository.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');
            when(() => repository.fetchLatestRates()).thenThrow(
              DioException(
                requestOptions: RequestOptions(),
                type: DioExceptionType.connectionError,
              ),
            );
            when(() => repository.getCachedRates()).thenAnswer((_) async => null);
            return buildViewModel();
          },
          act: (viewModel) => viewModel.onLaunch(),
          expect: () => [
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.isLoading,
              'loading',
              true,
            ),
            isA<BaseViewState<ConverterUiModel>>().having(
              (state) => state.maybeWhen(error: (_) => true, orElse: () => false),
              'isError',
              true,
            ),
          ],
        );
      });
    });

    group('when onCalculatorAmountChanged is called', () {
      blocTest<ConverterViewModel, BaseViewState<ConverterUiModel>>(
        'updates calculator result',
        build: () {
          when(() => repository.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');
          when(() => repository.fetchLatestRates()).thenAnswer(
            (_) async => TestDataUtil.sampleExchangeRate(),
          );
          return buildViewModel();
        },
        act: (viewModel) async {
          await viewModel.onLaunch();
          viewModel.onCalculatorAmountChanged('10');
        },
        verify: (viewModel) {
          final uiModel = viewModel.uiModel;
          expect(uiModel?.calculatorAmount, 10);
          expect(uiModel?.calculatorResult, greaterThan(0));
        },
      );
    });

    group('when onSearchQueryChanged is called', () {
      blocTest<ConverterViewModel, BaseViewState<ConverterUiModel>>(
        'filters currencies by code',
        build: () {
          when(() => repository.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');
          when(() => repository.fetchLatestRates()).thenAnswer(
            (_) async => TestDataUtil.sampleExchangeRate(),
          );
          return buildViewModel();
        },
        act: (viewModel) async {
          await viewModel.onLaunch();
          viewModel.onSearchQueryChanged('JP');
        },
        verify: (viewModel) {
          final currencies = viewModel.uiModel?.currencies ?? [];
          expect(currencies, hasLength(1));
          expect(currencies.first.code, 'JPY');
          expect(viewModel.uiModel?.searchQuery, 'JP');
        },
      );
    });
  });
}
