import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web qollab-quvvatlanmaydi');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Bu platforma qollab-quvvatlanmaydi');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBu5eUD5uw6DcT0TFmKh5M3H6VDFH51G6Y',
    appId: '1:807916195351:android:764cef580161c659e81652',
    messagingSenderId: '807916195351',
    projectId: 'mario-16667',
    storageBucket: 'mario-16667.firebasestorage.app',
  );
}