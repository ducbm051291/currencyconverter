import 'package:currencyconverter/data/currency/data_source/local/app_database.dart';
import 'package:currencyconverter/data/currency/data_source/remote/currency_api_service.dart';
import 'package:currencyconverter/data/currency/data_source/remote/currency_remote_data_source.dart';
import 'package:currencyconverter/domain/currency/repository/currency_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

class MockCurrencyRemoteDataSource extends Mock
    implements CurrencyRemoteDataSource {}

class MockCurrencyLocalDataSource extends Mock
    implements CurrencyLocalDataSource {}

class MockCurrencyApiService extends Mock implements CurrencyApiService {}
