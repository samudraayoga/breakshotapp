import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/user_service.dart';

class ShopDashboard extends StatelessWidget {
  final List<InventoryItem> shopItems;
  final double? balance;
  final void Function(int) addToCart;
  final void Function() showOrderHistoryDialog;
  final void Function() showCartDialog;

  const ShopDashboard({
    super.key,
    required this.shopItems,
    required this.balance,
    required this.addToCart,
    required this.showOrderHistoryDialog,
    required this.showCartDialog,
  });

  String formatRupiah(num value) {
    return 'Rp${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 46, 204, 113), size: 32),
                  const SizedBox(width: 8),
                  const Text('Dashboard Shopping', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)])),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Riwayat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 46, 204, 113),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: showOrderHistoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Saldo: ${formatRupiah(balance ?? 0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Atur tinggi sesuai kebutuhan UI
                child: shopItems.isEmpty
                    ? const Center(child: Text('Belum ada barang', style: TextStyle(color: Colors.white70)))
                    : ListView.separated(
                        itemCount: shopItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = shopItems[i];
                          return Card(
                            color: Colors.blueGrey[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: ListTile(
                              leading: item.imagePath != null && item.imagePath!.isNotEmpty
                                  ? Image.network(item.imagePath!, width: 48, height: 48, fit: BoxFit.cover)
                                  : const Icon(Icons.inventory, size: 40, color: Colors.grey),
                              title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)])),
                              subtitle: Text('Kode: ${item.kode} | Stok: ${item.jumlah} | Harga: ${formatRupiah(item.harga)}', style: const TextStyle(color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)])),
                              trailing: ElevatedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Keranjang'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(255, 46, 204, 113),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: item.jumlah > 0 ? () => addToCart(i) : null,
                              ),
                              onTap: () async {
                                final ownerUsername = item.ownerUsername;
                                final owner = await UserService.getUserByUsername(ownerUsername);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(item.nama),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (item.imagePath != null && item.imagePath!.isNotEmpty)
                                          Image.network(item.imagePath!, width: 120, height: 120, fit: BoxFit.cover),
                                        const SizedBox(height: 12),
                                        Text('Kode: ${item.kode}'),
                                        Text('Stok: ${item.jumlah}'),
                                        Text('Harga: ${formatRupiah(item.harga)}'),
                                        Text('Jenis: ${item.jenis}'),
                                        const Divider(),
                                        Text('Dijual oleh: ${owner?.name ?? ownerUsername}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Tutup'),
                                      ),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.add_shopping_cart),
                                        label: const Text('Tambah ke Keranjang'),
                                        onPressed: item.jumlah > 0 ? () {
                                          addToCart(i);
                                          Navigator.of(context).pop();
                                        } : null,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            backgroundColor: Color.fromARGB(255, 46, 204, 113),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Keranjang'),
            onPressed: showCartDialog,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}
