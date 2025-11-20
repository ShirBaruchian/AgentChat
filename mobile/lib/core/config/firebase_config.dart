import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase options for different platforms
/// 
/// These values come from Firebase Console > Project Settings > General
/// For your project: agentchat-f7eb8
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

  // Firebase Web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCmXOfPpGqTbu7XM8OIqtZN99upZjlOabg',
    appId: '1:943343441020:web:fe29c8b5126f23cf21e5f9',
    messagingSenderId: '943343441020',
    projectId: 'agentchat-f7eb8',
    authDomain: 'agentchat-f7eb8.firebaseapp.com',
    storageBucket: 'agentchat-f7eb8.firebasestorage.app',
    measurementId: 'G-RG7N1XTWCM',
  );

  // Firebase Android config (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBeGB9MSQ0J3InGNeZYSwFPo6Jlj0fEHd8',
    appId: '1:943343441020:android:0598092b4cafc32821e5f9',
    messagingSenderId: '943343441020',
    projectId: 'agentchat-f7eb8',
    storageBucket: 'agentchat-f7eb8.firebasestorage.app',
  );

  // Firebase iOS config (from GoogleService-Info.plist)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBX6FGMKn-XZlFPc_JtiaeCaM-4kk6y14U',
    appId: '1:943343441020:ios:47cc76a3cc4b803c21e5f9',
    messagingSenderId: '943343441020',
    projectId: 'agentchat-f7eb8',
    storageBucket: 'agentchat-f7eb8.firebasestorage.app',
    iosBundleId: 'Com.company.AgentChat',
  );

  // Firebase macOS config (from GoogleService-Info.plist)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBX6FGMKn-XZlFPc_JtiaeCaM-4kk6y14U',
    appId: '1:943343441020:ios:47cc76a3cc4b803c21e5f9',
    messagingSenderId: '943343441020',
    projectId: 'agentchat-f7eb8',
    storageBucket: 'agentchat-f7eb8.firebasestorage.app',
    iosBundleId: 'Com.company.AgentChat',
  );
}
