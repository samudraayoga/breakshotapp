import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as model;

class OrderService {
  static final _collection = FirebaseFirestore.instance.collection('orders');

  static Future<List<model.Order>> getOrderHistory(String username) async {
    final snapshot = await _collection.where('username', isEqualTo: username).orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => model.Order.fromMap(doc.data())).toList();
  }

  static Future<void> saveOrderHistory(String username, List<model.Order> orders) async {
    // Hapus semua order user lama
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await _collection.where('username', isEqualTo: username).get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    // Tambahkan order baru
    for (final order in orders) {
      final doc = _collection.doc();
      batch.set(doc, order.toMap()..['username'] = username);
    }
    await batch.commit();
  }

  static Future<List<model.Order>> getAllOrders() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => model.Order.fromMap(doc.data())).toList();
  }

  static Future<void> saveAllOrders(List<model.Order> orders) async {
    // Hapus semua order lama
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await _collection.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    // Tambahkan order baru
    for (final order in orders) {
      final doc = _collection.doc();
      batch.set(doc, order.toMap());
    }
    await batch.commit();
  }

  static Future<void> addOrderToAll(model.Order order) async {
    await _collection.add(order.toMap());
  }
}
