import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodLogService {
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

  // Get food logs by noKode and date
  Stream<QuerySnapshot> getFoodLogsByDate(String noKode, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('food_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('tanggal', descending: false)
        .snapshots();
  }

  // Get food logs by noKode and date range
  Stream<QuerySnapshot> getFoodLogsByDateRange(
    String noKode,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection('food_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Get total calories by date
  Future<Map<String, double>> getTotalNutritionByDate(
    String noKode,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final querySnapshot = await _firestore
        .collection('food_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    double totalCalories = 0;
    double totalCarbs = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      totalCalories += (data['calories'] as num).toDouble();
      totalCarbs += (data['carbohydrate'] as num).toDouble();
      totalProtein += (data['protein'] as num).toDouble();
      totalFat += (data['fat'] as num).toDouble();
    }

    return {
      'calories': totalCalories,
      'carbohydrate': totalCarbs,
      'protein': totalProtein,
      'fat': totalFat,
    };
  }

  // Delete food log
  Future<void> deleteFoodLog(String logId) async {
    try {
      await _firestore.collection('food_logs').doc(logId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // Check if user can delete (only owner can delete)
  Future<bool> canDeleteLog(String logId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final logDoc = await _firestore.collection('food_logs').doc(logId).get();

      if (!logDoc.exists) return false;

      final logData = logDoc.data()!;
      return logData['userId'] == currentUser.uid;
    } catch (e) {
      return false;
    }
  }
}