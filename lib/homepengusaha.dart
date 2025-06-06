import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/inventory_service.dart';
import 'models/inventory_item.dart';

class HomePengusahaPage extends StatefulWidget {
  const HomePengusahaPage({super.key});

  @override
  State<HomePengusahaPage> createState() => _HomePengusahaPageState();
}

class _HomePengusahaPageState extends State<HomePengusahaPage> {
  int _selectedIndex = 0;
  final LatLng _defaultCenter = LatLng(-7.7691672922501915, 110.40738797582647);
  LatLng? _currentPosition;
  bool _gettingLocation = false;
  late final MapController _mapController = MapController();
  double _currentZoom = 16.0;

  // Inventory state
  List<Map<String, dynamic>> _items = [];

  // Balance and order history state
  double _pengusahaBalance = 0;
  List<Map<String, dynamic>> _orderHistory = [];

  String? _username;

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _getCurrentLocation() async {
    setState(() {
      _gettingLocation = true;
    });
    // Ambil lokasi GPS asli
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _gettingLocation = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location service is disabled.')),
      );
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _gettingLocation = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _gettingLocation = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied.')),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _gettingLocation = false;
    });
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _currentZoom);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSessionAndInventory();
    _loadPengusahaBalanceFromFirestore();
    _loadOrderHistoryFromFirestore();
  }

  Future<void> _loadSessionAndInventory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
    });
    await _loadInventoryFromFirestore();
  }

  Future<void> _loadInventoryFromFirestore() async {
    final items = await InventoryService.getAllItems();
    setState(() {
      _items = items.map((e) => e.toMap()).toList();
    });
  }

  Future<void> _addOrUpdateItemFirestore(Map<String, dynamic> item, {bool isEdit = false}) async {
    final inventoryItem = InventoryItem.fromMap(item);
    if (isEdit) {
      await InventoryService.updateItem(inventoryItem);
    } else {
      await InventoryService.addItem(inventoryItem);
    }
    await _loadInventoryFromFirestore();
  }

  Future<void> _deleteItemFirestore(String kode) async {
    await InventoryService.deleteItem(kode);
    await _loadInventoryFromFirestore();
  }

  void _showItemDialog({Map<String, dynamic>? item, int? index}) {
    final TextEditingController nameController = TextEditingController(text: item?['nama'] ?? '');
    final TextEditingController kodeController = TextEditingController(text: item?['kode'] ?? '');
    final TextEditingController jumlahController = TextEditingController(text: item?['jumlah']?.toString() ?? '');
    final TextEditingController hargaController = TextEditingController(text: item?['harga']?.toString() ?? '');
    final TextEditingController imageUrlController = TextEditingController(text: item?['imagePath'] ?? '');
    final String ownerUsername = _username ?? '';
    String jenis = item?['jenis'] ?? 'Meja Billiard';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? 'Tambah Barang' : 'Edit Barang'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[200],
                      ),
                      child: imageUrlController.text.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(imageUrlController.text, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                            )
                          : const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(labelText: 'URL Gambar'),
                      onChanged: (_) => setStateDialog(() {}),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Barang'),
                    ),
                    TextField(
                      controller: kodeController,
                      decoration: const InputDecoration(labelText: 'Kode Barang'),
                      readOnly: item != null, // kode tidak bisa diubah saat edit
                    ),
                    TextField(
                      controller: jumlahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jumlah Barang'),
                    ),
                    TextField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga Barang'),
                    ),
                    TextField(
                      controller: TextEditingController(text: ownerUsername),
                      decoration: const InputDecoration(labelText: 'Username Pengusaha'),
                      readOnly: true,
                    ),
                    DropdownButtonFormField<String>(
                      value: jenis,
                      decoration: const InputDecoration(labelText: 'Jenis Barang'),
                      items: const [
                        DropdownMenuItem(value: 'Meja Billiard', child: Text('Meja Billiard')),
                        DropdownMenuItem(value: 'Stik Billiard', child: Text('Stik Billiard')),
                        DropdownMenuItem(value: 'Bola', child: Text('Bola')),
                      ],
                      onChanged: (val) {
                        if (val != null) setStateDialog(() { jenis = val; });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                if (item != null)
                  TextButton(
                    onPressed: () async {
                      await _deleteItemFirestore(item['kode']);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nama = nameController.text.trim();
                    final kode = kodeController.text.trim();
                    final jumlah = int.tryParse(jumlahController.text.trim()) ?? 0;
                    final harga = int.tryParse(hargaController.text.trim()) ?? 0;
                    final imageUrl = imageUrlController.text.trim();
                    if (nama.isEmpty || kode.isEmpty || jumlah <= 0 || harga <= 0 || ownerUsername.isEmpty) return;
                    final newItem = {
                      'nama': nama,
                      'kode': kode,
                      'jumlah': jumlah,
                      'harga': harga,
                      'jenis': jenis,
                      'imagePath': imageUrl,
                      'ownerUsername': ownerUsername,
                    };
                    await _addOrUpdateItemFirestore(newItem, isEdit: item != null);
                    Navigator.of(context).pop();
                  },
                  child: Text(item == null ? 'Tambah' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryContent() {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = _items[i];
            return ListTile(
              tileColor: Colors.grey[200],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: item['imagePath'] != null && item['imagePath'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item['imagePath'], width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.grey),
              title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Kode: ${item['kode']} | Jumlah: ${item['jumlah']} | Harga: Rp${item['harga']} | Jenis: ${item['jenis']}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () => _showItemDialog(item: item, index: i),
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _showItemDialog(),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Tambah Barang',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return const ProfilePage();
  }

  Widget _buildDashboardContent() {
    int totalTransaksi = _orderHistory.length;
    int totalBarangTerjual = 0;
    double totalPendapatan = 0;
    for (final order in _orderHistory) {
      totalPendapatan += (order['total'] ?? 0).toDouble();
      for (final item in (order['items'] as List)) {
        totalBarangTerjual += (item['qty'] ?? 0) as int;
      }
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.dashboard, size: 40, color: Color.fromARGB(255, 46, 204, 113)),
              const SizedBox(width: 12),
              const Text('Dashboard Pengusaha', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(offset: Offset(0,1), blurRadius: 2, color: Colors.black54)])),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.blueGrey[900], // Warna gelap untuk kontras
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Pengusaha', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text('Rp${_pengusahaBalance.toStringAsFixed(0)}', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet, color: Color.fromARGB(255, 46, 204, 113), size: 40),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.blueGrey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Transaksi', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('$totalTransaksi', style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.blueGrey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Barang Terjual', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('$totalBarangTerjual', style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: Colors.blueGrey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Pendapatan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Rp${totalPendapatan.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Riwayat Transaksi Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _orderHistory.isEmpty
              ? const Text('Belum ada transaksi masuk.')
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orderHistory.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final order = _orderHistory[i];
                    final date = DateTime.tryParse(order['date'] ?? '') ?? DateTime.now();
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...List<Widget>.from((order['items'] as List).map((item) => Text('- ${item['nama']} x${item['qty']} (Rp${item['harga']})'))),
                            Text('Total: Rp${order['total'].toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // Tambahkan ulang method yang hilang
  Future<void> _loadPengusahaBalanceFromFirestore() async {
    if (_username == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(_username).get();
    setState(() {
      _pengusahaBalance = doc.exists ? (doc.data()?['balance'] ?? 0).toDouble() : 0;
    });
  }

  Future<void> _loadOrderHistoryFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance.collection('order_history_all').get();
    setState(() {
      _orderHistory = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_selectedIndex == 0) {
      bodyContent = _buildDashboardContent();
    } else if (_selectedIndex == 1) {
      bodyContent = _buildInventoryContent();
    } else if (_selectedIndex == 2) {
      bodyContent = _buildProfileContent();
    } else {
      bodyContent = _buildProfileContent();
    }
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
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
