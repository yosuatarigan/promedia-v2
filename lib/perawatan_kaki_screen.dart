import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PerawatanKakiScreen extends StatefulWidget {
  const PerawatanKakiScreen({super.key});

  @override
  State<PerawatanKakiScreen> createState() => _PerawatanKakiScreenState();
}

class _PerawatanKakiScreenState extends State<PerawatanKakiScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Kondisi kaki (multiple selection)
  Set<String> kondisiKaki = {};
  
  // Pertanyaan Ya/Tidak
  String? memeriksaSepatu;
  String? mengeringkanKaki;
  String? menggunakanAlasKaki;
  String? menggunakanPelembab;

  // Tanggal dan waktu observasi
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedJam = TimeOfDay.now();

  int _skorRisiko = 0;

  Future<void> _selectDateTime() async {
    // Pilih tanggal
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      // Pilih jam
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedJam,
        );

        if (time != null) {
          setState(() {
            selectedDate = date;
            selectedJam = time;
          });
        }
      }
    }
  }

  Future<void> _simpanData() async {
    if (kondisiKaki.isEmpty || 
        memeriksaSepatu == null || 
        mengeringkanKaki == null || 
        menggunakanAlasKaki == null || 
        menggunakanPelembab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua pertanyaan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hitung skor risiko
    _skorRisiko = _hitungSkorRisiko();

    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showError('User tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Ambil noKode user dari Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        _showError('Data user tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      final userData = userDoc.data()!;
      final noKode = userData['noKode'] as String;
      final namaLengkap = userData['namaLengkap'] as String;
      final role = userData['role'] as String;

      // Gabungkan tanggal dan jam
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedJam.hour,
        selectedJam.minute,
      );

      // Simpan ke Firestore (top-level collection)
      await _firestore.collection('foot_care_logs').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': namaLengkap,
        'userRole': role,
        'kondisiKaki': kondisiKaki.toList(),
        'memeriksaSepatu': memeriksaSepatu,
        'mengeringkanKaki': mengeringkanKaki,
        'menggunakanAlasKaki': menggunakanAlasKaki,
        'menggunakanPelembab': menggunakanPelembab,
        'skorRisiko': _skorRisiko,
        'statusKondisi': _getStatusKondisi(),
        'deskripsiObservasi': _getDeskripsiObservasi(),
        'rekomendasi': _getRekomendasi(),
        'tanggal': Timestamp.fromDate(dateTime),
        'jam':
            '${selectedJam.hour.toString().padLeft(2, '0')}:${selectedJam.minute.toString().padLeft(2, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      if (mounted) {
        // Tampilkan dialog hasil
        _showHasilDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showHasilDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB83B7E),
                        const Color(0xFF8B2D5C),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assessment, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hasil Observasi Kaki',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Deskripsi Observasi
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8D5DF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.description, color: Color(0xFF5D2E46), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Deskripsi Observasi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D2E46),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getDeskripsiObservasi(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Status Risiko
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getStatusColor().withOpacity(0.3), width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      _skorRisiko >= 10 ? Icons.warning : 
                                      _skorRisiko >= 6 ? Icons.info :
                                      _skorRisiko >= 3 ? Icons.check_circle : Icons.thumb_up,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Status Risiko',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5D2E46),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getStatusKondisi(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Skor Risiko: $_skorRisiko',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kondisi Terdeteksi
                        const Text(
                          'Kondisi yang Terdeteksi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...kondisiKaki.map((kondisi) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.circle, size: 6, color: Color(0xFFB83B7E)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  kondisi,
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),

                        // Rekomendasi
                        const Text(
                          'Rekomendasi Perawatan:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._getRekomendasi().asMap().entries.map((entry) {
                          bool isPrioritas = entry.value.contains("SEGERA") || entry.value.contains("PENTING");
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPrioritas ? const Color(0xFFFFEBEE) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isPrioritas ? Colors.red.shade200 : const Color(0xFFE0E0E0),
                                width: isPrioritas ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isPrioritas ? Colors.red : const Color(0xFFB83B7E),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
                                      fontWeight: isPrioritas ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Footer Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFB83B7E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Lihat Lagi',
                            style: TextStyle(
                              color: Color(0xFFB83B7E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB83B7E),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Selesai',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _hitungSkorRisiko() {
    int skor = 0;

    // Skor berdasarkan kondisi kaki (prioritas tertinggi)
    if (kondisiKaki.any((k) => k.contains("Lepuh") || k.contains("luka"))) {
      skor += 10; // Sangat serius
    }
    if (kondisiKaki.any((k) => k.contains("Perubahan warna"))) {
      skor += 8; // Serius, indikasi masalah sirkulasi
    }
    if (kondisiKaki.any((k) => k.contains("Bengkak"))) {
      skor += 7; // Serius
    }
    if (kondisiKaki.any((k) => k.contains("Kapur") || k.contains("mata ikan"))) {
      skor += 4; // Sedang
    }
    if (kondisiKaki.any((k) => k.contains("Kulit terlalu kering"))) {
      skor += 3; // Ringan
    }

    // Skor berdasarkan kebiasaan perawatan
    if (memeriksaSepatu == "Tidak") skor += 2;
    if (mengeringkanKaki == "Tidak") skor += 3; // Risiko jamur
    if (menggunakanAlasKaki == "Tidak") skor += 4; // Risiko cedera
    if (menggunakanPelembab == "Tidak") skor += 2;

    return skor;
  }

  String _getStatusKondisi() {
    if (_skorRisiko >= 10) {
      return "TINGGI - Perlu Perhatian Medis Segera";
    } else if (_skorRisiko >= 6) {
      return "SEDANG - Perlu Perawatan Khusus";
    } else if (_skorRisiko >= 3) {
      return "RENDAH - Perlu Perbaikan Kebiasaan";
    } else {
      return "BAIK - Pertahankan Perawatan";
    }
  }

  Color _getStatusColor() {
    if (_skorRisiko >= 10) {
      return Colors.red;
    } else if (_skorRisiko >= 6) {
      return Colors.orange;
    } else if (_skorRisiko >= 3) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  String _getDeskripsiObservasi() {
    List<String> deskripsi = [];

    // Deskripsi kondisi kaki
    if (kondisiKaki.isNotEmpty) {
      String kondisiText = "Kondisi Kaki ${kondisiKaki.join(", ").toLowerCase()}";
      deskripsi.add(kondisiText);
    }

    // Deskripsi kebiasaan
    List<String> kebiasaanBaik = [];
    List<String> kebiasaanBuruk = [];

    if (memeriksaSepatu == "Ya") {
      kebiasaanBaik.add("selalu cek bagian dalam sepatu sebelum digunakan");
    } else {
      kebiasaanBuruk.add("tidak memeriksa bagian dalam sepatu");
    }

    if (mengeringkanKaki == "Ya") {
      kebiasaanBaik.add("setelah dicuci dikeringkan dengan baik");
    } else {
      kebiasaanBuruk.add("setelah dicuci tidak dikeringkan");
    }

    if (menggunakanAlasKaki == "Ya") {
      kebiasaanBaik.add("menggunakan alas kaki setiap keluar rumah");
    } else {
      kebiasaanBuruk.add("tidak menggunakan alas kaki setiap keluar rumah");
    }

    if (menggunakanPelembab == "Ya") {
      kebiasaanBaik.add("selalu menggunakan pelembab atau lotion");
    } else {
      kebiasaanBuruk.add("tidak menggunakan pelembab atau lotion");
    }

    if (kebiasaanBaik.isNotEmpty) {
      deskripsi.add(kebiasaanBaik.join(", "));
    }
    if (kebiasaanBuruk.isNotEmpty) {
      deskripsi.add(kebiasaanBuruk.join(", "));
    }

    return deskripsi.join(", ");
  }

  List<String> _getRekomendasi() {
    List<String> rekomendasi = [];

    // Rekomendasi berdasarkan kondisi kaki (prioritas)
    if (kondisiKaki.any((k) => k.contains("Lepuh") || k.contains("luka"))) {
      rekomendasi.add("SEGERA konsultasi dengan dokter atau perawat diabetes untuk penanganan luka. Luka pada penderita diabetes dapat berkembang menjadi infeksi serius");
      rekomendasi.add("Jangan mengobati luka sendiri. Bersihkan dengan air bersih dan tutup dengan perban steril sambil menunggu pemeriksaan medis");
    }
    
    if (kondisiKaki.any((k) => k.contains("Perubahan warna"))) {
      rekomendasi.add("Perubahan warna kulit dapat mengindikasikan masalah sirkulasi darah. Segera periksakan ke dokter untuk evaluasi lebih lanjut");
    }

    if (kondisiKaki.any((k) => k.contains("Bengkak"))) {
      rekomendasi.add("Pembengkakan kaki memerlukan pemeriksaan dokter untuk mengetahui penyebabnya (bisa jantung, ginjal, atau masalah pembuluh darah)");
      rekomendasi.add("Sementara menunggu pemeriksaan, tinggikan kaki saat berbaring dan kurangi konsumsi garam");
    }

    if (kondisiKaki.any((k) => k.contains("Kapur") || k.contains("mata ikan"))) {
      rekomendasi.add("Untuk kapalan/mata ikan: rendam kaki dengan air hangat 10-15 menit, lalu gosok perlahan dengan batu apung");
      rekomendasi.add("JANGAN memotong atau mengiris kapalan sendiri karena berisiko luka. Konsultasikan ke podiatris jika mengganggu");
    }

    if (kondisiKaki.any((k) => k.contains("Kulit terlalu kering"))) {
      rekomendasi.add("Oleskan pelembab khusus kaki 2x sehari (pagi dan malam). Pilih pelembab yang mengandung urea atau lanolin");
      rekomendasi.add("Hindari mengoleskan pelembab di sela-sela jari kaki untuk mencegah jamur");
    }

    // Rekomendasi berdasarkan kebiasaan yang perlu diperbaiki
    if (memeriksaSepatu == "Tidak") {
      rekomendasi.add("Biasakan memeriksa bagian dalam sepatu sebelum dipakai. Batu kecil, jahitan yang tajam, atau benda asing bisa melukai kaki tanpa Anda sadari");
    }

    if (mengeringkanKaki == "Tidak") {
      rekomendasi.add("PENTING: Keringkan kaki dengan seksama setelah mandi, terutama sela-sela jari. Kelembaban berlebih dapat menyebabkan infeksi jamur");
    }

    if (menggunakanAlasKaki == "Tidak") {
      rekomendasi.add("Selalu gunakan alas kaki, bahkan di dalam rumah. Kaki penderita diabetes rentan cedera dan sering tidak merasakan sakit saat terluka");
    }

    if (menggunakanPelembab == "Tidak") {
      rekomendasi.add("Gunakan pelembab atau lotion setiap hari untuk mencegah kulit kering dan pecah-pecah yang bisa menjadi pintu masuk infeksi");
    }

    // Rekomendasi umum pencegahan
    if (_skorRisiko >= 6) {
      rekomendasi.add("Lakukan pemeriksaan kaki setiap hari. Gunakan cermin untuk melihat bagian bawah kaki jika sulit menekuk");
      rekomendasi.add("Kontrol gula darah secara ketat. HbA1c yang baik (<7%) membantu penyembuhan dan mencegah komplikasi");
    }

    if (_skorRisiko < 3 && rekomendasi.isEmpty) {
      rekomendasi.add("Kebiasaan perawatan kaki Anda sudah baik! Pertahankan dan lakukan pemeriksaan rutin");
      rekomendasi.add("Tetap kontrol gula darah dan lakukan pemeriksaan kaki menyeluruh setiap 3 bulan ke tenaga kesehatan");
    }

    return rekomendasi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perawatan Kaki',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Lengkapi form observasi perawatan kaki untuk monitoring kesehatan kaki Anda',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tanggal & Waktu Observasi
                const Text(
                  'Tanggal & Waktu Observasi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFB83B7E).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Color(0xFFB83B7E), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${DateFormat('dd MMM yyyy').format(selectedDate)} - ${selectedJam.hour.toString().padLeft(2, '0')}:${selectedJam.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OBSERVASI PERAWATAN KAKI DIABETES',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lakukan Observasi Kaki anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // Question 1: Kondisi Kaki (Multiple selection)
                const Text(
                  '1. Bagaimana kondisi kaki anda hari ini',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildCheckboxOption('Lepuh, luka gores, atau sayatan'),
                _buildCheckboxOption('Perubahan warna kulit (biru, merah terang, atau bercak putih)'),
                _buildCheckboxOption('Kulit terlalu kering'),
                _buildCheckboxOption('Kapur/tumit tebal (callus) atau mata ikan (corns)'),
                _buildCheckboxOption('Bengkak'),
                const SizedBox(height: 24),

                // Question 2
                const Text(
                  '2. Saya selalu memeriksa bagaian dalam sepatu sebelum digunakan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildRadioOption('memeriksaSepatu', 'Ya', memeriksaSepatu),
                _buildRadioOption('memeriksaSepatu', 'Tidak', memeriksaSepatu),
                const SizedBox(height: 20),

                // Question 3
                const Text(
                  '3. Setelah di cuci di keringkan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildRadioOption('mengeringkanKaki', 'Ya', mengeringkanKaki),
                _buildRadioOption('mengeringkanKaki', 'Tidak', mengeringkanKaki),
                const SizedBox(height: 20),

                // Question 4
                const Text(
                  '4. Menggunakan alas kaki setiap keluar rumah',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildRadioOption('menggunakanAlasKaki', 'Ya', menggunakanAlasKaki),
                _buildRadioOption('menggunakanAlasKaki', 'Tidak', menggunakanAlasKaki),
                const SizedBox(height: 20),

                // Question 5
                const Text(
                  '5. Menggunakan pelembab atau lotion',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildRadioOption('menggunakanPelembab', 'Ya', menggunakanPelembab),
                _buildRadioOption('menggunakanPelembab', 'Tidak', menggunakanPelembab),
                const SizedBox(height: 32),

                // Tombol Simpan
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _simpanData,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan Observasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(String value) {
    final isSelected = kondisiKaki.contains(value);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            kondisiKaki.remove(value);
          } else {
            kondisiKaki.add(value);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5D2E46) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF5D2E46),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String group, String value, String? groupValue) {
    return GestureDetector(
      onTap: () {
        setState(() {
          switch (group) {
            case 'memeriksaSepatu':
              memeriksaSepatu = value;
              break;
            case 'mengeringkanKaki':
              mengeringkanKaki = value;
              break;
            case 'menggunakanAlasKaki':
              menggunakanAlasKaki = value;
              break;
            case 'menggunakanPelembab':
              menggunakanPelembab = value;
              break;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF5D2E46),
                  width: 2,
                ),
              ),
              child: groupValue == value
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF5D2E46),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}