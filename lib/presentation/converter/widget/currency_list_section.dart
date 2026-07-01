import 'package:flutter/material.dart';

import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';

class CurrencyListSection extends StatelessWidget {
  const CurrencyListSection({
    required this.uiModel,
    required this.onSearchChanged,
    super.key,
  });

  final ConverterUiModel uiModel;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('All Currencies', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search currency code',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }
}
