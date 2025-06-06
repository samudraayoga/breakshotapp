import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  static final _collection = FirebaseFirestore.instance.collection('users');

  static Future<List<User>> getAllUsers() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  static Future<void> saveUser(User user) async {
    await _collection.doc(user.username).set(user.toMap());
  }

  static Future<User?> getUserByUsername(String username) async {
    final doc = await _collection.doc(username).get();
    if (doc.exists) {
      return User.fromMap(doc.data()!);
    }
    return null;
  }

  static Future<bool> usernameExists(String username) async {
    final doc = await _collection.doc(username).get();
    return doc.exists;
  }

  static Future<User?> getPengusahaUser() async {
    final snapshot = await _collection.where('role', isEqualTo: 'Pengusaha').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return User.fromMap(snapshot.docs.first.data());
    }
    return null;
  }
}
