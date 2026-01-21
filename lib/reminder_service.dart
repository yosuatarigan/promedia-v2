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

  // Get latest unread dan unsnoozed reminder untuk pop-up
  // HANYA untuk reminder aktivitas dari keluarga, BUKAN dari admin
  Future<DocumentSnapshot?> getLatestUnreadReminder() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final now = Timestamp.now();

      // Filter: hanya ambil reminder yang BUKAN dari admin (fromAdmin != true)
      final query = await _firestore
          .collection('reminders')
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      if (query.docs.isEmpty) return null;

      // Filter manual untuk exclude reminder dari admin
      final filteredDocs = query.docs.where((doc) {
        final data = doc.data();
        final fromAdmin = data['fromAdmin'] as bool? ?? false;
        return !fromAdmin; // Hanya ambil yang bukan dari admin
      }).toList();

      if (filteredDocs.isEmpty) return null;

      final reminder = filteredDocs.first;
      final data = reminder.data();

      // Check if snoozed
      final isSnoozed = data['isSnoozed'] as bool? ?? false;
      final snoozedUntil = data['snoozedUntil'] as Timestamp?;

      if (isSnoozed && snoozedUntil != null) {
        // Check if snooze time has passed
        if (snoozedUntil.compareTo(now) > 0) {
          // Still snoozed, return null
          return null;
        } else {
          // Snooze expired, unsnooze it
          await _firestore.collection('reminders').doc(reminder.id).update({
            'isSnoozed': false,
            'snoozedUntil': null,
          });
        }
      }

      return reminder;
    } catch (e) {
      print('Error getting latest reminder: $e');
      return null;
    }
  }

  // Snooze reminder for 10 minutes
  Future<void> snoozeReminder(String reminderId) async {
    try {
      final snoozedUntil = Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 10)),
      );

      await _firestore.collection('reminders').doc(reminderId).update({
        'isSnoozed': true,
        'snoozedUntil': snoozedUntil,
      });
    } catch (e) {
      throw Exception('Gagal tunda pengingat: $e');
    }
  }
}