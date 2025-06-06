import 'dart:io';
import 'package:flutter/material.dart';

class ShopCartDialog extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double cartTotal;
  final void Function(int, int) onQtyChanged;
  final void Function(int) onRemove;
  final VoidCallback onCheckout;
  const ShopCartDialog({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    required this.onQtyChanged,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Keranjang Belanja'),
      content: SizedBox(
        width: 350,
        child: cartItems.isEmpty
            ? const Text('Keranjang kosong.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...cartItems.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return ListTile(
                      leading: item['imagePath'] != null && item['imagePath'].toString().isNotEmpty
                          ? (item['imagePath'].toString().startsWith('http')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imagePath'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(item['imagePath']),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ))
                          : const Icon(Icons.inventory, size: 32, color: Colors.grey),
                      title: Text(item['nama']),
                      subtitle: Text('x${item['qty']} | Rp${item['harga']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: item['qty'] > 1
                                ? () => onQtyChanged(i, item['qty'] - 1)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => onQtyChanged(i, item['qty'] + 1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onRemove(i),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Total: Rp${cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
        ElevatedButton(
          onPressed: cartItems.isNotEmpty ? onCheckout : null,
          child: const Text('Checkout'),
        ),
      ],
    );
  }
}
