import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:promedia_v2/firebase_config.dart';

/// Membuat akun Firebase Auth baru tanpa mengganti sesi admin yang sedang login.
///
/// `createUserWithEmailAndPassword` pada instance utama akan otomatis
/// me-login-kan akun baru (admin jadi ter-logout). Karena itu akun dibuat lewat
/// FirebaseApp kedua, lalu sesi di app kedua langsung di-signOut.
class SecondaryAuth {
  static const _appName = 'admin-account-creator';

  static Future<FirebaseApp> _app() async {
    try {
      return Firebase.app(_appName);
    } on FirebaseException {
      return Firebase.initializeApp(
        name: _appName,
        options: FirebaseConfig.webOptions,
      );
    }
  }

  /// Mengembalikan uid akun baru. Melempar [FirebaseAuthException] bila gagal.
  static Future<String> createAccount({
    required String email,
    required String password,
  }) async {
    final auth = FirebaseAuth.instanceFor(app: await _app());
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await auth.signOut();
    return uid;
  }

  /// Pesan error berbahasa Indonesia untuk kode FirebaseAuthException.
  static String describeError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah dipakai akun lain';
        case 'invalid-email':
          return 'Format email tidak valid';
        case 'weak-password':
          return 'Password terlalu lemah (minimal 6 karakter)';
        case 'operation-not-allowed':
          return 'Login email/password belum diaktifkan di Firebase';
        case 'network-request-failed':
          return 'Koneksi internet bermasalah';
      }
      return e.message ?? e.code;
    }
    return e.toString();
  }
}
