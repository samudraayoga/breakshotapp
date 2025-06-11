import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/inventory_item.dart';
import 'models/order.dart' as myorder;
import 'services/user_service.dart';
import 'services/inventory_service.dart';
import 'services/order_service.dart';
import 'widgets/topup_dialog.dart';
import 'ui.dart';
import 'widgets/shop_cart_dialog.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- State ---
  String affirmation = "Kata Penyemangat";
  String? name;
  String? username;
  List<InventoryItem> _shopItems = [];
  double? _balance;
  final List<InventoryItem> _cartItems = [];
  List<myorder.Order> _orderHistory = [];

  // Tambahkan state untuk konversi mata uang
  String _selectedCurrency = 'IDR';
  final Map<String, String> _currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': 'EUR',
    'GBP': '£',
  };
  final Map<String, double> _currencyRates = {
    'IDR': 1.0,
    'USD': 0.000065, // 1 IDR = 0.000065 USD (contoh, update sesuai kurs terbaru)
    'EUR': 0.000060, // 1 IDR = 0.000060 EUR
    'GBP': 0.000051, // 1 IDR = 0.000051 GBP
  };

  int _selectedIndex = 0;

  // State untuk Map
  final LatLng _defaultCenter = LatLng(-7.7691672922501915, 110.40738797582647);
  LatLng? _currentPosition;
  late final MapController _mapController = MapController();
  double _currentZoom = 16.0;
  bool _gettingLocation = false;

  // Daftar marker statis rumah billiard
  final List<Map<String, dynamic>> _billiardMarkers = [
    {
      'name': 'Amora Billiard',
      'point': LatLng(-7.765072296340974, 110.41447984627699),
    },
    {
      'name': 'Om Billiard Jogja',
      'point': LatLng(-7.782719652107371, 110.38992681002497),
    },
    {
      'name': 'Mille Billiard',
      'point': LatLng(-7.78331392238846, 110.39055416955144),
    },
    {
      'name': 'Five Seven',
      'point': LatLng(-7.770281152797553, 110.40488150682984),
    },
    {
      'name': 'Simple Chapter 07',
      'point': LatLng(-7.774830907152643, 110.40393736945487),
    },
    {
      'name': 'The Gardens',
      'point': LatLng(-7.772449733457909, 110.40844348051856),
    },
    {
      'name': 'Zon Billiard',
      'point': LatLng(-7.773215112242821, 110.41007426371505),
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchAffirmation();
    _loadUserData();
    _loadInventory();
  }

  Future<void> fetchAffirmation() async {
    try {
      final response = await http.get(Uri.parse('https://katanime.vercel.app/api/getrandom'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String kata = data['result'][0]['indo'] ?? affirmation;
        setState(() {
          affirmation = kata;
        });
      }
    } catch (e) {
      // ignore error, keep default affirmation
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    if (username != null) {
      final user = await UserService.getUserByUsername(username!);
      // MIGRASI: Jika user belum punya field balance, tambahkan ke Firestore
      if (user != null && user.balance == 0) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(username).get();
        if (!doc.data()!.containsKey('balance')) {
          await FirebaseFirestore.instance.collection('users').doc(username).update({'balance': 0.0});
        }
      }
      setState(() {
        name = user?.name ?? 'User';
        _balance = user?.balance ?? 0;
      });
      _loadOrderHistory();
    }
  }

  Future<void> _loadInventory() async {
    setState(() { });
    final items = await InventoryService.getAllItems();
    setState(() {
      _shopItems = items;
    });
  }

  Future<void> _updateBalance(double newBalance) async {
    if (username == null) return;
    final user = await UserService.getUserByUsername(username!);
    if (user != null) {
      user.balance = newBalance;
      await UserService.saveUser(user);
      setState(() {
        _balance = newBalance;
      });
    }
  }

  Future<void> _loadOrderHistory() async {
    if (username == null) return;
    final orders = await OrderService.getOrderHistory(username!);
    setState(() {
      _orderHistory = orders;
    });
  }

  Future<void> _saveOrderHistory() async {
    if (username == null) return;
    await OrderService.saveOrderHistory(username!, _orderHistory);
  }

  void _showTopUpDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => TopUpDialog(
        controller: controller,
        onTopUp: () async {
          final value = double.tryParse(controller.text.replaceAll('.', '')) ?? 0;
          const double maxTopUp = 9999999999;
          if (value > maxTopUp) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maksimal top up Rp9.999.999.999')),
            );
            return;
          }
          if (value > 0) {
            await _updateBalance((_balance ?? 0) + value);
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Top up berhasil! Saldo bertambah Rp$value')),
            );
          }
        },
      ),
    );
  }

  double get _cartTotal => _cartItems.fold(0, (sum, item) => sum + (item.harga * item.jumlah));

  Future<void> _checkoutCart() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }
    if ((_balance ?? 0) < _cartTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo tidak cukup untuk checkout!')),
      );
      return;
    }
    // Cek stok cukup
    bool stokCukup = true;
    for (final cart in _cartItems) {
      final idx = _shopItems.indexWhere((e) => e.kode == cart.kode);
      if (idx == -1 || _shopItems[idx].jumlah < cart.jumlah) {
        stokCukup = false;
        break;
      }
    }
    if (!stokCukup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak cukup untuk salah satu barang!')),
      );
      return;
    }
    // Kurangi stok dan update Firestore
    for (final cart in _cartItems) {
      final idx = _shopItems.indexWhere((e) => e.kode == cart.kode);
      if (idx != -1) {
        final updated = _shopItems[idx].copyWith(jumlah: _shopItems[idx].jumlah - cart.jumlah);
        _shopItems[idx] = updated;
        await InventoryService.updateItem(updated);
      }
    }
    // Update saldo customer
    await _updateBalance((_balance ?? 0) - _cartTotal);
    // Update saldo pengusaha untuk setiap barang
    for (final cart in _cartItems) {
      final ownerUsername = cart.ownerUsername;
      final owner = await UserService.getUserByUsername(ownerUsername);
      if (owner != null) {
        owner.balance += cart.harga * cart.jumlah;
        await UserService.saveUser(owner);
      }
    }
    // Simpan ke riwayat pesanan
    final order = myorder.Order(
      items: _cartItems.map((e) => {
        'nama': e.nama,
        'kode': e.kode,
        'qty': e.jumlah,
        'harga': e.harga,
        'imagePath': e.imagePath,
        'ownerUsername': e.ownerUsername,
      }).toList(),
      total: _cartTotal,
      date: DateTime.now(),
    );
    setState(() {
      _orderHistory.insert(0, order);
      _cartItems.clear();
    });
    await _saveOrderHistory();
    // Update pengusaha order history (jika ada global summary)
    await _updatePengusahaOrderHistoryAndBalance(order);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checkout berhasil! Stok dan saldo terupdate.')),
    );
  }

  Future<void> _updatePengusahaOrderHistoryAndBalance(myorder.Order order) async {
    // Add to global order history (summary)
    await OrderService.addOrderToAll(order);
    // Hapus update saldo pengusaha di sini, karena sudah diupdate per item pada proses checkout.
    // Jika ingin summary, lakukan di dashboard pengusaha saja.
  }

  // Menentukan nama rumah billiard terdekat dari posisi tertentu
  String _getNearestBilliardNameWithPos(LatLng ref) {
    double minDist = double.infinity;
    String nearest = _billiardMarkers.first['name'];
    for (final marker in _billiardMarkers) {
      final LatLng point = marker['point'];
      final dist = Distance().as(LengthUnit.Kilometer, ref, point);
      if (dist < minDist) {
        minDist = dist;
        nearest = marker['name'];
      }
    }
    return nearest;
  }

  void _getCurrentLocation() async {
    setState(() { _gettingLocation = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        setState(() { _gettingLocation = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _gettingLocation = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _gettingLocation = false; });
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final newLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newLatLng;
        _gettingLocation = false;
      });
      _mapController.move(newLatLng, _currentZoom);
      // Tampilkan notifikasi rumah billiard terdekat dengan posisi terbaru
      if (mounted) {
        final nearest = _getNearestBilliardNameWithPos(newLatLng);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('halo $username, rumah billiard terdekat saat ini adalah $nearest'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() { _gettingLocation = false; });
      // Bisa tampilkan snackbar error jika mau
    }
  }

  void _zoomIn() {
    setState(() { _currentZoom += 1; });
    _mapController.move(_currentPosition ?? _defaultCenter, _currentZoom);
  }
  void _zoomOut() {
    setState(() { _currentZoom -= 1; });
    _mapController.move(_currentPosition ?? _defaultCenter, _currentZoom);
  }

  void _removeFromCart(int i) {
    final item = _shopItems[i];
    final idx = _cartItems.indexWhere((e) => e.kode == item.kode);
    if (idx != -1) {
      if (_cartItems[idx].jumlah > 1) {
        setState(() {
          _cartItems[idx].jumlah--;
        });
      } else {
        setState(() {
          _cartItems.removeAt(idx);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF1B5E20),
        onPrimary: Colors.white,
        secondary: const Color(0xFFFFD600),
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: const Color(0xFF121212),
        onBackground: Colors.white,
        surface: const Color(0xFF2C2C2C),
        onSurface: Colors.white,
        surfaceVariant: const Color(0xFF232323),
        onSurfaceVariant: Colors.white,
        outline: Colors.grey.shade700,
        outlineVariant: Colors.grey.shade800,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: const Color(0xFF1B5E20),
      ),
    );
    return CustomerHomeUI(
      selectedIndex: _selectedIndex,
      theme: theme,
      name: name,
      balance: _balance,
      affirmation: affirmation,
      selectedCurrency: _selectedCurrency,
      currencySymbols: _currencySymbols,
      currencyRates: _currencyRates,
      onCurrencyChanged: (val) => setState(() => _selectedCurrency = val!),
      onShowTopUpDialog: _showTopUpDialog,
      shopItems: _shopItems,
      cartItems: _cartItems,
      onAddToCart: (int i) {
        final item = _shopItems[i];
        final idx = _cartItems.indexWhere((e) => e.kode == item.kode);
        final qtyInCart = idx != -1 ? _cartItems[idx].jumlah : 0;
        if (qtyInCart < item.jumlah) {
          setState(() {
            if (idx != -1) {
              _cartItems[idx].jumlah++;
            } else {
              _cartItems.add(InventoryItem(
                nama: item.nama,
                kode: item.kode,
                jumlah: 1,
                harga: item.harga,
                jenis: item.jenis,
                imagePath: item.imagePath ?? '',
                ownerUsername: item.ownerUsername,
              ));
            }
          });
        }
      },
      onRemoveFromCart: _removeFromCart,
      onShowCartDialog: () {
        showDialog(
          context: context,
          builder: (context) => ShopCartDialog(
            cartItems: _cartItems.map((e) => {
              'nama': e.nama,
              'kode': e.kode,
              'qty': e.jumlah,
              'harga': e.harga,
              'imagePath': e.imagePath,
              'ownerUsername': e.ownerUsername,
            }).toList(),
            cartTotal: _cartTotal,
            onQtyChanged: (i, qty) {
              setState(() {
                _cartItems[i].jumlah = qty;
              });
            },
            onRemove: (i) {
              setState(() {
                _cartItems.removeAt(i);
              });
            },
            onCheckout: _checkoutCart,
          ),
        );
      },
      cartTotal: _cartTotal,
      onCheckoutCart: _checkoutCart,
      defaultCenter: _defaultCenter,
      currentPosition: _currentPosition,
      mapController: _mapController,
      currentZoom: _currentZoom,
      onZoomIn: _zoomIn,
      onZoomOut: _zoomOut,
      onGetCurrentLocation: _getCurrentLocation,
      gettingLocation: _gettingLocation,
      onProfileLogout: () {}, // Implement if needed
      onNavBarTapped: (i) => setState(() => _selectedIndex = i),
    );
  }
}
