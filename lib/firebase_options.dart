// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCw6JPaKDiTKY0ZuGqwh6bsOYO03P65s0M',
    appId: '1:778872222967:web:13b5d5e840bbf902104ff2',
    messagingSenderId: '778872222967',
    projectId: 'katalog-makanan-45b5c',
    authDomain: 'katalog-makanan-45b5c.firebaseapp.com',
    storageBucket: 'katalog-makanan-45b5c.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUoO36WllUbEaZoWDOlCtEMJURTBBjyWU',
    appId: '1:778872222967:android:d666002b3cc6093e104ff2',
    messagingSenderId: '778872222967',
    projectId: 'katalog-makanan-45b5c',
    storageBucket: 'katalog-makanan-45b5c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvC6A7QbCCSkr7a7cU4bMH-GBVZUcNBgI',
    appId: '1:778872222967:ios:598974cfd7d647f3104ff2',
    messagingSenderId: '778872222967',
    projectId: 'katalog-makanan-45b5c',
    storageBucket: 'katalog-makanan-45b5c.appspot.com',
    iosBundleId: 'com.example.waterxpressCustomer',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvC6A7QbCCSkr7a7cU4bMH-GBVZUcNBgI',
    appId: '1:778872222967:ios:598974cfd7d647f3104ff2',
    messagingSenderId: '778872222967',
    projectId: 'katalog-makanan-45b5c',
    storageBucket: 'katalog-makanan-45b5c.appspot.com',
    iosBundleId: 'com.example.waterxpressCustomer',
  );
}
