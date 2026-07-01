import 'package:flutter/material.dart';

import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';

class SavedCurrencyHeader extends StatelessWidget {
  const SavedCurrencyHeader({
    required this.uiModel,
    required this.onChangeSavedCurrency,
    super.key,
  });

  final ConverterUiModel uiModel;
  final ValueChanged<String> onChangeSavedCurrency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Currency',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '1 ${uiModel.savedCurrencyCode} = '
              '${uiModel.savedCurrencyRate.toStringAsFixed(6)} '
              '${uiModel.targetCurrencyCode}',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => _showCurrencyPicker(context),
              child: Text('Change saved currency (${uiModel.savedCurrencyCode})'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCurrencyPicker(BuildContext context) async {
    final codes = uiModel.rates.keys.toList()..sort();
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CurrencyPickerSheet(codes: codes),
    );

    if (selected != null) {
      onChangeSavedCurrency(selected);
    }
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({required this.codes});

  final List<String> codes;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView.builder(
          controller: scrollController,
          itemCount: codes.length,
          itemBuilder: (context, index) {
            final code = codes[index];
            return ListTile(
              title: Text(code),
              onTap: () => Navigator.of(context).pop(code),
            );
          },
        ),
      );
}
