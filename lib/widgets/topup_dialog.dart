import 'package:flutter/material.dart';

class TopUpDialog extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onTopUp;
  const TopUpDialog({super.key, required this.controller, required this.onTopUp});

  @override
  State<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends State<TopUpDialog> {
  String? _errorText;
  static const double maxTopUp = 9999999999;

  void _validate(String value) {
    value = value.trim();
    if (value.isEmpty) {
      setState(() => _errorText = 'Jumlah tidak boleh kosong');
      return;
    }
    if (!RegExp(r'^[0-9]+').hasMatch(value)) {
      setState(() => _errorText = 'Hanya boleh angka bulat');
      return;
    }
    final numValue = int.tryParse(value.replaceAll('.', '')) ?? 0;
    if (numValue <= 0) {
      setState(() => _errorText = 'Jumlah harus lebih dari 0');
      return;
    }
    if (numValue > maxTopUp) {
      setState(() => _errorText = 'Maksimal top up Rp9.999.999.999');
      return;
    }
    setState(() => _errorText = null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Top Up Saldo'),
      content: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Jumlah Top Up (Rp)',
          errorText: _errorText,
        ),
        onChanged: _validate,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _errorText != null ? null : () {
            final value = widget.controller.text.trim();
            if (value.isEmpty) {
              setState(() => _errorText = 'Jumlah tidak boleh kosong');
              return;
            }
            if (!RegExp(r'^[0-9]+').hasMatch(value)) {
              setState(() => _errorText = 'Hanya boleh angka bulat');
              return;
            }
            final numValue = int.tryParse(value.replaceAll('.', '')) ?? 0;
            if (numValue <= 0) {
              setState(() => _errorText = 'Jumlah harus lebih dari 0');
              return;
            }
            if (numValue > maxTopUp) {
              setState(() => _errorText = 'Maksimal top up Rp9.999.999.999');
              return;
            }
            widget.onTopUp();
          },
          child: const Text('Top Up'),
        ),
      ],
    );
  }
}
