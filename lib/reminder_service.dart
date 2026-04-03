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

      // Cari pasien dengan noKode yang sama (opsional — reminder tetap dikirim walau belum terdaftar)
      final pasienQuery = await _firestore
          .collection('users')
          .where('noKode', isEqualTo: noKode)
          .where('role', isEqualTo: 'pasien')
          .limit(1)
          .get();

      final pasienUid = pasienQuery.docs.isNotEmpty
          ? pasienQuery.docs.first.id
          : null;

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

  // Get reminders untuk pasien yang login (berdasarkan toUserId ATAU noKode)
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

  // Get reminders berdasarkan noKode — untuk menangkap reminder yang dikirim
  // sebelum pasien terdaftar (toUserId == null)
  Stream<QuerySnapshot> getRemindersForNoKode(String noKode) {
    return _firestore
        .collection('reminders')
        .where('noKode', isEqualTo: noKode)
        .where('toUserId', isNull: true)
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
  Future<DocumentSnapshot?> getLatestUnreadReminder({String? noKode}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final now = Timestamp.now();

      // Query 1: reminder yang langsung ke uid pasien
      final queryByUid = await _firestore
          .collection('reminders')
          .where('toUserId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      // Query 2: reminder berbasis noKode (toUserId null — dikirim sebelum pasien terdaftar)
      final queryByNoKode = noKode != null
          ? await _firestore
              .collection('reminders')
              .where('noKode', isEqualTo: noKode)
              .where('toUserId', isNull: true)
              .where('isRead', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              .get()
          : null;

      // Gabungkan dan urutkan
      final allDocs = [
        ...queryByUid.docs,
        ...?queryByNoKode?.docs,
      ]..sort((a, b) {
          final aTime = (a.data() as Map)['createdAt'] as Timestamp?;
          final bTime = (b.data() as Map)['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

      if (allDocs.isEmpty) return null;

      // Filter manual untuk exclude reminder dari admin
      final filteredDocs = allDocs.where((doc) {
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