import 'package:flutter/material.dart';
import '../utils/format_utils.dart';
import 'real_time_clock.dart';

class HomeContent extends StatelessWidget {
  final String? name;
  final String affirmation;
  final num? balance;
  final String selectedCurrency;
  final Map<String, String> currencySymbols;
  final Map<String, double> currencyRates;
  final VoidCallback onShowTopUpDialog;
  final Function(String?) onCurrencyChanged;
  final Widget shopDashboard;

  const HomeContent({
    super.key,
    required this.name,
    required this.affirmation,
    required this.balance,
    required this.selectedCurrency,
    required this.currencySymbols,
    required this.currencyRates,
    required this.onShowTopUpDialog,
    required this.onCurrencyChanged,
    required this.shopDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RealTimeClock(zona: 'WIB'),
          const SizedBox(height: 24),
          Text(
            'Hi, ${name ?? 'User'}! Selamat datang di BreakShot!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)]),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 32),
          Card(
            color: const Color.fromARGB(255, 46, 204, 113),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Anda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatCurrency(balance ?? 0, selectedCurrency, currencySymbols, currencyRates),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: selectedCurrency,
                        dropdownColor: Colors.white,
                        items: currencySymbols.keys.map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(code, style: const TextStyle(color: Colors.black)),
                        )).toList(),
                        onChanged: onCurrencyChanged,
                        underline: Container(),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onShowTopUpDialog,
                    child: const Text('Top Up Saldo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color.fromARGB(255, 46, 204, 113), // Warna hijau cerah
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kata-kata hari ini sebelum main billiard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.format_quote, color: Colors.deepPurple, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          affirmation,
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          shopDashboard,
        ],
      ),
    );
  }
}
