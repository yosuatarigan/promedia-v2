import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Klien layanan Promedia di VPS (pengganti Cloud Functions).
/// Dipakai untuk operasi yang butuh Firebase Admin SDK, mis. menonaktifkan
/// atau menghapus akun login pengguna.
class PromediaApi {
  static const baseUrl = String.fromEnvironment(
    'PROMEDIA_API',
    defaultValue: 'https://api-promedia.jostar.id',
  );

  static Future<Map<String, dynamic>> _call(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const PromediaApiException('Sesi login berakhir');
    final token = await user.getIdToken();
    final uri = Uri.parse('$baseUrl$path');
    final headers = {
      'Authorization': 'Bearer $token',
      if (body != null) 'Content-Type': 'application/json',
    };

    http.Response res;
    try {
      res = await switch (method) {
        'GET' => http.get(uri, headers: headers),
        'POST' => http.post(uri, headers: headers, body: jsonEncode(body)),
        'DELETE' => http.delete(uri, headers: headers),
        _ => throw ArgumentError(method),
      }
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const PromediaApiException(
          'Layanan server Promedia tidak dapat dihubungi. Coba lagi beberapa saat.');
    }

    Map<String, dynamic> data = const {};
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {}
    if (res.statusCode >= 400) {
      throw PromediaApiException(
          (data['error'] as String?) ?? 'Server menolak permintaan (${res.statusCode})');
    }
    return data;
  }

  /// Jumlah data yang akan ikut terhapus (tanpa menghapus apa pun).
  static Future<Map<String, dynamic>> deletePreview(String uid) =>
      _call('GET', '/v1/users/$uid/delete-preview');

  /// Nonaktifkan / aktifkan kembali akun login.
  static Future<void> setDisabled(String uid, bool disabled) =>
      _call('POST', '/v1/users/$uid/disable', body: {'disabled': disabled});

  /// Hapus permanen: akun login, profil, catatan, dan notifikasi terkait.
  static Future<Map<String, dynamic>> deleteUser(String uid) =>
      _call('DELETE', '/v1/users/$uid');
}

class PromediaApiException implements Exception {
  final String message;
  const PromediaApiException(this.message);
  @override
  String toString() => message;
}
