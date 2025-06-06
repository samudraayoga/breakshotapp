import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'shop_dashboard.dart';

class ShopDashboardPage extends StatelessWidget {
  final List<InventoryItem> shopItems;
  final double? balance;
  final List<InventoryItem> cartItems;
  final void Function(int) onAddToCart;
  final VoidCallback onShowCartDialog;

  const ShopDashboardPage({
    super.key,
    required this.shopItems,
    required this.balance,
    required this.cartItems,
    required this.onAddToCart,
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
          showOrderHistoryDialog: () {},
          showCartDialog: onShowCartDialog,
        ),
      ),
    );
  }
}
