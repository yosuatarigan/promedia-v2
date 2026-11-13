// Logika perhitungan aktivitas pasien untuk Admin Panel.
//
// Isi fungsi DISALIN APA ADANYA dari layar input aplikasi mobile:
//   - latihan_fisik_screen.dart   (_hitungKalori, _getKategoriIntensitas,
//                                  _getManfaat, _getRekomendasi)
//   - perawatan_kaki_screen.dart  (_hitungSkorRisiko, _getStatusKondisi,
//                                  _getDeskripsiObservasi, _getRekomendasi)
//   - manajemen_stress.dart       (_hitungSkorStress, _getStatusStress, ...)
//   - pengelolaan_makanan_screen.dart, terapi_obat_screen.dart (pilihan)
// sehingga catatan yang diinput admin identik dengan input dari aplikasi.
// Bila rumus di layar aplikasi diubah, ubah juga di sini.

// ignore_for_file: prefer_const_declarations

// ───────────────────────── Makan ─────────────────────────

class FoodLogic {
  static const List<String> porsiOptions = [
    '1 piring',
    '½ piring',
    '¼ piring',
    '1/3 piring',
  ];

  static double porsiToGrams(String porsi) {
    switch (porsi) {
      case '1 piring':
        return 200;
      case '½ piring':
        return 100;
      case '¼ piring':
        return 50;
      case '1/3 piring':
        return 67;
      default:
        return 0;
    }
  }

  static String waktuMakan(int hour) {
    if (hour >= 5 && hour < 11) return 'Pagi';
    if (hour >= 11 && hour < 16) return 'Siang';
    return 'Malam';
  }

  static const List<String> kategoriOptions = ['Makan Utama', 'Snack'];
  static const List<String> waktuOptions = ['Pagi', 'Siang', 'Malam'];
}

// ───────────────────────── Obat ─────────────────────────

class MedicationLogic {
  static const List<String> jenisObatList = [
    // Biguanid
    'Metformin',
    // Sulfonilurea
    'Glibenclamide',
    'Gliclazide',
    'Glimepiride',
    'Glipizide',
    // Tiazolidindion
    'Pioglitazone',
    // Penghambat Alfa-Glukosidase
    'Acarbose',
    // DPP-4 Inhibitor
    'Sitagliptin',
    'Vildagliptin',
    'Saxagliptin',
    'Linagliptin',
    // SGLT-2 Inhibitor
    'Empagliflozin',
    'Dapagliflozin',
    'Canagliflozin',
    // GLP-1 Agonis
    'Liraglutide',
    'Dulaglutide',
    'Exenatide',
    // Insulin
    'Insulin',
    // Lainnya
    'Lainnya',
  ];

  static const List<String> waktuOptions = ['Pagi', 'Siang', 'Malam'];
  static const List<String> satuanOptions = ['Tablet', 'Unit'];

  /// Sama dengan aplikasi: Insulin → Unit, selain itu Tablet.
  static String defaultSatuan(String? jenisObat) =>
      jenisObat == 'Insulin' ? 'Unit' : 'Tablet';
}

// ───────────────────────── Latihan fisik ─────────────────────────

class ExerciseLogic {
  static const List<String> daftarOlahraga = [
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
    'Rumah Tangga',
  ];

  static const List<String> satuanDurasiOptions = ['Menit', 'Total Durasi'];

  static int hitungKalori(String jenis, int durasi) {
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
      'Rumah Tangga': 3.0,
    };

