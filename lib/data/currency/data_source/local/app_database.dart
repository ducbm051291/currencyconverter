import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:currencyconverter/domain/currency/model/exchange_rate_model.dart';

part 'app_database.g.dart';

class ExchangeRatesTable extends Table {
  IntColumn get id => integer()();

  TextColumn get base => text()();

  TextColumn get ratesJson => text()();

  TextColumn get apiDate => text()();

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class UserPreferencesTable extends Table {
  IntColumn get id => integer()();

  TextColumn get savedCurrencyCode => text().withDefault(const Constant('JPY'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [ExchangeRatesTable, UserPreferencesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'currency_converter.sqlite'));
      return NativeDatabase.createInBackground(file);
    });

abstract class CurrencyLocalDataSource {
  Future<void> saveRates(ExchangeRateModel model);

  Future<ExchangeRateModel?> getCachedRates();

  Future<String> getSavedCurrencyCode();

  Future<void> setSavedCurrencyCode(String code);
}

@Injectable(as: CurrencyLocalDataSource)
class DefaultCurrencyLocalDataSource implements CurrencyLocalDataSource {
  DefaultCurrencyLocalDataSource(this._database);

  final AppDatabase _database;

  static const _singletonId = 1;

  @override
  Future<void> saveRates(ExchangeRateModel model) async {
    await _database.into(_database.exchangeRatesTable).insertOnConflictUpdate(
          ExchangeRatesTableCompanion.insert(
            id: const Value(_singletonId),
            base: model.base,
            ratesJson: jsonEncode(model.rates),
            apiDate: model.apiDate.toIso8601String(),
            fetchedAt: model.fetchedAt,
          ),
        );
  }

  @override
  Future<ExchangeRateModel?> getCachedRates() async {
    final row = await (_database.select(_database.exchangeRatesTable)
          ..where((table) => table.id.equals(_singletonId)))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    final rates = (jsonDecode(row.ratesJson) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExchangeRateModel(
      base: row.base,
      rates: rates,
      apiDate: DateTime.parse(row.apiDate),
      fetchedAt: row.fetchedAt,
      isFromCache: true,
    );
  }

  @override
  Future<String> getSavedCurrencyCode() async {
    final row = await (_database.select(_database.userPreferencesTable)
          ..where((table) => table.id.equals(_singletonId)))
        .getSingleOrNull();

    if (row == null) {
      await _database.into(_database.userPreferencesTable).insert(
            UserPreferencesTableCompanion.insert(
              id: const Value(_singletonId),
            ),
          );
      return 'JPY';
    }

    return row.savedCurrencyCode;
  }

  @override
  Future<void> setSavedCurrencyCode(String code) async {
    await _database.into(_database.userPreferencesTable).insertOnConflictUpdate(
          UserPreferencesTableCompanion.insert(
            id: const Value(_singletonId),
            savedCurrencyCode: Value(code),
          ),
        );
  }
}

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase appDatabase() => AppDatabase();
}
