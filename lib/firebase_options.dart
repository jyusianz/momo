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
        return windows;
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
    apiKey: 'AIzaSyA88qr7497Kr0te4oSVJQN-DBnNj6riDec',
    appId: '1:189153598464:web:257da63782b416e9d88ce5',
    messagingSenderId: '189153598464',
    projectId: 'momo-app0329',
    authDomain: 'momo-app0329.firebaseapp.com',
    storageBucket: 'momo-app0329.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYQZvhLPhzMc6Oyx3CUfPhBekZ9erbqjI',
    appId: '1:189153598464:android:7621020399700c9bd88ce5',
    messagingSenderId: '189153598464',
    projectId: 'momo-app0329',
    storageBucket: 'momo-app0329.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCtiqknWRaJCFwM7MpCEtHnf6hkS605iLY',
    appId: '1:189153598464:ios:3e8bbc4416b227efd88ce5',
    messagingSenderId: '189153598464',
    projectId: 'momo-app0329',
    storageBucket: 'momo-app0329.appspot.com',
    iosBundleId: 'com.example.Momo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCtiqknWRaJCFwM7MpCEtHnf6hkS605iLY',
    appId: '1:189153598464:ios:3e8bbc4416b227efd88ce5',
    messagingSenderId: '189153598464',
    projectId: 'momo-app0329',
    storageBucket: 'momo-app0329.appspot.com',
    iosBundleId: 'com.example.Momo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA88qr7497Kr0te4oSVJQN-DBnNj6riDec',
    appId: '1:189153598464:web:c863ad2899c3839dd88ce5',
    messagingSenderId: '189153598464',
    projectId: 'momo-app0329',
    authDomain: 'momo-app0329.firebaseapp.com',
    storageBucket: 'momo-app0329.appspot.com',
  );
}
