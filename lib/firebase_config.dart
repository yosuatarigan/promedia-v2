import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: "AIzaSyA_0rzC1TMyjoVQh1tFdfpFOsBAA_TsRRA",
    authDomain: "app-jarak-penentu.firebaseapp.com",
    projectId: "app-jarak-penentu",
    storageBucket: "app-jarak-penentu.appspot.com",
    messagingSenderId: "501470008135",
    appId: "1:501470008135:web:6af0c6d4f02c5eeaa7b262",
  );

  static Future<void> initialize() async {
    await Firebase.initializeApp(options: webOptions);
  }
}
