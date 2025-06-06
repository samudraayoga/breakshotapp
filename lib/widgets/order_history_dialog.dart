import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderHistoryDialog extends StatelessWidget {
  final List<Order> orderHistory;
  const OrderHistoryDialog({super.key, required this.orderHistory});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Riwayat Pesanan'),
      content: SizedBox(
        width: 350,
        child: orderHistory.isEmpty
            ? const Text('Belum ada riwayat pesanan.')
            : SizedBox(
                height: 350,
                child: ListView.separated(
                  itemCount: orderHistory.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final order = orderHistory[i];
                    final date = order.date;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal: ${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...order.items.map((item) => Text('- ${item['nama']} x${item['qty']} (Rp${item['harga']})')),
                        Text('Total: Rp${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
