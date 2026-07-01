import 'package:flutter/material.dart';

import 'package:currencyconverter/app/theme/app_theme.dart';
import 'package:currencyconverter/presentation/converter/converter_screen.dart';

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Currency Converter',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const ConverterScreen(),
      );
}
