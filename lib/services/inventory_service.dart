import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class InventoryService {
  static final _collection = FirebaseFirestore.instance.collection('inventory');

  static Future<List<InventoryItem>> getAllItems() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => InventoryItem.fromMap(doc.data()..['kode'] = doc.id)).toList();
  }

  static Future<void> saveAllItems(List<InventoryItem> items) async {
    // Hapus semua data lama
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    // Tambahkan data baru
    for (final item in items) {
      final doc = _collection.doc(item.kode);
      batch.set(doc, item.toMap());
    }
    await batch.commit();
  }

  static Future<void> addItem(InventoryItem item) async {
    await _collection.doc(item.kode).set(item.toMap());
  }

  static Future<void> updateItem(InventoryItem item) async {
    await _collection.doc(item.kode).update(item.toMap());
  }

  static Future<void> deleteItem(String kode) async {
    await _collection.doc(kode).delete();
  }
}
