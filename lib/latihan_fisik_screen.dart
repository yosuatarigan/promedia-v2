import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LatihanFisikScreen extends StatefulWidget {
  const LatihanFisikScreen({super.key});

  @override
  State<LatihanFisikScreen> createState() => _LatihanFisikScreenState();
}

class _LatihanFisikScreenState extends State<LatihanFisikScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String? selectedJenisOlahraga;
  final TextEditingController _durasiController = TextEditingController();
  bool isDurasiMenit = true; // true = Menit, false = Total Durasi

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedJam = TimeOfDay.now();

  final List<String> daftarOlahraga = [
    'Jalan Kaki',
    'Jogging',
    'Lari',
    'Bersepeda',
    'Berenang',
    'Senam',
    'Yoga',
    'Angkat Beban',
    'Badminton',
    'Futsal',
    'Basket',
    'Tenis',
  ];

  @override
  void dispose() {
    _durasiController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
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
    if (selectedJenisOlahraga == null || _durasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final durasi = int.tryParse(_durasiController.text);
    if (durasi == null || durasi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Durasi harus berupa angka positif'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showError('User tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        _showError('Data user tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      final userData = userDoc.data()!;
      final noKode = userData['noKode'] as String;
      final namaLengkap = userData['namaLengkap'] as String;
      final role = userData['role'] as String;

      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedJam.hour,
        selectedJam.minute,
      );

      final kaloriTerbakar = _hitungKalori(selectedJenisOlahraga!, durasi);
      final kategoriIntensitas = _getKategoriIntensitas(durasi);
      final manfaat = _getManfaat(selectedJenisOlahraga!, durasi);
      final rekomendasi = _getRekomendasi(durasi);

      await _firestore.collection('latihan_fisik_logs').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': namaLengkap,
        'userRole': role,
        'jenisOlahraga': selectedJenisOlahraga,
        'durasi': durasi,
        'satuanDurasi': isDurasiMenit ? 'Menit' : 'Total Durasi',
        'kaloriTerbakar': kaloriTerbakar,
        'kategoriIntensitas': kategoriIntensitas,
        'manfaat': manfaat,
        'rekomendasi': rekomendasi,
        'tanggal': Timestamp.fromDate(dateTime),
        'jam': '${selectedJam.hour.toString().padLeft(2, '0')}:${selectedJam.minute.toString().padLeft(2, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      if (mounted) {
        _showHasilDialog(
          kaloriTerbakar,
          kategoriIntensitas,
          manfaat,
          rekomendasi,
        );
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

  int _hitungKalori(String jenis, int durasi) {
    // Kalori per menit untuk berbagai jenis olahraga (estimasi)
    final Map<String, double> kaloriPerMenit = {
      'Jalan Kaki': 3.5,
      'Jogging': 7.0,
      'Lari': 10.0,
      'Bersepeda': 6.0,
      'Berenang': 8.0,
      'Senam': 5.0,
      'Yoga': 3.0,
      'Angkat Beban': 6.0,
      'Badminton': 7.5,
      'Futsal': 9.0,
      'Basket': 8.0,
      'Tenis': 7.0,
    };

    return ((kaloriPerMenit[jenis] ?? 5.0) * durasi).round();
  }

  String _getKategoriIntensitas(int durasi) {
    if (durasi >= 60) {
      return 'TINGGI - Olahraga Intensif';
    } else if (durasi >= 30) {
      return 'SEDANG - Olahraga Teratur';
    } else if (durasi >= 15) {
      return 'RINGAN - Aktivitas Fisik';
    } else {
      return 'SANGAT RINGAN';
    }
  }

  Color _getKategoriColor(String kategori) {
    if (kategori.contains('TINGGI')) {
      return Colors.green;
    } else if (kategori.contains('SEDANG')) {
      return Colors.blue;
    } else if (kategori.contains('RINGAN')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  List<String> _getManfaat(String jenis, int durasi) {
    List<String> manfaat = [];

    // Manfaat umum olahraga
    manfaat.add('✓ Meningkatkan kesehatan jantung dan sirkulasi darah');
    manfaat.add('✓ Membantu mengontrol berat badan dan kadar gula darah');
    manfaat.add('✓ Mengurangi stress dan meningkatkan mood');

    // Manfaat spesifik per jenis olahraga
    switch (jenis) {
      case 'Jalan Kaki':
        manfaat.add('✓ Cocok untuk semua usia, aman untuk sendi');
        break;
      case 'Jogging':
      case 'Lari':
        manfaat.add('✓ Meningkatkan stamina dan daya tahan tubuh');
        break;
      case 'Bersepeda':
        manfaat.add('✓ Melatih otot kaki tanpa membebani sendi');
        break;
      case 'Berenang':
        manfaat.add('✓ Olahraga full body, baik untuk pernafasan');
        break;
      case 'Senam':
        manfaat.add('✓ Meningkatkan fleksibilitas dan koordinasi');
        break;
      case 'Yoga':
        manfaat.add('✓ Meningkatkan keseimbangan dan ketenangan pikiran');
        break;
      case 'Angkat Beban':
        manfaat.add('✓ Membangun massa otot dan kekuatan');
        break;
      default:
        manfaat.add('✓ Meningkatkan koordinasi dan ketangkasan');
    }

    if (durasi >= 30) {
      manfaat.add('✓ Durasi optimal untuk manfaat kesehatan maksimal');
    }

    return manfaat;
  }

  List<String> _getRekomendasi(int durasi) {
    List<String> rekomendasi = [];

    if (durasi < 30) {
      rekomendasi.add('💡 Tingkatkan durasi menjadi minimal 30 menit untuk manfaat optimal');
      rekomendasi.add('💡 Lakukan olahraga secara bertahap, tambah 5 menit setiap minggu');
    } else if (durasi >= 30 && durasi < 60) {
      rekomendasi.add('✅ Durasi sudah bagus! Pertahankan konsistensi');
      rekomendasi.add('💡 Lakukan minimal 3-5 kali seminggu untuk hasil terbaik');
    } else {
      rekomendasi.add('👏 Luar biasa! Durasi olahraga Anda sangat baik');
      rekomendasi.add('💡 Pastikan istirahat cukup untuk pemulihan otot');
    }

    rekomendasi.add('💧 Jangan lupa minum air putih 500ml sebelum dan sesudah olahraga');
    rekomendasi.add('🍎 Konsumsi makanan bergizi 1-2 jam sebelum olahraga');
    rekomendasi.add('📊 Untuk diabetes: Monitor gula darah sebelum dan sesudah olahraga');
    rekomendasi.add('⚠️ Hentikan jika merasa pusing, nyeri dada, atau sesak nafas');

    return rekomendasi;
  }

  void _showHasilDialog(
    int kalori,
    String kategori,
    List<String> manfaat,
    List<String> rekomendasi,
  ) {
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
                      const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hasil Latihan Fisik',
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
                          Navigator.of(context).pop();
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
                        // Info Singkat
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8D5DF)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.local_fire_department, 
                                        color: Colors.orange, size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$kalori kal',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Terbakar',
                                        style: TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(Icons.timer, 
                                        color: _getKategoriColor(kategori), size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_durasiController.text}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Menit',
                                        style: TextStyle(fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kategori Intensitas
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getKategoriColor(kategori).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getKategoriColor(kategori).withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getKategoriColor(kategori),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  kategori,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getKategoriColor(kategori),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Manfaat
                        const Text(
                          'Manfaat:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: manfaat.map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                m,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rekomendasi
                        const Text(
                          'Rekomendasi:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...rekomendasi.asMap().entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFB83B7E),
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
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

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
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
          'Latihan Fisik',
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
                const Text(
                  'Silahkan pilih jenis latihan fisik, kemudian isi durasi olahraga',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 24),

                // Tanggal & Waktu
                const Text(
                  'Tanggal & Waktu:',
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
                        color: const Color(0xFFB83B7E).withOpacity(0.2),
                      ),
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

                // Jenis Olahraga
                const Text(
                  'Jenis Olahraga :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedJenisOlahraga,
                      hint: const Text(
                        'Pilih Olahraga',
                        style: TextStyle(color: Colors.grey),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFB83B7E)),
                      items: daftarOlahraga.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedJenisOlahraga = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Durasi Olahraga
                const Text(
                  'Durasi Olahraga :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                
                // Toggle Menit / Total Durasi
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isDurasiMenit = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDurasiMenit 
                              ? const Color(0xFFB83B7E) 
                              : const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              'Menit',
                              style: TextStyle(
                                color: isDurasiMenit ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isDurasiMenit = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isDurasiMenit 
                              ? const Color(0xFFB83B7E) 
                              : const Color(0xFFFCE4EC),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              'Masukan Total Durasi',
                              style: TextStyle(
                                color: !isDurasiMenit ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Input Durasi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _durasiController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: isDurasiMenit ? '30' : 'Masukan durasi',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Menit',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Simpan
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _simpanData,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
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
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}