import 'package:flutter/material.dart';

class Pilar5PenggunaanObatPage extends StatelessWidget {
  const Pilar5PenggunaanObatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilar 5: Penggunaan Obat',
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
          _buildHeaderSection(),
          const SizedBox(height: 16),
          _buildMateriCard(
            number: '1',
            title: 'Obat Diabetes Oral',
            icon: Icons.medication_rounded,
            color: const Color(0xFF3B82F6),
            content: _buildObatOral(),
          ),
          _buildMateriCard(
            number: '2',
            title: 'Obat Diabetes Suntik (Insulin)',
            icon: Icons.science_rounded,
            color: const Color(0xFF8B5CF6),
            content: _buildObatSuntik(),
          ),
          _buildMateriCard(
            number: '3',
            title: 'Tips Penggunaan Obat',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF10B981),
            content: _buildTips(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Image
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/edukasi/pilar5/1.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Info Cards
        _buildInfoCard(
          'Kapan Obat Dibutuhkan?',
          'Obat diabetes dan insulin dibutuhkan jika pengelolaan makan dan olahraga saja belum cukup menurunkan gula darah.',
          Icons.help_outline_rounded,
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Tujuan Pengobatan',
          'Menjaga gula darah tetap terkendali dan mencegah komplikasi. Obat tidak menyembuhkan, tetapi membantu mengontrol.',
          Icons.track_changes_rounded,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 12),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Jangan hentikan obat sendiri! Patuhi aturan minum obat dan konsultasikan jika ada keluhan.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEF4444),
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

  Widget _buildInfoCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
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

  Widget _buildObatOral() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildObatItem(
          'Biguanide (Metformin)',
          'Diminum saat atau sesudah makan',
          'Mual, diare ringan (biasanya hilang setelah beberapa hari)',
          const Color(0xFF3B82F6),
        ),
        _buildObatItem(
          'Penghambat Alfa Glukosidase',
          'Diminum bersamaan suapan pertama makanan',
          'Kembung, sering buang gas (hilang setelah beberapa minggu)',
          const Color(0xFF10B981),
        ),
        _buildObatItem(
          'DPP-4 Inhibitor',
          'Sesuai rekomendasi dokter (sebelum/sesudah makan)',
          'Sakit kepala ringan, pilek atau batuk ringan',
          const Color(0xFF8B5CF6),
        ),
        _buildObatItem(
          'Thiazolidinedione (TZD)',
          'Sekali sehari (sebelum/sesudah makan)',
          'Tidak untuk gagal jantung berat. Waspadai gejala gangguan hati',
          const Color(0xFFF59E0B),
        ),
        _buildObatItem(
          'Sulfonilurea',
          'Sebelum/bersamaan makan utama',
          'Risiko hipoglikemia! Jangan lewatkan makan',
          const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildObatItem(String nama, String caraMinum, String efekSamping, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.medication_liquid_rounded,
              color: color,
              size: 18,
            ),
          ),
          title: Text(
            nama,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          children: [
            _buildDetailRow('Cara Minum', caraMinum, Icons.schedule_rounded),
            const SizedBox(height: 8),
            _buildDetailRow('Efek Samping', efekSamping, Icons.warning_amber_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObatSuntik() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInsulinCard(
          'Intermediate-Acting (NPH)',
          'Insulatard®, Humulin N®, Novolin N®',
          '10-15 menit sebelum makan',
          const Color(0xFF8B5CF6),
        ),
        _buildInsulinCard(
          'Long-Acting (Basal)',
          'Lantus®, Levemir®, Tresiba®',
          'Tidak tergantung waktu makan',
          const Color(0xFF3B82F6),
        ),
        _buildInsulinCard(
          'Rapid-Acting',
          'Humalog®, NovoRapid®, Apidra®',
          '10-15 menit sebelum makan',
          const Color(0xFFEC4899),
        ),
        _buildInsulinCard(
          'Short-Acting',
          'Humulin R®, Novolin R®',
          '30 menit sebelum makan',
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
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
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Waspadai Efek Samping',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildWarningItem('Hipoglikemia: lemas, gemetar, berkeringat → konsumsi makanan manis'),
              _buildWarningItem('Benjolan/kemerahan di tempat suntikan'),
              _buildWarningItem('Rotasi tempat suntikan untuk mencegah kulit menebal'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsulinCard(String jenis, String contoh, String waktu, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
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
                child: Icon(
                  Icons.vaccines_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  jenis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            contoh,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  waktu,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
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
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.circle,
              color: Colors.white,
              size: 6,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipCard(
          'Lupa Minum/Suntik',
          'Jika sudah terlanjur makan, cek gula darah. Bila tinggi segera minum obat sesuai anjuran.',
          Icons.access_alarm_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildTipCard(
          'Sedang Sakit',
          'Cek gula darah dulu sebelum minum obat. Jika gula rendah, tunda obat dan konsultasi ke tenaga kesehatan.',
          Icons.sick_rounded,
          const Color(0xFFEF4444),
        ),
        _buildTipCard(
          'Jangan Hentikan Sendiri',
          'Jangan menghentikan obat tanpa anjuran dokter. Konsultasikan jika ada keluhan.',
          Icons.cancel_rounded,
          const Color(0xFF8B5CF6),
        ),
        _buildTipCard(
          'Saat Bepergian',
          'Bawa obat saat bepergian dan simpan insulin sesuai suhu anjuran.',
          Icons.luggage_rounded,
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}