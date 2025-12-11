import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get noKode dari user yang sedang login
  Future<String?> getCurrentUserNoKode() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) return null;

      return userDoc.data()?['noKode'] as String?;
    } catch (e) {
      print('Error getting noKode: $e');
      return null;
    }
  }

  // Get medication logs by noKode and date
  Stream<QuerySnapshot> getMedicationLogsByDate(String noKode, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('medication_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('tanggal', descending: false)
        .snapshots();
  }

  // Get medication logs by noKode and date range
  Stream<QuerySnapshot> getMedicationLogsByDateRange(
    String noKode,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('medication_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Delete medication log
  Future<void> deleteMedicationLog(String logId) async {
    try {
      await _firestore.collection('medication_logs').doc(logId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // Check if user can delete (only owner can delete)
  Future<bool> canDeleteLog(String logId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final logDoc =
          await _firestore.collection('medication_logs').doc(logId).get();

      if (!logDoc.exists) return false;

      final logData = logDoc.data()!;
      return logData['userId'] == currentUser.uid;
    } catch (e) {
      return false;
    }
  }
}