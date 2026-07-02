import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:currencyconverter/presentation/converter/model/converter_ui_model.dart';
import 'package:currencyconverter/presentation/converter/widget/currency_picker_sheet.dart';

class CalculatorSection extends StatefulWidget {
  const CalculatorSection({
    required this.uiModel,
    required this.onAmountChanged,
    required this.onFromChanged,
    required this.onToChanged,
    super.key,
  });

  final ConverterUiModel uiModel;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;

  @override
  State<CalculatorSection> createState() => _CalculatorSectionState();
}

class _CalculatorSectionState extends State<CalculatorSection> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.uiModel.calculatorAmount.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant CalculatorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextAmount = widget.uiModel.calculatorAmount.toString();
    if (_amountController.text != nextAmount &&
        oldWidget.uiModel.calculatorAmount != widget.uiModel.calculatorAmount) {
      _amountController.text = nextAmount;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final codes = widget.uiModel.rates.keys.toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calculator', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: widget.onAmountChanged,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CurrencySelectorField(
                    label: 'From',
                    value: widget.uiModel.calculatorFromCode,
                    codes: codes,
                    onChanged: widget.onFromChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CurrencySelectorField(
                    label: 'To',
                    value: widget.uiModel.calculatorToCode,
                    codes: codes,
                    onChanged: widget.onToChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.uiModel.calculatorAmount} ${widget.uiModel.calculatorFromCode} = '
              '${widget.uiModel.calculatorResult.toStringAsFixed(4)} '
              '${widget.uiModel.calculatorToCode}',
              style: theme.textTheme.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySelectorField extends StatelessWidget {
  const _CurrencySelectorField({
    required this.label,
    required this.value,
    required this.codes,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> codes;
  final ValueChanged<String> onChanged;

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showCurrencyPickerSheet(
      context,
      codes: codes,
      selectedCode: value,
      suggestedCodes: suggestedCodesFor(codes),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
}
