import 'package:cloud_firestore/cloud_firestore.dart';

class MessageFramingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tambah message framing baru
  Future<void> addMessageFraming({
    required String materi,
    required String subMateri,
    required String message,
    required int hari,
  }) async {
    try {
      await _firestore.collection('message_framing').add({
        'materi': materi,
        'subMateri': subMateri,
        'message': message,
        'hari': hari,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menambah message: $e');
    }
  }

  // Update message framing
  Future<void> updateMessageFraming({
    required String id,
    required String materi,
    required String subMateri,
    required String message,
    required int hari,
  }) async {
    try {
      await _firestore.collection('message_framing').doc(id).update({
        'materi': materi,
        'subMateri': subMateri,
        'message': message,
        'hari': hari,
      });
    } catch (e) {
      throw Exception('Gagal update message: $e');
    }
  }

  // Hapus message framing
  Future<void> deleteMessageFraming(String id) async {
    try {
      await _firestore.collection('message_framing').doc(id).delete();
    } catch (e) {
      throw Exception('Gagal hapus message: $e');
    }
  }

  // Get semua message framing (untuk admin)
  Stream<QuerySnapshot> getAllMessageFraming() {
    return _firestore
        .collection('message_framing')
        .orderBy('hari')
        .orderBy('materi')
        .snapshots();
  }

  // Kirim message framing ke pasien tertentu
  Future<void> sendMessageToPasien({
    required String messageId,
    required String pasienUid,
  }) async {
    try {
      // Ambil data message
      final messageDoc = await _firestore
          .collection('message_framing')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) throw Exception('Message tidak ditemukan');

      final messageData = messageDoc.data()!;

      // Simpan ke collection notifications
      await _firestore.collection('reminders').add({
        'toUserId': pasienUid,
        'type': 'edukasi',
        'materi': messageData['materi'],
        'subMateri': messageData['subMateri'],
        'message': messageData['message'],
        'fromAdmin': true,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal kirim message: $e');
    }
  }

  // Kirim message ke semua pasien
  Future<void> sendMessageToAllPasien(String messageId) async {
    try {
      // Ambil semua pasien
      final pasienQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      // Ambil data message
      final messageDoc = await _firestore
          .collection('message_framing')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) throw Exception('Message tidak ditemukan');

      final messageData = messageDoc.data()!;

      // Kirim ke setiap pasien
      final batch = _firestore.batch();
      for (var pasien in pasienQuery.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasien.id,
          'type': 'edukasi',
          'materi': messageData['materi'],
          'subMateri': messageData['subMateri'],
          'message': messageData['message'],
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke semua pasien: $e');
    }
  }
}