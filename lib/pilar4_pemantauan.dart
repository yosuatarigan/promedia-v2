import 'package:flutter/material.dart';

class Pilar4PemantauanPage extends StatelessWidget {
  const Pilar4PemantauanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFF59E0B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilar 4: Pemantauan Gula Darah',
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
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildMateriCard(
            number: '1',
            title: 'Apa itu PGDM?',
            icon: Icons.info_rounded,
            color: const Color(0xFFF59E0B),
            content: _buildApaItuPGDM(),
          ),
          _buildMateriCard(
            number: '2',
            title: 'Mengapa PGDM Penting',
            icon: Icons.star_rounded,
            color: const Color(0xFFEC4899),
            content: _buildMengapaPenting(),
          ),
          _buildMateriCard(
            number: '3',
            title: 'Kapan Harus Memeriksa',
            icon: Icons.schedule_rounded,
            color: const Color(0xFF8B5CF6),
            content: _buildKapanMemeriksa(),
          ),
          _buildMateriCard(
            number: '4',
            title: 'Cara Memeriksa Gula Darah',
            icon: Icons.assignment_rounded,
            color: const Color(0xFF3B82F6),
            content: _buildCaraMemeriksa(),
          ),
          _buildMateriCard(
            number: '5',
            title: 'Tips Penting',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF10B981),
            content: _buildTipsPenting(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PGDM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pemantauan Glukosa Darah Mandiri',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
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

  Widget _buildApaItuPGDM() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Pemantauan Glukosa Darah Mandiri (PGDM) adalah cara pasien memeriksa kadar gula darah sendiri menggunakan alat glukometer.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tujuannya untuk membantu mengontrol diabetes dan mencegah komplikasi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMengapaPenting() {
    final List<Map<String, dynamic>> alasanList = [
      {
        'icon': Icons.restaurant_rounded,
        'text': 'Mengetahui kadar gula darah sebelum dan sesudah makan',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.medication_rounded,
        'text': 'Membantu dokter menyesuaikan obat atau insulin',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.speed_rounded,
        'text': 'Mendeteksi gula darah tinggi atau rendah lebih cepat',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.self_improvement_rounded,
        'text': 'Meningkatkan kemandirian pasien dalam pengelolaan diabetes',
        'color': const Color(0xFF10B981),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alasanList.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item['color'].withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'],
                  color: item['color'],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['text'],
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKapanMemeriksa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Pemeriksaan Rutin:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildWaktuItem('Sebelum makan', 'Puasa, sarapan, makan siang, makan malam', Icons.lunch_dining_rounded),
        _buildWaktuItem('2 jam setelah makan', 'Untuk pemantauan', Icons.timer_rounded),
        _buildWaktuItem('Sebelum tidur', 'Memastikan kadar stabil', Icons.bedtime_rounded),
        const SizedBox(height: 16),
        const Text(
          'Saat Merasa Gejala:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildGejalaBox(
          'Hipoglikemia (Gula Rendah)',
          'Lemas, gemetar, berkeringat, pusing',
          const Color(0xFFEF4444),
        ),
        const SizedBox(height: 8),
        _buildGejalaBox(
          'Hiperglikemia (Gula Tinggi)',
          'Sering haus, sering buang air kecil',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF8B5CF6),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Frekuensi pemeriksaan bisa berbeda tergantung saran dokter dan jenis terapi',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuItem(String waktu, String keterangan, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8B5CF6),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waktu,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  keterangan,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGejalaBox(String title, String gejala, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
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
                Text(
                  gejala,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaraMemeriksa() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image 1
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar4/1.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Image 2
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar4/2.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Steps
        const Text(
          'Langkah-langkah:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStepItem(1, 'Cuci tangan dengan sabun dan air bersih'),
        _buildStepItem(2, 'Siapkan glukometer, strip tes, dan lancet'),
        _buildStepItem(3, 'Tusuk ujung jari dengan lancet, teteskan darah pada strip'),
        _buildStepItem(4, 'Tunggu hasil muncul di glukometer'),
        _buildStepItem(5, 'Catat hasil pada buku catatan atau aplikasi kesehatan'),
      ],
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsPenting() {
    final List<Map<String, dynamic>> tipsList = [
      {
        'icon': Icons.book_rounded,
        'text': 'Selalu bawa buku catatan atau aplikasi untuk mencatat hasil',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.build_rounded,
        'text': 'Gunakan glukometer yang terkalibrasi dan strip tes masih berlaku',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.notifications_active_rounded,
        'text': 'Jangan menunggu gejala, cek rutin sesuai anjuran dokter',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.verified_rounded,
        'text': 'Jangan tergiur alat murah, pastikan memiliki standar SNI',
        'color': const Color(0xFFEF4444),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tipsList.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'].withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item['color'].withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'],
                  color: item['color'],
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['text'],
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}