import 'package:flutter/material.dart';

import 'package:currencyconverter/app/app.dart';
import 'package:currencyconverter/core/di/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureInjection();
  runApp(const CurrencyConverterApp());
}
