import 'package:flutter/material.dart';

const kSuggestedCurrencyCodes = [
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'CAD',
  'AUD',
  'CHF',
  'CNY',
  'VND',
];

List<String> suggestedCodesFor(List<String> allCodes) =>
    kSuggestedCurrencyCodes.where(allCodes.contains).toList();

Future<String?> showCurrencyPickerSheet(
  BuildContext context, {
  required List<String> codes,
  String? selectedCode,
  List<String> suggestedCodes = const [],
}) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CurrencyPickerSheet(
        codes: codes,
        selectedCode: selectedCode,
        suggestedCodes: suggestedCodes,
      ),
    );

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    required this.codes,
    this.selectedCode,
    this.suggestedCodes = const [],
    super.key,
  });

  final List<String> codes;
  final String? selectedCode;
  final List<String> suggestedCodes;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _sortedCodes => widget.codes.toList()..sort();

  List<String> get _suggestedCodes {
    final available = _sortedCodes.toSet();
    return widget.suggestedCodes
        .where(available.contains)
        .toSet()
        .toList();
  }

  List<String> get _filteredCodes {
    final suggested = _suggestedCodes.toSet();
    final remaining = _sortedCodes
        .where((code) => !suggested.contains(code))
        .where(_matchesQuery)
        .toList();

    if (_query.isEmpty) {
      return remaining;
    }

    return _sortedCodes.where(_matchesQuery).toList();
  }

  bool _matchesQuery(String code) =>
      code.toLowerCase().contains(_query.toLowerCase());

  void _onSearchChanged(String value) => setState(() => _query = value.trim());

  void _select(String code) => Navigator.of(context).pop(code);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showSuggested = _query.isEmpty && _suggestedCodes.isNotEmpty;
    final filteredCodes = _filteredCodes;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select currency', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Search currency code',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                if (showSuggested) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Suggested',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  ..._suggestedCodes.map(_buildTile),
                  const Divider(height: 24),
                ],
                if (filteredCodes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No currencies found')),
                  )
                else
                  ...filteredCodes.map(_buildTile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(String code) {
    final isSelected = code == widget.selectedCode;

    return ListTile(
      title: Text(code),
      trailing: isSelected ? const Icon(Icons.check) : null,
      selected: isSelected,
      onTap: () => _select(code),
    );
  }
}
