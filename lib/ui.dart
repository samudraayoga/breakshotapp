import 'package:flutter/material.dart';
import 'widgets/home_content.dart';
import 'widgets/shop_dashboard_page.dart';
import 'widgets/map_content.dart';
import 'widgets/profile_content.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'models/inventory_item.dart';

/// UI for the customer HomePage. All widget tree and build method are here.
/// Logic, state, and function definitions remain in home.dart.
class CustomerHomeUI extends StatelessWidget {
  final int selectedIndex;
  final ThemeData theme;
  final String? name;
  final double? balance;
  final String affirmation;
  final String selectedCurrency;
  final Map<String, String> currencySymbols;
  final Map<String, double> currencyRates;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onShowTopUpDialog;
  final List shopItems;
  final List cartItems;
  final Function(int) onAddToCart;
  final Function(int) onRemoveFromCart;
  final VoidCallback onShowCartDialog;
  final double cartTotal;
  final Future<void> Function() onCheckoutCart;
  final LatLng defaultCenter;
  final LatLng? currentPosition;
  final MapController mapController;
  final double currentZoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onGetCurrentLocation;
  final bool gettingLocation;
  final VoidCallback onProfileLogout;
  final ValueChanged<int> onNavBarTapped;

  const CustomerHomeUI({
    super.key,
    required this.selectedIndex,
    required this.theme,
    required this.name,
    required this.balance,
    required this.affirmation,
    required this.selectedCurrency,
    required this.currencySymbols,
    required this.currencyRates,
    required this.onCurrencyChanged,
    required this.onShowTopUpDialog,
    required this.shopItems,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onShowCartDialog,
    required this.cartTotal,
    required this.onCheckoutCart,
    required this.defaultCenter,
    required this.currentPosition,
    required this.mapController,
    required this.currentZoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onGetCurrentLocation,
    required this.gettingLocation,
    required this.onProfileLogout,
    required this.onNavBarTapped,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (selectedIndex == 0) {
      bodyContent = HomeContent(
        name: name,
        balance: balance,
        onShowTopUpDialog: onShowTopUpDialog,
        selectedCurrency: selectedCurrency,
        currencySymbols: currencySymbols,
        currencyRates: currencyRates,
        onCurrencyChanged: onCurrencyChanged,
        affirmation: affirmation,
        shopDashboard: Container(),
      );
    } else if (selectedIndex == 1) {
      bodyContent = ShopDashboardPage(
        shopItems: shopItems.cast<InventoryItem>(),
        balance: balance,
        cartItems: cartItems.cast<InventoryItem>(),
        onAddToCart: onAddToCart,
        onRemoveFromCart: onRemoveFromCart,
        onShowCartDialog: onShowCartDialog,
      );
    } else if (selectedIndex == 2) {
      bodyContent = MapContent(
        center: defaultCenter,
        currentPosition: currentPosition,
        mapController: mapController,
        currentZoom: currentZoom,
        onZoomIn: onZoomIn,
        onZoomOut: onZoomOut,
        onGetCurrentLocation: onGetCurrentLocation,
        gettingLocation: gettingLocation,
      );
    } else if (selectedIndex == 3) {
      bodyContent = const ProfileContent();
    } else {
      bodyContent = Container();
    }
    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Warna latar belakang utama aplikasi
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onNavBarTapped,
        backgroundColor: theme.colorScheme.surface, // Warna latar belakang BottomNavigationBar
        selectedItemColor: theme.colorScheme.primary, // Warna ikon/tab terpilih
        unselectedItemColor: Colors.grey[500], // Warna ikon/tab tidak terpilih
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
