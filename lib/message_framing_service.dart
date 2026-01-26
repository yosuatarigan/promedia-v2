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

  // ========== METHOD BARU UNTUK KIRIM PESAN ==========

  // 1. Kirim ke PASIEN saja (tanpa keluarga)
  Future<void> sendMessageToPasien({
    required String message,
    required String materi,
    required String subMateri,
    required List<String> pasienIds,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (var pasienId in pasienIds) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasienId,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke pasien: $e');
    }
  }

  // 2. Kirim ke PASIEN + KELUARGA dengan noKode yang sama
  Future<void> sendMessageToPasienAndFamily({
    required String message,
    required String materi,
    required String subMateri,
    required List<String> pasienIds,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (var pasienId in pasienIds) {
        // Kirim ke pasien
        final pasienReminderRef = _firestore.collection('reminders').doc();
        batch.set(pasienReminderRef, {
          'toUserId': pasienId,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Cari keluarga dengan noKode yang sama
        final pasienDoc = await _firestore.collection('users').doc(pasienId).get();
        if (pasienDoc.exists) {
          final pasienNoKode = pasienDoc.data()!['noKode'] as String?;
          
          if (pasienNoKode != null) {
            // Query keluarga dengan noKode yang sama
            final keluargaQuery = await _firestore
                .collection('users')
                .where('noKode', isEqualTo: pasienNoKode)
                .where('role', isEqualTo: 'keluarga')
                .get();

            // Kirim ke semua keluarga dengan noKode yang sama
            for (var keluargaDoc in keluargaQuery.docs) {
              final keluargaReminderRef = _firestore.collection('reminders').doc();
              batch.set(keluargaReminderRef, {
                'toUserId': keluargaDoc.id,
                'type': 'edukasi',
                'materi': materi,
                'subMateri': subMateri,
                'message': message,
                'fromAdmin': true,
                'isRead': false,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke pasien dan keluarga: $e');
    }
  }

  // 3. Kirim ke SEMUA PASIEN saja
  Future<void> sendMessageToAllPasien({
    required String message,
    required String materi,
    required String subMateri,
  }) async {
    try {
      // Get semua pasien
      final pasienQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      final batch = _firestore.batch();
      
      for (var pasien in pasienQuery.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasien.id,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
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

  // 4. Kirim ke SEMUA PASIEN + SEMUA KELUARGA
  Future<void> sendMessageToAllPasienAndFamily({
    required String message,
    required String materi,
    required String subMateri,
  }) async {
    try {
      // Get semua pasien
      final pasienQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      // Get semua keluarga
      final keluargaQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'keluarga')
          .get();

      final batch = _firestore.batch();
      
      // Kirim ke semua pasien
      for (var pasien in pasienQuery.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasien.id,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Kirim ke semua keluarga
      for (var keluarga in keluargaQuery.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': keluarga.id,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke semua pasien dan keluarga: $e');
    }
  }

  // 5. Kirim ke KELUARGA saja
  Future<void> sendMessageToKeluarga({
    required String message,
    required String materi,
    required String subMateri,
    required List<String> keluargaIds,
  }) async {
    try {
      final batch = _firestore.batch();
      
      for (var keluargaId in keluargaIds) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': keluargaId,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke keluarga: $e');
    }
  }

  // 6. Kirim ke SEMUA KELUARGA
  Future<void> sendMessageToAllKeluarga({
    required String message,
    required String materi,
    required String subMateri,
  }) async {
    try {
      // Get semua keluarga
      final keluargaQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'keluarga')
          .get();

      final batch = _firestore.batch();
      
      for (var keluarga in keluargaQuery.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': keluarga.id,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Gagal kirim message ke semua keluarga: $e');
    }
  }
}