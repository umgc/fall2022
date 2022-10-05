// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for windows - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHQngn9lxLsHjQSIPn1BBxjTywrM27YOc',
    appId: '1:872576625259:android:accd56b745157ebc7f1f2e',
    messagingSenderId: '872576625259',
    projectId: 'swen670-b197f',
    storageBucket: 'swen670-b197f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYZCRwouCzacVzbxF5qVasIN4jVQU7cr4',
    appId: '1:872576625259:ios:aafd44597e5e92c97f1f2e',
    messagingSenderId: '872576625259',
    projectId: 'swen670-b197f',
    storageBucket: 'swen670-b197f.appspot.com',
    iosClientId: '872576625259-h9l5shh21q8cccq2lbovc8e8eq9k4l7c.apps.googleusercontent.com',
    iosBundleId: 'com.example.fall2022',
  );

  /*
    static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBA7mKhpBPlAX0f6Uk8VVtHFVxnElR62Ek',
    appId: '1:872576625259:web:12ce406f12f7ffa77f1f2e',
    messagingSenderId: '872576625259',
    projectId: 'swen670-b197f',
    authDomain: 'swen670-b197f.firebaseapp.com',
    storageBucket: 'swen670-b197f.appspot.com',
    measurementId: 'G-EHPVPHQZZQ',
    );

    static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDYZCRwouCzacVzbxF5qVasIN4jVQU7cr4',
    appId: '1:872576625259:ios:aafd44597e5e92c97f1f2e',
    messagingSenderId: '872576625259',
    projectId: 'swen670-b197f',
    storageBucket: 'swen670-b197f.appspot.com',
    iosClientId: '872576625259-h9l5shh21q8cccq2lbovc8e8eq9k4l7c.apps.googleusercontent.com',
    iosBundleId: 'com.example.fall2022',
  );*/
}


