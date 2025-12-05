import 'package:flutter/material.dart';

class ManajemenStressScreen extends StatefulWidget {
  const ManajemenStressScreen({super.key});

  @override
  State<ManajemenStressScreen> createState() => _ManajemenStressScreenState();
}

class _ManajemenStressScreenState extends State<ManajemenStressScreen> {
  final TextEditingController _tekananDarahController = TextEditingController();
  String? selectedPerasaan;

  final List<String> daftarPerasaan = [
    'Perasaan Senang',
    'Perasaan Marah',
    'Perasaan Takut',
    'Perasaan Stres',
    'Perasaan Sedih',
    'Perasaan Cemas',
    'Perasaan Obsesi',
    'Perasaan Depresi',
  ];

  int _skorStress = 0;

  @override
  void dispose() {
    _tekananDarahController.dispose();
    super.dispose();
  }

  void _simpanData() {
    if (_tekananDarahController.text.isEmpty || selectedPerasaan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Hitung skor stress
    _skorStress = _hitungSkorStress();

    // Tampilkan dialog hasil
    _showHasilDialog();
  }

  int _hitungSkorStress() {
    int skor = 0;

    // Skor berdasarkan tekanan darah
    String tekananDarah = _tekananDarahController.text.trim();
    if (tekananDarah.contains('/')) {
      List<String> parts = tekananDarah.split('/');
      if (parts.length == 2) {
        int? sistolik = int.tryParse(parts[0].trim());
        int? diastolik = int.tryParse(parts[1].trim());

        if (sistolik != null && diastolik != null) {
          // Hipertensi tingkat 2 (≥140/90)
          if (sistolik >= 140 || diastolik >= 90) {
            skor += 8;
          }
          // Prehipertensi (120-139 / 80-89)
          else if (sistolik >= 120 || diastolik >= 80) {
            skor += 4;
          }
          // Hipotensi (<90/60)
          else if (sistolik < 90 || diastolik < 60) {
            skor += 5;
          }
        }
      }
    }

    // Skor berdasarkan perasaan
    if (selectedPerasaan == 'Perasaan Depresi' || selectedPerasaan == 'Perasaan Obsesi') {
      skor += 10; // Sangat serius
    } else if (selectedPerasaan == 'Perasaan Stres' || selectedPerasaan == 'Perasaan Cemas') {
      skor += 7; // Serius
    } else if (selectedPerasaan == 'Perasaan Marah' || selectedPerasaan == 'Perasaan Sedih') {
      skor += 5; // Sedang
    } else if (selectedPerasaan == 'Perasaan Takut') {
      skor += 4; // Ringan-Sedang
    } else if (selectedPerasaan == 'Perasaan Senang') {
      skor += 0; // Baik
    }

    return skor;
  }

  String _getStatusStress() {
    if (_skorStress >= 15) {
      return "TINGGI - Perlu Konseling Profesional";
    } else if (_skorStress >= 10) {
      return "SEDANG-TINGGI - Perlu Intervensi";
    } else if (_skorStress >= 6) {
      return "SEDANG - Perlu Teknik Relaksasi";
    } else if (_skorStress >= 3) {
      return "RINGAN - Perlu Pemantauan";
    } else {
      return "BAIK - Pertahankan";
    }
  }

  Color _getStatusColor() {
    if (_skorStress >= 15) {
      return Colors.red;
    } else if (_skorStress >= 10) {
      return Colors.deepOrange;
    } else if (_skorStress >= 6) {
      return Colors.orange;
    } else if (_skorStress >= 3) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  String _getAnalisaTekananDarah() {
    String tekananDarah = _tekananDarahController.text.trim();
    if (!tekananDarah.contains('/')) {
      return "Format tekanan darah tidak valid. Gunakan format: Sistolik/Diastolik (contoh: 120/80)";
    }

    List<String> parts = tekananDarah.split('/');
    if (parts.length != 2) {
      return "Format tekanan darah tidak valid";
    }

    int? sistolik = int.tryParse(parts[0].trim());
    int? diastolik = int.tryParse(parts[1].trim());

    if (sistolik == null || diastolik == null) {
      return "Nilai tekanan darah tidak valid";
    }

    if (sistolik >= 180 || diastolik >= 120) {
      return "⚠️ KRISIS HIPERTENSI - Segera ke IGD! Tekanan darah sangat tinggi dan berbahaya";
    } else if (sistolik >= 140 || diastolik >= 90) {
      return "🔴 Hipertensi Tingkat 2 - Tekanan darah tinggi, perlu penanganan medis";
    } else if (sistolik >= 130 || diastolik >= 85) {
      return "🟡 Hipertensi Tingkat 1 - Tekanan darah mulai tinggi, perlu dikontrol";
    } else if (sistolik >= 120 || diastolik >= 80) {
      return "🟠 Prehipertensi - Tekanan darah di atas normal, waspada";
    } else if (sistolik >= 90 && diastolik >= 60 && sistolik < 120 && diastolik < 80) {
      return "✅ Normal - Tekanan darah dalam batas normal";
    } else if (sistolik < 90 || diastolik < 60) {
      return "🔵 Hipotensi - Tekanan darah rendah, bisa menyebabkan pusing";
    }

    return "Tekanan darah: $tekananDarah mmHg";
  }

  String _getAnalisisPerasaan() {
    if (selectedPerasaan == 'Perasaan Senang') {
      return "✅ Kondisi emosional positif - Anda dalam keadaan mental yang baik";
    } else if (selectedPerasaan == 'Perasaan Depresi') {
      return "🚨 Depresi - Kondisi serius yang membutuhkan bantuan profesional kesehatan mental";
    } else if (selectedPerasaan == 'Perasaan Obsesi') {
      return "⚠️ Obsesi - Pikiran berulang yang mengganggu, konsultasi dengan psikolog/psikiater";
    } else if (selectedPerasaan == 'Perasaan Stres') {
      return "🔴 Stress tinggi - Tubuh dan pikiran dalam tekanan, perlu teknik manajemen stress";
    } else if (selectedPerasaan == 'Perasaan Cemas') {
      return "🟠 Cemas - Kekhawatiran berlebih yang bisa mengganggu aktivitas sehari-hari";
    } else if (selectedPerasaan == 'Perasaan Marah') {
      return "🟡 Marah - Emosi negatif yang perlu dikelola agar tidak merusak hubungan dan kesehatan";
    } else if (selectedPerasaan == 'Perasaan Sedih') {
      return "🔵 Sedih - Emosi normal namun jika berkepanjangan perlu diperhatikan";
    } else if (selectedPerasaan == 'Perasaan Takut') {
      return "⚡ Takut - Respons terhadap ancaman, perlu identifikasi sumber ketakutan";
    }
    return selectedPerasaan ?? "";
  }

  String _getDeskripsiObservasi() {
    String tekananDarah = _tekananDarahController.text.trim();
    String perasaan = selectedPerasaan?.toLowerCase().replaceAll('Perasaan ', '') ?? "";
    
    return "Tekanan darah tercatat $tekananDarah mmHg dengan kondisi emosional $perasaan. ${_getKesimpulanSingkat()}";
  }

  String _getKesimpulanSingkat() {
    if (_skorStress >= 15) {
      return "Kondisi stress tinggi yang memerlukan perhatian segera";
    } else if (_skorStress >= 10) {
      return "Menunjukkan tanda-tanda stress yang signifikan";
    } else if (_skorStress >= 6) {
      return "Stress dalam level yang perlu dikelola";
    } else if (_skorStress >= 3) {
      return "Kondisi masih terkendali namun perlu pemantauan";
    } else {
      return "Kondisi mental dan fisik dalam keadaan baik";
    }
  }

  List<String> _getRekomendasi() {
    List<String> rekomendasi = [];

    // Rekomendasi berdasarkan tekanan darah
    String tekananDarah = _tekananDarahController.text.trim();
    if (tekananDarah.contains('/')) {
      List<String> parts = tekananDarah.split('/');
      if (parts.length == 2) {
        int? sistolik = int.tryParse(parts[0].trim());
        int? diastolik = int.tryParse(parts[1].trim());

        if (sistolik != null && diastolik != null) {
          if (sistolik >= 180 || diastolik >= 120) {
            rekomendasi.add("SEGERA ke Unit Gawat Darurat! Krisis hipertensi sangat berbahaya dan bisa menyebabkan stroke atau serangan jantung");
          } else if (sistolik >= 140 || diastolik >= 90) {
            rekomendasi.add("Konsultasikan dengan dokter untuk penanganan hipertensi. Mungkin memerlukan obat penurun tekanan darah");
            rekomendasi.add("Kurangi konsumsi garam (maksimal 1 sendok teh/hari), hindari makanan tinggi natrium");
            rekomendasi.add("Olahraga teratur minimal 30 menit/hari, seperti jalan cepat atau bersepeda");
          } else if (sistolik >= 120 || diastolik >= 80) {
            rekomendasi.add("Tekanan darah mulai tinggi. Terapkan pola hidup sehat: diet rendah garam, olahraga teratur");
            rekomendasi.add("Monitor tekanan darah secara rutin, minimal seminggu sekali");
          } else if (sistolik < 90 || diastolik < 60) {
            rekomendasi.add("Tekanan darah rendah. Perbanyak minum air putih (minimal 2 liter/hari)");
            rekomendasi.add("Konsumsi makanan bergaram secukupnya dan hindari berdiri terlalu cepat");
          }
        }
      }
    }

    // Rekomendasi berdasarkan perasaan
    if (selectedPerasaan == 'Perasaan Depresi' || selectedPerasaan == 'Perasaan Obsesi') {
      rekomendasi.add("PENTING: Segera konsultasi dengan psikolog atau psikiater. Kondisi ini memerlukan penanganan profesional");
      rekomendasi.add("Jangan ragu mencari bantuan. Hubungi hotline kesehatan mental: 119 ext 8 atau Sejiwa 119");
      rekomendasi.add("Ceritakan kondisi Anda pada orang terdekat yang dipercaya untuk mendapat dukungan emosional");
    }

    if (selectedPerasaan == 'Perasaan Stres') {
      rekomendasi.add("Praktikkan teknik relaksasi: napas dalam (4-7-8 breathing), meditasi 10 menit/hari");
      rekomendasi.add("Identifikasi sumber stress dan buat rencana untuk mengatasinya secara bertahap");
      rekomendasi.add("Pastikan tidur cukup 7-8 jam/malam. Tidur yang baik membantu mengelola stress");
    }

    if (selectedPerasaan == 'Perasaan Cemas') {
      rekomendasi.add("Latihan grounding 5-4-3-2-1: Sebutkan 5 hal yang dilihat, 4 yang didengar, 3 yang disentuh, 2 yang dicium, 1 yang dikecap");
      rekomendasi.add("Batasi konsumsi kafein dan gula yang bisa memperburuk kecemasan");
      rekomendasi.add("Olahraga ringan seperti yoga atau jalan santai dapat mengurangi kecemasan");
    }

    if (selectedPerasaan == 'Perasaan Marah') {
      rekomendasi.add("Praktikkan teknik time-out: Mundur dari situasi pemicu marah, ambil napas dalam 10x");
      rekomendasi.add("Ekspresikan kemarahan dengan cara sehat: tulis jurnal, bicara dengan orang yang dipercaya");
      rekomendasi.add("Hindari mengambil keputusan penting saat marah. Tenangkan diri terlebih dahulu");
    }

    if (selectedPerasaan == 'Perasaan Sedih') {
      rekomendasi.add("Izinkan diri merasakan kesedihan, ini adalah emosi yang normal dan sehat");
      rekomendasi.add("Lakukan aktivitas yang menyenangkan: dengar musik favorit, bertemu teman, hobi");
      rekomendasi.add("Jika kesedihan berlangsung >2 minggu dan mengganggu aktivitas, konsultasi dengan profesional");
    }

    if (selectedPerasaan == 'Perasaan Takut') {
      rekomendasi.add("Identifikasi apa yang membuat takut dan nilai apakah ketakutan tersebut rasional");
      rekomendasi.add("Hadapi ketakutan secara bertahap dengan exposure therapy (jika memungkinkan)");
      rekomendasi.add("Gunakan afirmasi positif untuk menenangkan diri");
    }

    // Rekomendasi umum manajemen stress
    if (_skorStress >= 6) {
      rekomendasi.add("Buat jadwal harian yang terstruktur untuk mengurangi chaos dan meningkatkan kontrol");
      rekomendasi.add("Praktikkan mindfulness: Fokus pada momen saat ini, bukan khawatir masa depan atau menyesali masa lalu");
    }

    // Rekomendasi diabetes & stress
    rekomendasi.add("Stress dapat meningkatkan kadar gula darah. Monitor gula darah lebih sering saat stress");
    rekomendasi.add("Tetap patuhi jadwal makan dan obat diabetes meskipun sedang stress");

    if (_skorStress < 3 && rekomendasi.isEmpty) {
      rekomendasi.add("Kondisi mental dan emosional Anda baik! Pertahankan kebiasaan positif");
      rekomendasi.add("Terus jaga pola hidup sehat: olahraga teratur, makan bergizi, tidur cukup");
      rekomendasi.add("Luangkan waktu untuk hal yang Anda sukai dan habiskan waktu berkualitas dengan orang terkasih");
    }

    return rekomendasi;
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
                      const Icon(Icons.psychology, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hasil Manajemen Stress',
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

                        // Card Status Stress
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
                                      _skorStress >= 15 ? Icons.warning : 
                                      _skorStress >= 10 ? Icons.error_outline :
                                      _skorStress >= 6 ? Icons.info :
                                      _skorStress >= 3 ? Icons.check_circle : Icons.thumb_up,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Level Stress',
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
                                      _getStatusStress(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Skor Stress: $_skorStress',
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

                        // Analisis Detail
                        const Text(
                          'Analisis Detail:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D2E46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Analisa Tekanan Darah
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFE0B2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.favorite, size: 16, color: Color(0xFFE65100)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tekanan Darah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getAnalisaTekananDarah(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Analisa Perasaan
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.sentiment_satisfied, size: 16, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 6),
                                  Text(
                                    'Kondisi Emosional',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getAnalisisPerasaan(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
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
          'Manajemen Stress',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silahkan lengkapi form dibawah ini untuk melakukan pencatatan management stress',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Tekanan Darah
            const Text(
              'Tekanan Darah :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB83B7E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'mmHg',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tekananDarahController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 120/80',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Perasaan
            const Text(
              'Apa yang Anda rasakan saat ini ?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...daftarPerasaan.map((perasaan) => _buildRadioOption(perasaan)),
            const SizedBox(height: 32),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB83B7E),
                  padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPerasaan = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              child: selectedPerasaan == value
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}