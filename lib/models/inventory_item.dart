class InventoryItem {
  final String nama;
  final String kode;
  int jumlah;
  final int harga;
  final String jenis;
  final String? imagePath;
  final String ownerUsername;

  InventoryItem({
    required this.nama,
    required this.kode,
    required this.jumlah,
    required this.harga,
    required this.jenis,
    this.imagePath,
    required this.ownerUsername,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      nama: map['nama'],
      kode: map['kode'],
      jumlah: map['jumlah'],
      harga: map['harga'],
      jenis: map['jenis'],
      imagePath: map['imagePath'],
      ownerUsername: map['ownerUsername'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'kode': kode,
      'jumlah': jumlah,
      'harga': harga,
      'jenis': jenis,
      'imagePath': imagePath,
      'ownerUsername': ownerUsername,
    };
  }

  // Add copyWith method for cart/stock operations
  InventoryItem copyWith({
    String? nama,
    String? kode,
    int? jumlah,
    int? harga,
    String? jenis,
    String? imagePath,
    String? ownerUsername,
  }) {
    return InventoryItem(
      nama: nama ?? this.nama,
      kode: kode ?? this.kode,
      jumlah: jumlah ?? this.jumlah,
      harga: harga ?? this.harga,
      jenis: jenis ?? this.jenis,
      imagePath: imagePath ?? this.imagePath,
      ownerUsername: ownerUsername ?? this.ownerUsername,
    );
  }
}
