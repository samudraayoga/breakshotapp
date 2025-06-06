import 'package:flutter/material.dart';

class TopUpDialog extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTopUp;
  const TopUpDialog({super.key, required this.controller, required this.onTopUp});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Top Up Saldo'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Jumlah Top Up (Rp)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: onTopUp,
          child: const Text('Top Up'),
        ),
      ],
    );
  }
}
