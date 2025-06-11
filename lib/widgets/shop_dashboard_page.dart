import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'shop_dashboard.dart';

class ShopDashboardPage extends StatelessWidget {
  final List<InventoryItem> shopItems;
  final double? balance;
  final List<InventoryItem> cartItems;
  final void Function(int) onAddToCart;
  final void Function(int) onRemoveFromCart;
  final VoidCallback onShowCartDialog;

  const ShopDashboardPage({
    super.key,
    required this.shopItems,
    required this.balance,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onShowCartDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Shopping'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ShopDashboard(
          shopItems: shopItems,
          balance: balance,
          addToCart: onAddToCart,
          onRemoveFromCart: onRemoveFromCart,
          getCartQty: (int i) {
            final item = shopItems[i];
            final idx = cartItems.indexWhere((e) => e.kode == item.kode);
            return idx != -1 ? cartItems[idx].jumlah : 0;
          },
          showOrderHistoryDialog: () {},
          showCartDialog: onShowCartDialog,
        ),
      ),
    );
  }
}
