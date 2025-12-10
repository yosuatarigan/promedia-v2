import 'package:flutter/material.dart';

class Pilar6PencegahanKomplikasiPage extends StatelessWidget {
  const Pilar6PencegahanKomplikasiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFEF4444),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilar 6: Pencegahan Komplikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMateriCard(
            number: '1',
            title: 'Hipoglikemia (Gula Rendah)',
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFFEF4444),
            content: _buildHipoglikemia(),
          ),
          _buildMateriCard(
            number: '2',
            title: 'Hiperglikemia (Gula Tinggi)',
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFF59E0B),
            content: _buildHiperglikemia(),
          ),
          _buildMateriCard(
            number: '3',
            title: 'Komplikasi Luka pada Kaki',
            icon: Icons.healing_rounded,
            color: const Color(0xFF8B5CF6),
            content: _buildKomplikasiKaki(),
          ),
          _buildMateriCard(
            number: '4',
            title: 'Waspada Komplikasi Diabetes',
            icon: Icons.warning_rounded,
            color: const Color(0xFFEC4899),
            content: _buildWaspadaKomplikasi(),
          ),
          _buildMateriCard(
            number: '5',
            title: 'Kelola Stress',
            icon: Icons.spa_rounded,
            color: const Color(0xFF10B981),
            content: _buildKelolaStress(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMateriCard({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          children: [
            const Divider(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildHipoglikemia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image 1 - Sudah berisi tanda gejala hipoglikemia
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar6/1.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Text(
          'Apa yang harus dilakukan?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          '1. Konsumsi Karbohidrat Cepat',
          'Air gula (2-3 sdm dalam 1 gelas) atau 2-3 sdm sirup/madu',
          Icons.local_drink_rounded,
          const Color(0xFF3B82F6),
        ),
        _buildActionCard(
          '2. Tunggu 15 Menit',
          'Periksa apakah gejala membaik. Jika belum, berikan kembali air gula',
          Icons.timer_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildActionCard(
          '3. Periksa Gula Darah',
          'Jika masih <70 mg/dL, ulangi langkah 1 dan 2',
          Icons.monitor_heart_rounded,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        _buildKisahBox(
          'Kisah Pak Yaya',
          'Pak Yaya minum glibenklamid tapi sarapan terlambat. Di ladang ia gemetar, berkeringat, gula darah 78 mg/dL. Tindakan: minum air gula 3 sdm, istirahat 15 menit, lalu makan nasi.',
          const Color(0xFFEC4899),
        ),
        const SizedBox(height: 16),
        _buildTipsBox(
          'Tips Menangani Hipoglikemia',
          [
            'Jangan lewatkan makan setelah minum obat/insulin',
            'Selalu bawa permen atau gula saat bepergian',
            'Kenali tanda awal dan segera tangani',
          ],
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildHiperglikemia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image 5 - Sudah berisi tanda gejala hiperglikemia
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar6/5.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Text(
          'Cara Mengatasi:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          '1. Periksa Gula Darah',
          'Gunakan alat pengukur gula darah',
          Icons.science_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildActionCard(
          '2. Minum Air Banyak',
          'Membantu mengeluarkan kelebihan gula melalui urin',
          Icons.water_drop_rounded,
          const Color(0xFF3B82F6),
        ),
        _buildActionCard(
          '3. Olahraga Ringan',
          'Jika tidak ada masalah kesehatan lain',
          Icons.directions_walk_rounded,
          const Color(0xFF10B981),
        ),
        _buildActionCard(
          '4. Ikuti Instruksi Dokter',
          'Terkait dosis insulin atau obat',
          Icons.medical_services_rounded,
          const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFEF4444).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444), size: 20),
                  const SizedBox(width: 10),
                  const Text(
                    'Kapan Harus ke RS?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika gula darah >300 mg/dL atau ada gejala: nafas berbau buah, mual, muntah → segera ke RS! Bisa jadi ketoasidosis diabetik.',
                style: TextStyle(fontSize: 11, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildKisahBox(
          'Kisah Pak Yaya',
          'Sibuk kerja, makan tidak teratur, lupa obat. Gula darah 350 mg/dL. Pelajaran: kesibukan bukan alasan mengabaikan perawatan diri.',
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildKomplikasiKaki() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSubSection(
          'Waspadai Tanda-Tanda',
          Icons.visibility_rounded,
          const Color(0xFF8B5CF6),
          [
            'Lepuh, luka gores, sayatan',
            'Perubahan warna kulit (biru, merah, putih)',
            'Kulit terlalu kering',
            'Kapur/tumit tebal, mata ikan',
            'Bengkak',
          ],
        ),
        const SizedBox(height: 16),
        _buildSubSection(
          'Senam Kaki',
          Icons.self_improvement_rounded,
          const Color(0xFF10B981),
          [
            'Gerakkan telapak ke atas, tekuk jari seperti cakar (10x)',
            'Angkat telapak, tumit di lantai, turun-naik (10x)',
            'Putar pergelangan kaki (10x)',
            'Angkat kaki, luruskan, gerakkan ujung jari ke wajah (10x)',
            'Bentuk koran jadi bola dengan kaki, buka kembali (1x)',
          ],
        ),
        const SizedBox(height: 16),
        // Image 2 - Sudah berisi tips memilih sepatu lengkap
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar6/2.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        _buildTipsDetailCard(
          'Tips Memotong Kuku',
          [
            'Potong kuku lurus (jangan melengkung)',
            'Jangan potong sudut lebih pendek dari bantalan',
            'Gunakan kikir untuk merapikan',
            'Hindari alat potong bersama orang lain',
            'Gunakan alat pemotong kuku, bukan pisau/silet',
          ],
          Icons.cut_rounded,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildTipsDetailCard(
          'Tips Pemeriksaan Kaki',
          [
            'Periksa di antara semua jari kaki',
            'Periksa area kuku (jamur/cantengan)',
            'Gunakan cermin untuk lihat telapak kaki',
            'Jangan pecahkan lepuh',
            'Hindari penghangat langsung (botol air panas)',
            'Selalu pakai alas kaki jika kaki kebas',
          ],
          Icons.search_rounded,
          const Color(0xFFEC4899),
        ),
        const SizedBox(height: 16),
        _buildKisahBox(
          'Kisah Pak Yaya',
          'Kaki dingin, dijulurkan ke tungku api. Pagi hari kulit melepuh dan gosong tanpa terasa. Sejak itu selalu pakai kaus kaki hangat, bukan api.',
          const Color(0xFFEF4444),
        ),
        const SizedBox(height: 16),
        _buildPerawatanLukaSection(),
      ],
    );
  }

  Widget _buildPerawatanLukaSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.healing_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Tips Perawatan Luka',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPerawatanItem('Cuci tangan sebelum & sesudah perawatan'),
          _buildPerawatanItem('Periksa luka setiap hari'),
          _buildPerawatanItem('Bersihkan dengan NaCl 0.9% (jangan alkohol/betadine)'),
          _buildPerawatanItem('Tutup dengan kasa steril, ganti setiap hari'),
          _buildPerawatanItem('Jaga luka tetap lembab tapi tidak becek'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kapan ke Fasilitas Kesehatan?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '• Luka tidak sembuh >7 hari\n• Bernanah/berbau busuk\n• Bengkak/demam\n• Ada bagian hitam (gangren)',
                  style: TextStyle(fontSize: 11, color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerawatanItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaspadaKomplikasi() {
    final List<Map<String, dynamic>> komplikasiList = [
      {'icon': Icons.remove_red_eye_rounded, 'text': 'Mata (retinopati)', 'color': const Color(0xFFEC4899)},
      {'icon': Icons.water_damage_rounded, 'text': 'Ginjal (nefropati)', 'color': const Color(0xFF3B82F6)},
      {'icon': Icons.psychology_rounded, 'text': 'Saraf (neuropati)', 'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.favorite_rounded, 'text': 'Jantung & pembuluh darah', 'color': const Color(0xFFEF4444)},
      {'icon': Icons.directions_walk_rounded, 'text': 'Kaki diabetes', 'color': const Color(0xFFF59E0B)},
      {'icon': Icons.sick_rounded, 'text': 'Infeksi berulang', 'color': const Color(0xFF10B981)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Komplikasi:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...komplikasiList.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: item['color'].withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(item['icon'], color: item['color'], size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                item['text'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        )).toList(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pencegahan Umum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildPencegahanItem('Kendalikan gula darah, tekanan darah, kolesterol'),
              _buildPencegahanItem('Pola makan sehat & olahraga teratur'),
              _buildPencegahanItem('Berhenti merokok, kelola stres'),
              _buildPencegahanItem('Periksa rutin komplikasi tiap tahun'),
              _buildPencegahanItem('Rawat kaki setiap hari dan ikuti pengobatan'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPencegahanItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKelolaStress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image 3 - Manajemen Stress Edukasi
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar6/3.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Image 4 - 5 Praktik Pereda Stress (Sudah lengkap di gambar)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar6/4.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Tambahan info yang tidak ada di gambar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Berdoa & Mendekatkan Diri',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lepaskan beban hati, tumbuhkan syukur, beri ketenangan batin',
                      style: TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStressCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionBox(String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKisahBox(String title, String story, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(story, style: const TextStyle(fontSize: 11, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTipsBox(String title, List<String> tips, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: color, size: 12),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(tip, style: const TextStyle(fontSize: 11, height: 1.4))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color, fontSize: 12)),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 11, height: 1.4))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTipsDetailCard(String title, List<String> tips, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(child: Text(tip, style: const TextStyle(fontSize: 11, height: 1.3))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}