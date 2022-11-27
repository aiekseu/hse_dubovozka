// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;



class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
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
          'DefaultFirebaseOptions have not been configured for macos - '
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
    apiKey: 'AIzaSyD7Y6UxKQzCWJbc_XhJWLmToY1WdYQMjs4',
    appId: '1:820189585854:android:2b6b9d04453cbf041f19ef',
    messagingSenderId: '820189585854',
    projectId: 'dubovozka',
    storageBucket: 'dubovozka.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArFboBs9QU0WvZR-DRLRIQ6okXWx1qRac',
    appId: '1:820189585854:ios:06cb778fad0667571f19ef',
    messagingSenderId: '820189585854',
    projectId: 'dubovozka',
    storageBucket: 'dubovozka.appspot.com',
    iosClientId: '820189585854-0oakbngpefu5ig8psh55puekfttmmq53.apps.googleusercontent.com',
    iosBundleId: 'com.dada.dubovozka',
  );
}
