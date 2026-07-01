import 'package:currencyconverter/data/currency/repository/default_currency_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks/mock_util.dart';
import '../../../mocks/test_data_util.dart';

void main() {
  late DefaultCurrencyRepository repository;
  late MockCurrencyRemoteDataSource remoteDataSource;
  late MockCurrencyLocalDataSource localDataSource;

  setUp(() {
    remoteDataSource = MockCurrencyRemoteDataSource();
    localDataSource = MockCurrencyLocalDataSource();
    repository = DefaultCurrencyRepository(
      remoteDataSource,
      localDataSource,
    );
  });

  group('DefaultCurrencyRepository', () {
    group('when fetchLatestRates is called', () {
      group('and remote call succeeds', () {
        test('persists rates and returns fresh model', () async {
          final rates = TestDataUtil.sampleExchangeRate();
          when(() => remoteDataSource.getLatestRates()).thenAnswer((_) async => rates);
          when(() => localDataSource.saveRates(rates)).thenAnswer((_) async {});

          final result = await repository.fetchLatestRates();

          expect(result, rates);
          verify(() => localDataSource.saveRates(rates)).called(1);
        });
      });
    });

    group('when getCachedRates is called', () {
      test('returns cached model from local data source', () async {
        final cached = TestDataUtil.sampleExchangeRate(isFromCache: true);
        when(() => localDataSource.getCachedRates()).thenAnswer((_) async => cached);

        final result = await repository.getCachedRates();

        expect(result, cached);
      });
    });

    group('when getSavedCurrencyCode is called', () {
      test('returns saved code from local data source', () async {
        when(() => localDataSource.getSavedCurrencyCode()).thenAnswer((_) async => 'JPY');

        final result = await repository.getSavedCurrencyCode();

        expect(result, 'JPY');
      });
    });
  });
}
