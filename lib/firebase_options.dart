// Firebase configuration for project "devathon-saylani".
// Android values mirror android/app/google-services.json. To add iOS, run
// `flutterfire configure` (or add GoogleService-Info.plist) and regenerate.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase is only configured for Android. Run `flutterfire configure` '
      'to add other platforms.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-AW6y-adVOPyXcX4SzVBXHjrCl8a_KMo',
    appId: '1:135514481989:android:97beb60e539eef42e58a2c',
    messagingSenderId: '135514481989',
    projectId: 'devathon-saylani',
    storageBucket: 'devathon-saylani.firebasestorage.app',
  );
}
