import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GlucoseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) return null;

      return userDoc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get glucose logs by date
  Stream<QuerySnapshot> getGlucoseLogsByDate(String noKode, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('glucose_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  // Add glucose log
  Future<void> addGlucoseLog({
    required String noKode,
    required DateTime tanggal,
    required String jam,
    int? gulaDarahPuasa,
    int? gulaDarahSewaktu,
    int? gulaDarah2JamPP,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      final userData = await getCurrentUserData();
      if (userData == null) {
        throw Exception('Data user tidak ditemukan');
      }

      // Validate at least one value
      if (gulaDarahPuasa == null &&
          gulaDarahSewaktu == null &&
          gulaDarah2JamPP == null) {
        throw Exception('Minimal satu jenis gula darah harus diisi');
      }

      // Analyze status
      final statusPuasa = gulaDarahPuasa != null
          ? _analyzeGlucoseStatus('puasa', gulaDarahPuasa)
          : null;
      final statusSewaktu = gulaDarahSewaktu != null
          ? _analyzeGlucoseStatus('sewaktu', gulaDarahSewaktu)
          : null;
      final status2JamPP = gulaDarah2JamPP != null
          ? _analyzeGlucoseStatus('2jampp', gulaDarah2JamPP)
          : null;

      await _firestore.collection('glucose_logs').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': userData['namaLengkap'] ?? 'User',
        'userRole': userData['role'] ?? 'Unknown',
        'gulaDarahPuasa': gulaDarahPuasa,
        'gulaDarahSewaktu': gulaDarahSewaktu,
        'gulaDarah2JamPP': gulaDarah2JamPP,
        'statusPuasa': statusPuasa,
        'statusSewaktu': statusSewaktu,
        'status2JamPP': status2JamPP,
        'tanggal': Timestamp.fromDate(tanggal),
        'jam': jam,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Gagal menyimpan data: $e');
    }
  }

  // Analyze glucose status
  Map<String, dynamic> _analyzeGlucoseStatus(String type, int value) {
    String status;
    String color;
    String description;
    List<String> recommendations = [];

    if (type == 'puasa') {
      // Gula Darah Puasa (Normal: 70-100 mg/dL)
      if (value < 70) {
        status = 'RENDAH';
        color = 'blue';
        description = 'Hipoglikemia - Gula darah di bawah normal';
        recommendations = [
          'Segera konsumsi makanan/minuman manis',
          'Istirahat dan duduk',
          'Periksa ulang dalam 15 menit',
          'Konsultasi dokter jika sering terjadi'
        ];
      } else if (value <= 100) {
        status = 'NORMAL';
        color = 'green';
        description = 'Gula darah puasa dalam batas normal';
        recommendations = [
          'Pertahankan pola makan sehat',
          'Rutin olahraga',
          'Cek gula darah berkala'
        ];
      } else if (value <= 125) {
        status = 'PREDIABETES';
        color = 'orange';
        description = 'Gula darah puasa tinggi - Risiko diabetes';
        recommendations = [
          'Kurangi konsumsi karbohidrat & gula',
          'Tingkatkan aktivitas fisik',
          'Konsultasi dokter untuk pemeriksaan lanjutan',
          'Pantau gula darah lebih sering'
        ];
      } else {
        status = 'TINGGI';
        color = 'red';
        description = 'Diabetes - Gula darah puasa sangat tinggi';
        recommendations = [
          'PENTING: Konsultasi dokter segera',
          'Minum obat sesuai anjuran dokter',
          'Diet ketat rendah gula',
          'Olahraga teratur',
          'Monitor gula darah setiap hari'
        ];
      }
    } else if (type == 'sewaktu') {
      // Gula Darah Sewaktu (Normal: < 200 mg/dL)
      if (value < 70) {
        status = 'RENDAH';
        color = 'blue';
        description = 'Hipoglikemia - Gula darah rendah';
        recommendations = [
          'Segera konsumsi makanan/minuman manis',
          'Istirahat',
          'Periksa ulang dalam 15 menit',
          'Hubungi dokter jika tidak membaik'
        ];
      } else if (value < 140) {
        status = 'NORMAL';
        color = 'green';
        description = 'Gula darah sewaktu dalam batas normal';
        recommendations = [
          'Pertahankan pola hidup sehat',
          'Makan teratur dengan porsi seimbang',
          'Tetap aktif bergerak'
        ];
      } else if (value < 200) {
        status = 'WASPADA';
        color = 'orange';
        description = 'Gula darah sewaktu cukup tinggi';
        recommendations = [
          'Perhatikan pola makan',
          'Hindari makanan manis & berlemak',
          'Olahraga ringan',
          'Konsultasi dokter'
        ];
      } else {
        status = 'TINGGI';
        color = 'red';
        description = 'Gula darah sewaktu sangat tinggi';
        recommendations = [
          'PENTING: Konsultasi dokter',
          'Minum obat diabetes sesuai resep',
          'Diet ketat',
          'Pantau gula darah ketat',
          'Hindari stres'
        ];
      }
    } else if (type == '2jampp') {
      // Gula Darah 2 Jam PP (Normal: < 140 mg/dL)
      if (value < 70) {
        status = 'RENDAH';
        color = 'blue';
        description = 'Hipoglikemia pasca makan';
        recommendations = [
          'Konsumsi makanan ringan',
          'Istirahat',
          'Evaluasi porsi makan',
          'Konsultasi dokter'
        ];
      } else if (value < 140) {
        status = 'NORMAL';
        color = 'green';
        description = 'Gula darah 2 jam PP dalam batas normal';
        recommendations = [
          'Pertahankan pola makan',
          'Teruskan aktivitas fisik',
          'Monitor berkala'
        ];
      } else if (value < 200) {
        status = 'PREDIABETES';
        color = 'orange';
        description = 'Gula darah 2 jam PP tinggi - Risiko diabetes';
        recommendations = [
          'Kurangi porsi karbohidrat',
          'Hindari makanan manis setelah makan',
          'Olahraga setelah makan',
          'Konsultasi dokter'
        ];
      } else {
        status = 'TINGGI';
        color = 'red';
        description = 'Diabetes - Gula darah 2 jam PP sangat tinggi';
        recommendations = [
          'PENTING: Konsultasi dokter',
          'Obat diabetes diminum rutin',
          'Diet ketat',
          'Jalan kaki setelah makan',
          'Pantau ketat'
        ];
      }
    } else {
      status = 'UNKNOWN';
      color = 'grey';
      description = 'Status tidak diketahui';
      recommendations = [];
    }

    return {
      'status': status,
      'color': color,
      'description': description,
      'recommendations': recommendations,
    };
  }

  // Delete glucose log
  Future<void> deleteGlucoseLog(String logId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Check if user is the owner
      final logDoc =
          await _firestore.collection('glucose_logs').doc(logId).get();

      if (!logDoc.exists) {
        throw Exception('Data tidak ditemukan');
      }

      final logData = logDoc.data()!;
      if (logData['userId'] != currentUser.uid) {
        throw Exception('Anda tidak memiliki izin untuk menghapus data ini');
      }

      await _firestore.collection('glucose_logs').doc(logId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }
}