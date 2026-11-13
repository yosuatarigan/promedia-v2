import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Push notification (FCM) untuk aplikasi pasien & keluarga.
///
/// Token perangkat disimpan di `users/{uid}.fcmTokens` (array). Layanan
/// Promedia di VPS membaca token ini untuk mengirim notifikasi saat ada
/// pengingat baru. Tidak dipakai di web (Admin Panel).
class PushService {
  PushService._();

  static String? _savedToken;
  static String? _savedForUid;
  static StreamSubscription<String>? _refreshSub;

  /// Pengingat baru masuk saat aplikasi sedang terbuka (foreground).
  static Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  /// Minta izin notifikasi dan simpan token untuk pengguna yang login.
  /// Aman dipanggil berulang; menulis ke Firestore hanya bila token berubah.
  static Future<void> registerCurrentUser() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token != null) await _save(uid, token);

      await _refreshSub?.cancel();
      _refreshSub = messaging.onTokenRefresh.listen((t) {
        final current = FirebaseAuth.instance.currentUser?.uid;
        if (current != null) _save(current, t);
      });
    } catch (e) {
      // Push bersifat tambahan — jangan ganggu alur aplikasi bila gagal
      // (mis. perangkat tanpa Google Play Services).
      debugPrint('PushService.register gagal: $e');
    }
  }

  static Future<void> _save(String uid, String token) async {
    if (_savedToken == token && _savedForUid == uid) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
      'fcmUpdatedAt': FieldValue.serverTimestamp(),
    });
    _savedToken = token;
    _savedForUid = uid;
  }

  /// Panggil SEBELUM signOut: lepaskan token dari akun ini agar notifikasi
  /// tidak terkirim ke perangkat yang sudah logout.
  static Future<void> unregisterCurrentUser() async {
    if (kIsWeb) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      await _refreshSub?.cancel();
      _refreshSub = null;
      final token = _savedToken ?? await FirebaseMessaging.instance.getToken();
      if (uid != null && token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('PushService.unregister gagal: $e');
    } finally {
      _savedToken = null;
      _savedForUid = null;
    }
  }
}