    return ((kaloriPerMenit[jenis] ?? 5.0) * durasi).round();
  }

  static String kategoriIntensitas(int durasi) {
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

  static List<String> manfaat(String jenis, int durasi) {
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
      case 'Rumah Tangga':
        manfaat.add('✓ Aktivitas ringan-sedang yang baik untuk penderita DM');
        break;
      default:
        manfaat.add('✓ Meningkatkan koordinasi dan ketangkasan');
    }

    if (durasi >= 30) {
      manfaat.add('✓ Durasi optimal untuk manfaat kesehatan maksimal');
    }

    return manfaat;
  }

  static List<String> rekomendasi(int durasi) {
    List<String> rekomendasi = [];

    if (durasi < 30) {
      rekomendasi.add(
        '💡 Tingkatkan durasi menjadi minimal 30 menit untuk manfaat optimal',
      );
      rekomendasi.add(
        '💡 Lakukan olahraga secara bertahap, tambah 5 menit setiap minggu',
      );
    } else if (durasi >= 30 && durasi < 60) {
      rekomendasi.add('✅ Durasi sudah bagus! Pertahankan konsistensi');
      rekomendasi.add(
        '💡 Lakukan minimal 3-5 kali seminggu untuk hasil terbaik',
      );
    } else {
      rekomendasi.add('👏 Luar biasa! Durasi olahraga Anda sangat baik');
      rekomendasi.add('💡 Pastikan istirahat cukup untuk pemulihan otot');
    }

    rekomendasi.add(
      '💧 Jangan lupa minum air putih 500ml sebelum dan sesudah olahraga',
    );
    rekomendasi.add('🍎 Konsumsi makanan bergizi 1-2 jam sebelum olahraga');
    rekomendasi.add(
      '📊 Untuk diabetes: Monitor gula darah sebelum dan sesudah olahraga',
    );
    rekomendasi.add(
      '⚠️ Hentikan jika merasa pusing, nyeri dada, atau sesak nafas',
    );

    return rekomendasi;
  }
}

// ───────────────────────── Perawatan kaki ─────────────────────────

class FootCareLogic {
  static const List<String> kondisiOptions = [
    'Tidak ada masalah',
    'Lepuh, luka gores, atau sayatan',
    'Perubahan warna kulit (biru, merah terang, atau bercak putih)',
    'Kulit terlalu kering',
    'Kapur/tumit tebal (callus) atau mata ikan (corns)',
    'Bengkak',
  ];

  final Set<String> kondisiKaki;
  final String? memeriksaSepatu;
  final String? mengeringkanKaki;
  final String? menggunakanAlasKaki;
  final String? menggunakanPelembab;

  const FootCareLogic({
    required this.kondisiKaki,
    required this.memeriksaSepatu,
    required this.mengeringkanKaki,
    required this.menggunakanAlasKaki,
    required this.menggunakanPelembab,
  });

  int get _skorRisiko => hitungSkorRisiko();

