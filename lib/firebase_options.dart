import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyAwQedtuCTitsAQ2RhFs5rLuqac8OYoeK0',
    appId: '1:34818372698:web:00f70fa38d804196399463',
    messagingSenderId: '34818372698',
    projectId: 'plashcard2',
    authDomain: 'plashcard2.firebaseapp.com',
    storageBucket: 'plashcard2.appspot.com',
    measurementId: 'G-28H83E6JHM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfiosgIbXEqLDnArm0SxgFoXWYyBXX1g4',
    appId: '1:34818372698:android:230ca50b9174e0a0399463',
    messagingSenderId: '34818372698',
    projectId: 'plashcard2',
    storageBucket: 'plashcard2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-AytG10milUnN2xYE5q9dUKvWir4HO70',
    appId: '1:34818372698:ios:87321e000b54d6bc399463',
    messagingSenderId: '34818372698',
    projectId: 'plashcard2',
    storageBucket: 'plashcard2.appspot.com',
    iosBundleId: 'com.example.flutterFinal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-AytG10milUnN2xYE5q9dUKvWir4HO70',
    appId: '1:34818372698:ios:87321e000b54d6bc399463',
    messagingSenderId: '34818372698',
    projectId: 'plashcard2',
    storageBucket: 'plashcard2.appspot.com',
    iosBundleId: 'com.example.flutterFinal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAwQedtuCTitsAQ2RhFs5rLuqac8OYoeK0',
    appId: '1:34818372698:web:c4c862c301aeef31399463',
    messagingSenderId: '34818372698',
    projectId: 'plashcard2',
    authDomain: 'plashcard2.firebaseapp.com',
    storageBucket: 'plashcard2.appspot.com',
    measurementId: 'G-DZG98YVCY6',
  );
}
