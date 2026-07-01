class ConvertCurrencyUseCase {
  const ConvertCurrencyUseCase();

  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required Map<String, double> rates,
  }) {
    if (amount == 0 || fromCurrency == toCurrency) {
      return amount;
    }

    final fromRate = rates[fromCurrency];
    final toRate = rates[toCurrency];

    if (fromRate == null || toRate == null || fromRate == 0) {
      throw ArgumentError('Unsupported currency code');
    }

    final usdAmount = amount / fromRate;
    return usdAmount * toRate;
  }
}
