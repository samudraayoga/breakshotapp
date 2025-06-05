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
    apiKey: "AIzaSyDXst7CL1-ww_ir_cOUl-uN1_O_35FNTJU",
    authDomain: "self-careapp-8ac9e.firebaseapp.com",
    projectId: "self-careapp-8ac9e",
    storageBucket: "self-careapp-8ac9e.appspot.com",
    messagingSenderId: "1003605900474",
    appId: "1:1003605900474:web:6b6e8a841d63dc5f929683",
  );
}
