import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA2QwQwQwQwQwQwQwQwQwQwQwQwQwQwQwQ",
    authDomain: "rumahbilliard-f153c.firebaseapp.com",
    projectId: "rumahbilliard-f153c",
    storageBucket: "rumahbilliard-f153c.appspot.com",
    messagingSenderId: "1090123456789",
    appId: "1:1090123456789:web:abcdef1234567890abcdef",
  );
}
