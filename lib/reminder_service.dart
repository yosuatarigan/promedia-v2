import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kirim reminder dari keluarga ke pasien
  Future<void> sendReminder({
    required String noKode,
    required String type, // 'makan', 'minum_obat', etc
    required String message,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User tidak login');

      // Ambil data user yang login (keluarga)
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) throw Exception('Data user tidak ditemukan');

      final userData = userDoc.data()!;
      final fromUserName = userData['namaLengkap'] as String;

      // Cari pasien dengan noKode yang sama
      final pasienQuery = await _firestore
          .collection('users')
          .where('noKode', isEqualTo: noKode)
          .where('role', isEqualTo: 'pasien')
          .limit(1)
          .get();

      if (pasienQuery.docs.isEmpty) {
        throw Exception('Pasien tidak ditemukan');
      }

      final pasienUid = pasienQuery.docs.first.id;

      // Simpan reminder ke Firestore
      await _firestore.collection('reminders').add({
        'noKode': noKode,
        'fromUserId': currentUser.uid,
        'fromUserName': fromUserName,
        'toUserId': pasienUid,
        'type': type,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal mengirim pengingat: $e');
    }
  }

  // Get reminders untuk pasien yang login
  Stream<QuerySnapshot> getRemindersForCurrentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('reminders')
        .where('toUserId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Tandai reminder sebagai sudah dibaca
  Future<void> markAsRead(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Gagal update status: $e');
    }
  }

  // Hitung jumlah reminder yang belum dibaca
  Stream<int> getUnreadReminderCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('reminders')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Hapus reminder (opsional)
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus pengingat: $e');
    }
  }
}