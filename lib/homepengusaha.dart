import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile.dart';
import 'services/inventory_service.dart';
import 'models/inventory_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePengusahaPage extends StatefulWidget {
  const HomePengusahaPage({super.key});

  @override
  State<HomePengusahaPage> createState() => _HomePengusahaPageState();
}

class _HomePengusahaPageState extends State<HomePengusahaPage> {
  int _selectedIndex = 0;

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
    // Tambahan: refresh saldo pengusaha setiap kali tab diganti
    _loadPengusahaBalanceFromFirestore();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: const Color(0xFF1B5E20), // dark green
        onPrimary: Colors.white,
        secondary: const Color(0xFFFFD600), // vibrant yellow
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        background: const Color(0xFF121212), // dark grey
        onBackground: Colors.white,
        surface: const Color(0xFF2C2C2C), // charcoal grey
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
    Widget bodyContent;
    if (_selectedIndex == 0) {
      bodyContent = _buildDashboardContent(theme);
    } else if (_selectedIndex == 1) {
      bodyContent = _buildInventoryContent(theme);
    } else {
      bodyContent = const ProfilePage();
    }
    return Scaffold(
      backgroundColor: theme.colorScheme.background, // Warna latar belakang utama aplikasi
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        selectedItemColor: theme.colorScheme.primary, // Warna ikon/tab terpilih
        unselectedItemColor: Colors.grey[500], // Warna ikon/tab tidak terpilih
        backgroundColor: theme.colorScheme.surface, // Warna latar belakang BottomNavigationBar
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

  Widget _buildDashboardContent(ThemeData theme) {
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
              Icon(Icons.dashboard, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text('Dashboard Pengusaha', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Pengusaha', style: GoogleFonts.montserrat(color: theme.colorScheme.secondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Rp${_pengusahaBalance.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 24, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary, size: 40),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Transaksi', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                        const SizedBox(height: 8),
                        Text('$totalTransaksi', style: GoogleFonts.montserrat(fontSize: 20, color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Barang Terjual', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                        const SizedBox(height: 8),
                        Text('$totalBarangTerjual', style: GoogleFonts.montserrat(fontSize: 20, color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Pendapatan', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                        const SizedBox(height: 8),
                        Text('Rp${totalPendapatan.toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontSize: 20, color: theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Riwayat Transaksi Masuk', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          _orderHistory.isEmpty
              ? Text('Belum ada transaksi masuk.', style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface))
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orderHistory.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final order = _orderHistory[i];
                    final date = DateTime.tryParse(order['date'] ?? '') ?? DateTime.now();
                    return Card(
                      color: theme.colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                            ...List<Widget>.from((order['items'] as List).map((item) => Text('- ${item['nama']} x${item['qty']} (Rp${item['harga']})', style: GoogleFonts.montserrat(color: theme.colorScheme.onSurface)))),
                            Text('Total: Rp${order['total'].toStringAsFixed(0)}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
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

  Widget _buildInventoryContent(ThemeData theme) {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = _items[i];
            return ListTile(
              tileColor: theme.colorScheme.surfaceVariant,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: item['imagePath'] != null && item['imagePath'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item['imagePath'], width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.grey),
              title: Text(item['nama'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              subtitle: Text('Kode: ${item['kode']} | Jumlah: ${item['jumlah']} | Harga: Rp${item['harga']} | Jenis: ${item['jenis']}', style: GoogleFonts.montserrat(color: theme.colorScheme.secondary)),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
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
            backgroundColor: theme.colorScheme.primary,
            tooltip: 'Tambah Barang',
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
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
}
