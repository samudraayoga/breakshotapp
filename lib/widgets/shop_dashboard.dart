import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/inventory_item.dart';
import '../services/user_service.dart';
import '../utils/format_utils.dart';

class ShopDashboard extends StatefulWidget {
  final List<InventoryItem> shopItems;
  final double? balance;
  final void Function(int) addToCart;
  final void Function(int) onRemoveFromCart;
  final int Function(int) getCartQty;
  final void Function() showOrderHistoryDialog;
  final void Function() showCartDialog;

  const ShopDashboard({
    super.key,
    required this.shopItems,
    required this.balance,
    required this.addToCart,
    required this.onRemoveFromCart,
    required this.getCartQty,
    required this.showOrderHistoryDialog,
    required this.showCartDialog,
  });

  @override
  State<ShopDashboard> createState() => _ShopDashboardState();
}

class _ShopDashboardState extends State<ShopDashboard> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter barang: hanya tampilkan yang stok > 0 dan sesuai query
    final filteredShopItems = widget.shopItems
        .where((item) => item.jumlah > 0 &&
            (item.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.kode.toLowerCase().contains(_searchQuery.toLowerCase())))
        .toList();
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
                    onPressed: widget.showOrderHistoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Saldo: ${formatRupiah(widget.balance ?? 0)}',
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
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ketik nama atau kode barang...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 400, // Atur tinggi sesuai kebutuhan UI
                child: filteredShopItems.isEmpty
                    ? const Center(child: Text('Belum ada barang bos', style: TextStyle(color: Colors.white70)))
                    : ListView.separated(
                        itemCount: filteredShopItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final item = filteredShopItems[i];
                          final idx = widget.shopItems.indexOf(item);
                          final qtyInCart = widget.getCartQty(idx);
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, color: Colors.redAccent),
                                    onPressed: qtyInCart > 0 ? () => widget.onRemoveFromCart(idx) : null,
                                  ),
                                  Text(qtyInCart.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Colors.greenAccent),
                                    onPressed: item.jumlah > 0 ? () => widget.addToCart(idx) : null,
                                  ),
                                ],
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
                                          Image.network(item.imagePath!, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                        const SizedBox(height: 12),
                                        Text('Kode: ${item.kode}'),
                                        Text('Stok: ${item.jumlah}'),
                                        Text('Harga: ${formatRupiah(item.harga)}'),
                                        Text('Jenis: ${item.jenis}'),
                                        const Divider(),
                                        Text('Dijual oleh: ${owner?.name ?? ownerUsername}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        // NOTE: Pastikan file assets/wa_icon.png sudah ada di folder assets dan didaftarkan di pubspec.yaml
                                        // Jika belum ada, gunakan Icons.chat sebagai fallback
                                        if (owner?.phone != null && owner!.phone.isNotEmpty)
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.chat, color: Colors.white),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            label: const Text('Hubungi via WhatsApp'),
                                            onPressed: () async {
                                              final phone = owner.phone.replaceAll(RegExp(r'[^0-9]'), '');
                                              final waUrl = Uri.parse('https://wa.me/$phone');
                                              if (await canLaunchUrl(waUrl)) {
                                                await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Tidak dapat membuka WhatsApp.')),
                                                );
                                              }
                                            },
                                          )
                                        else
                                          const Text('Nomor WhatsApp penjual gaada cik', style: TextStyle(color: Colors.redAccent)),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Tutup'),
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
            onPressed: widget.showCartDialog,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}