  int hitungSkorRisiko() {
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
    if (kondisiKaki.any(
      (k) => k.contains("Kapur") || k.contains("mata ikan"),
    )) {
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

  String getStatusKondisi() {
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

  String getDeskripsiObservasi() {
    List<String> deskripsi = [];

    // Deskripsi kondisi kaki
    if (kondisiKaki.contains('Tidak ada masalah')) {
      deskripsi.add('Kondisi kaki tidak ada masalah');
    } else if (kondisiKaki.isNotEmpty) {
      String kondisiText =
          "Kondisi Kaki ${kondisiKaki.join(", ").toLowerCase()}";
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

  List<String> getRekomendasi() {
    List<String> rekomendasi = [];

    // Rekomendasi berdasarkan kondisi kaki (prioritas)
    if (kondisiKaki.any((k) => k.contains("Lepuh") || k.contains("luka"))) {
      rekomendasi.add(
        "SEGERA konsultasi dengan dokter atau perawat diabetes untuk penanganan luka. Luka pada penderita diabetes dapat berkembang menjadi infeksi serius",
      );
      rekomendasi.add(
        "Jangan mengobati luka sendiri. Bersihkan dengan air bersih dan tutup dengan perban steril sambil menunggu pemeriksaan medis",
      );
    }

    if (kondisiKaki.any((k) => k.contains("Perubahan warna"))) {
      rekomendasi.add(
        "Perubahan warna kulit dapat mengindikasikan masalah sirkulasi darah. Segera periksakan ke dokter untuk evaluasi lebih lanjut",
      );
    }

    if (kondisiKaki.any((k) => k.contains("Bengkak"))) {
      rekomendasi.add(
        "Pembengkakan kaki memerlukan pemeriksaan dokter untuk mengetahui penyebabnya (bisa jantung, ginjal, atau masalah pembuluh darah)",
      );
      rekomendasi.add(
        "Sementara menunggu pemeriksaan, tinggikan kaki saat berbaring dan kurangi konsumsi garam",
      );
    }

    if (kondisiKaki.any(
      (k) => k.contains("Kapur") || k.contains("mata ikan"),
    )) {
      rekomendasi.add(
        "Untuk kapalan/mata ikan: rendam kaki dengan air hangat 10-15 menit, lalu gosok perlahan dengan batu apung",
      );
      rekomendasi.add(
        "JANGAN memotong atau mengiris kapalan sendiri karena berisiko luka. Konsultasikan ke podiatris jika mengganggu",
      );
    }

    if (kondisiKaki.any((k) => k.contains("Kulit terlalu kering"))) {
      rekomendasi.add(
        "Oleskan pelembab khusus kaki 2x sehari (pagi dan malam). Pilih pelembab yang mengandung urea atau lanolin",
      );
      rekomendasi.add(
        "Hindari mengoleskan pelembab di sela-sela jari kaki untuk mencegah jamur",
      );
    }

    // Rekomendasi berdasarkan kebiasaan yang perlu diperbaiki
    if (memeriksaSepatu == "Tidak") {
      rekomendasi.add(
        "Biasakan memeriksa bagian dalam sepatu sebelum dipakai. Batu kecil, jahitan yang tajam, atau benda asing bisa melukai kaki tanpa Anda sadari",
      );
    }

    if (mengeringkanKaki == "Tidak") {
      rekomendasi.add(
        "PENTING: Keringkan kaki dengan seksama setelah mandi, terutama sela-sela jari. Kelembaban berlebih dapat menyebabkan infeksi jamur",
      );
    }

    if (menggunakanAlasKaki == "Tidak") {
      rekomendasi.add(
        "Selalu gunakan alas kaki, bahkan di dalam rumah. Kaki penderita diabetes rentan cedera dan sering tidak merasakan sakit saat terluka",
      );
    }

    if (menggunakanPelembab == "Tidak") {
      rekomendasi.add(
        "Gunakan pelembab atau lotion setiap hari untuk mencegah kulit kering dan pecah-pecah yang bisa menjadi pintu masuk infeksi",
      );
    }

    // Rekomendasi umum pencegahan
    if (_skorRisiko >= 6) {
      rekomendasi.add(
        "Lakukan pemeriksaan kaki setiap hari. Gunakan cermin untuk melihat bagian bawah kaki jika sulit menekuk",
      );
      rekomendasi.add(
        "Kontrol gula darah secara ketat. HbA1c yang baik (<7%) membantu penyembuhan dan mencegah komplikasi",
      );
    }

    if (_skorRisiko < 3 && rekomendasi.isEmpty) {
      rekomendasi.add(
        "Kebiasaan perawatan kaki Anda sudah baik! Pertahankan dan lakukan pemeriksaan rutin",
      );
      rekomendasi.add(
        "Tetap kontrol gula darah dan lakukan pemeriksaan kaki menyeluruh setiap 3 bulan ke tenaga kesehatan",
      );
    }

    return rekomendasi;
  }
}

// ───────────────────────── Manajemen stress ─────────────────────────

class _TextValue {
  final String text;
  const _TextValue(this.text);
}

class StressLogic {
  static const List<String> daftarPerasaan = [
    'Perasaan Senang',
    'Perasaan Marah',
    'Perasaan Takut',
    'Perasaan Stres',
    'Perasaan Sedih',
    'Perasaan Cemas',
    'Perasaan Obsesi',
    'Perasaan Depresi',
  ];

  /// Teks tekanan darah persis seperti diketik (mis. "120/80" atau kosong).
  final String tekananDarah;
  final String? selectedPerasaan;

  const StressLogic({
    required this.tekananDarah,
    required this.selectedPerasaan,
  });

  // Agar isi fungsi dari layar aplikasi dapat dipakai tanpa diubah.
  _TextValue get _tekananDarahController => _TextValue(tekananDarah);
  int get _skorStress => hitungSkorStress();
  String _getKesimpulanSingkat() => getKesimpulanSingkat();

  int hitungSkorStress() {
    int skor = 0;

    // Skor berdasarkan tekanan darah
    String tekananDarah = _tekananDarahController.text.trim();
    if (tekananDarah.contains('/')) {
      List<String> parts = tekananDarah.split('/');
      if (parts.length == 2) {
        int? sistolik = int.tryParse(parts[0].trim());
        int? diastolik = int.tryParse(parts[1].trim());

        if (sistolik != null && diastolik != null) {
          // Krisis hipertensi (≥180/120)
          if (sistolik >= 180 || diastolik >= 120) {
            skor += 10;
          }
          // Hipertensi tingkat 2 (≥140/90)
          else if (sistolik >= 140 || diastolik >= 90) {
            skor += 8;
          }
          // Hipertensi tingkat 1 (≥130/85)
          else if (sistolik >= 130 || diastolik >= 85) {
            skor += 6;
          }
          // Prehipertensi (≥120/80)
          else if (sistolik >= 120 || diastolik >= 80) {
            skor += 4;
          }
          // Hipotensi (<90/60)
          else if (sistolik < 90 || diastolik < 60) {
            skor += 5;
          }
          // Normal (90-119 / 60-79) → skor += 0
        }
      }
    }

    // Skor berdasarkan perasaan
    if (selectedPerasaan == 'Perasaan Depresi' ||
        selectedPerasaan == 'Perasaan Obsesi') {
      skor += 10; // Sangat serius
    } else if (selectedPerasaan == 'Perasaan Stres' ||
        selectedPerasaan == 'Perasaan Cemas') {
      skor += 7; // Serius
    } else if (selectedPerasaan == 'Perasaan Marah' ||
        selectedPerasaan == 'Perasaan Sedih') {
      skor += 5; // Sedang
    } else if (selectedPerasaan == 'Perasaan Takut') {
      skor += 4; // Ringan-Sedang
    } else if (selectedPerasaan == 'Perasaan Senang') {
      skor += 0; // Baik
    }

    return skor;
  }

  String getStatusStress() {
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

  String getAnalisaTekananDarah() {
    String tekananDarah = _tekananDarahController.text.trim();
    if (tekananDarah.isEmpty) {
      return "Tekanan darah tidak diisi";
    }
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
    } else if (sistolik >= 90 &&
        diastolik >= 60 &&
        sistolik < 120 &&
        diastolik < 80) {
      return "✅ Normal - Tekanan darah dalam batas normal";
    } else if (sistolik < 90 || diastolik < 60) {
      return "🔵 Hipotensi - Tekanan darah rendah, bisa menyebabkan pusing";
    }

    return "Tekanan darah: $tekananDarah mmHg";
  }

  String getAnalisisPerasaan() {
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

  String getDeskripsiObservasi() {
    String tekananDarah = _tekananDarahController.text.trim();
    String perasaan =
        selectedPerasaan?.toLowerCase().replaceAll('Perasaan ', '') ?? "";
    String tdInfo =
        tekananDarah.isEmpty
            ? 'Tekanan darah tidak diisi'
            : 'Tekanan darah tercatat $tekananDarah mmHg';

    return "$tdInfo dengan kondisi emosional $perasaan. ${_getKesimpulanSingkat()}";
  }

  String getKesimpulanSingkat() {
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

  List<String> getRekomendasi() {
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
            rekomendasi.add(
              "SEGERA ke Unit Gawat Darurat! Krisis hipertensi sangat berbahaya dan bisa menyebabkan stroke atau serangan jantung",
            );
          } else if (sistolik >= 140 || diastolik >= 90) {
            rekomendasi.add(
              "Konsultasikan dengan dokter untuk penanganan hipertensi. Mungkin memerlukan obat penurun tekanan darah",
            );
            rekomendasi.add(
              "Kurangi konsumsi garam (maksimal 1 sendok teh/hari), hindari makanan tinggi natrium",
            );
            rekomendasi.add(
              "Olahraga teratur minimal 30 menit/hari, seperti jalan cepat atau bersepeda",
            );
          } else if (sistolik >= 120 || diastolik >= 80) {
            rekomendasi.add(
              "Tekanan darah mulai tinggi. Terapkan pola hidup sehat: diet rendah garam, olahraga teratur",
            );
            rekomendasi.add(
              "Monitor tekanan darah secara rutin, minimal seminggu sekali",
            );
          } else if (sistolik < 90 || diastolik < 60) {
            rekomendasi.add(
              "Tekanan darah rendah. Perbanyak minum air putih (minimal 2 liter/hari)",
            );
            rekomendasi.add(
              "Konsumsi makanan bergaram secukupnya dan hindari berdiri terlalu cepat",
            );
          }
        }
      }
    }

    // Rekomendasi berdasarkan perasaan
    if (selectedPerasaan == 'Perasaan Depresi' ||
        selectedPerasaan == 'Perasaan Obsesi') {
      rekomendasi.add(
        "PENTING: Segera konsultasi dengan psikolog atau psikiater. Kondisi ini memerlukan penanganan profesional",
      );
      rekomendasi.add(
        "Jangan ragu mencari bantuan. Hubungi hotline kesehatan mental: 119 ext 8 atau Sejiwa 119",
      );
      rekomendasi.add(
        "Ceritakan kondisi Anda pada orang terdekat yang dipercaya untuk mendapat dukungan emosional",
      );
    }

    if (selectedPerasaan == 'Perasaan Stres') {
      rekomendasi.add(
        "Praktikkan teknik relaksasi: napas dalam (4-7-8 breathing), meditasi 10 menit/hari",
      );
      rekomendasi.add(
        "Identifikasi sumber stress dan buat rencana untuk mengatasinya secara bertahap",
      );
      rekomendasi.add(
        "Pastikan tidur cukup 7-8 jam/malam. Tidur yang baik membantu mengelola stress",
      );
    }

    if (selectedPerasaan == 'Perasaan Cemas') {
      rekomendasi.add(
        "Latihan grounding 5-4-3-2-1: Sebutkan 5 hal yang dilihat, 4 yang didengar, 3 yang disentuh, 2 yang dicium, 1 yang dikecap",
      );
      rekomendasi.add(
        "Batasi konsumsi kafein dan gula yang bisa memperburuk kecemasan",
      );
      rekomendasi.add(
        "Olahraga ringan seperti yoga atau jalan santai dapat mengurangi kecemasan",
      );
    }

    if (selectedPerasaan == 'Perasaan Marah') {
      rekomendasi.add(
        "Praktikkan teknik time-out: Mundur dari situasi pemicu marah, ambil napas dalam 10x",
      );
      rekomendasi.add(
        "Ekspresikan kemarahan dengan cara sehat: tulis jurnal, bicara dengan orang yang dipercaya",
      );
      rekomendasi.add(
        "Hindari mengambil keputusan penting saat marah. Tenangkan diri terlebih dahulu",
      );
    }

    if (selectedPerasaan == 'Perasaan Sedih') {
      rekomendasi.add(
        "Izinkan diri merasakan kesedihan, ini adalah emosi yang normal dan sehat",
      );
      rekomendasi.add(
        "Lakukan aktivitas yang menyenangkan: dengar musik favorit, bertemu teman, hobi",
      );
      rekomendasi.add(
        "Jika kesedihan berlangsung >2 minggu dan mengganggu aktivitas, konsultasi dengan profesional",
      );
    }

    if (selectedPerasaan == 'Perasaan Takut') {
      rekomendasi.add(
        "Identifikasi apa yang membuat takut dan nilai apakah ketakutan tersebut rasional",
      );
      rekomendasi.add(
        "Hadapi ketakutan secara bertahap dengan exposure therapy (jika memungkinkan)",
      );
      rekomendasi.add("Gunakan afirmasi positif untuk menenangkan diri");
    }

    // Rekomendasi umum manajemen stress
    if (_skorStress >= 6) {
      rekomendasi.add(
        "Buat jadwal harian yang terstruktur untuk mengurangi chaos dan meningkatkan kontrol",
      );
      rekomendasi.add(
        "Praktikkan mindfulness: Fokus pada momen saat ini, bukan khawatir masa depan atau menyesali masa lalu",
      );
    }

    // Rekomendasi diabetes & stress
    rekomendasi.add(
      "Stress dapat meningkatkan kadar gula darah. Monitor gula darah lebih sering saat stress",
    );
    rekomendasi.add(
      "Tetap patuhi jadwal makan dan obat diabetes meskipun sedang stress",
    );

    if (_skorStress < 3 && rekomendasi.isEmpty) {
      rekomendasi.add(
        "Kondisi mental dan emosional Anda baik! Pertahankan kebiasaan positif",
      );
      rekomendasi.add(
        "Terus jaga pola hidup sehat: olahraga teratur, makan bergizi, tidur cukup",
      );
      rekomendasi.add(
        "Luangkan waktu untuk hal yang Anda sukai dan habiskan waktu berkualitas dengan orang terkasih",
      );
    }

    return rekomendasi;
  }
}
