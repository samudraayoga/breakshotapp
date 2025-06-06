import 'package:intl/intl.dart';

String formatRupiah(num value) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  return formatter.format(value);
}

String formatCurrency(num value, String selectedCurrency, Map<String, String> currencySymbols, Map<String, double> currencyRates) {
  final symbol = currencySymbols[selectedCurrency] ?? 'Rp';
  final rate = currencyRates[selectedCurrency] ?? 1.0;
  final converted = value * rate;
  if (selectedCurrency == 'IDR') {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: symbol, decimalDigits: 0);
    return formatter.format(value);
  } else {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: symbol, decimalDigits: 2);
    return formatter.format(converted);
  }
}
