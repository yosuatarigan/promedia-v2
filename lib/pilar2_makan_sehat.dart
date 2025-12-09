import 'package:flutter/material.dart';

class Pilar2MakanSehatPage extends StatelessWidget {
  const Pilar2MakanSehatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilar 2: Makan Sehat',
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
            title: '3J: Jadwal Makan',
            icon: Icons.schedule_rounded,
            color: const Color(0xFF10B981),
            content: _buildJadwalMakan(),
          ),
          _buildMateriCard(
            number: '2',
            title: 'Jumlah Makan',
            icon: Icons.calculate_rounded,
            color: const Color(0xFF3B82F6),
            content: _buildJumlahMakan(),
          ),
          _buildMateriCard(
            number: '3',
            title: 'Jenis Makanan',
            icon: Icons.restaurant_menu_rounded,
            color: const Color(0xFFF59E0B),
            content: _buildJenisMakanan(),
          ),
          _buildMateriCard(
            number: '4',
            title: 'Tips Makan Sehat',
            icon: Icons.tips_and_updates_rounded,
            color: const Color(0xFFEC4899),
            content: _buildTipsMakan(),
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

  Widget _buildJadwalMakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          'Jam makan yang teratur membantu kadar gula darah tetap stabil, mencegah hipoglikemia maupun hiperglikemia.',
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 16),
        // Image Card
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/edukasi/pilar2/1jadwalmakan.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jadwal Makan yang Disarankan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildJadwalItem('Sarapan', '06.00 - 08.00', Icons.wb_sunny_rounded),
        _buildJadwalItem('Snack Pagi', '09.30 - 10.00', Icons.coffee_rounded),
        _buildJadwalItem('Makan Siang', '12.00 - 13.00', Icons.lunch_dining_rounded),
        _buildJadwalItem('Snack Sore', '15.30 - 16.00', Icons.set_meal_rounded),
        _buildJadwalItem('Makan Malam', '18.30 - 19.30', Icons.dinner_dining_rounded),
      ],
    );
  }

  Widget _buildJadwalItem(String waktu, String jam, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF10B981),
              size: 20,
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jam,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumlahMakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          'Jumlah makanan disesuaikan dengan berat badan ideal, kebutuhan energi harian, dan tujuan pengelolaan.',
          const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 16),
        // Image Cards
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/edukasi/pilar2/penatalaksanaanpolamakan.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/edukasi/pilar2/penatalaksanapolamakan2.png',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        _buildKisahCard(),
        const SizedBox(height: 16),
        _buildPembagianKaloriCard(),
      ],
    );
  }

  Widget _buildKisahCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Contoh: Pak Yaya',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Usia: 50 tahun\n• TB: 170 cm, BB: 85 kg\n• Aktivitas: Ringan (pegawai kantor)',
                  style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Hasil Perhitungan:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• BBI: 63 kg\n• Status: Gemuk\n• Kebutuhan: ±2.174 kkal/hari',
                  style: TextStyle(fontSize: 12, height: 1.6, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPembagianKaloriCard() {
    final List<Map<String, dynamic>> pembagian = [
      {'waktu': 'Sarapan', 'persen': '30%', 'kalori': '≈ 650 kkal', 'icon': Icons.wb_sunny_rounded},
      {'waktu': 'Snack Pagi', 'persen': '10%', 'kalori': '≈ 220 kkal', 'icon': Icons.coffee_rounded},
      {'waktu': 'Makan Siang', 'persen': '35%', 'kalori': '≈ 760 kkal', 'icon': Icons.lunch_dining_rounded},
      {'waktu': 'Snack Sore', 'persen': '10%', 'kalori': '≈ 220 kkal', 'icon': Icons.set_meal_rounded},
      {'waktu': 'Makan Malam', 'persen': '15%', 'kalori': '≈ 325 kkal', 'icon': Icons.dinner_dining_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pembagian Kalori Harian (2.174 kkal)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...pembagian.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  item['icon'],
                  color: const Color(0xFF3B82F6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['waktu'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                item['persen'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item['kalori'],
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildJenisMakanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pilihan Makan Image
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar2/pilihanmakan.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        _buildSubMateri('Makanan Pokok', Icons.rice_bowl_rounded, const Color(0xFFF59E0B), _buildMakananPokok()),
        _buildSubMateri('Buah-buahan', Icons.apple_rounded, const Color(0xFFEC4899), _buildBuah()),
        _buildSubMateri('Sayuran', Icons.eco_rounded, const Color(0xFF10B981), _buildSayuran()),
        _buildSubMateri('Protein', Icons.egg_rounded, const Color(0xFF8B5CF6), _buildProtein()),
        _buildSubMateri('Minuman', Icons.local_drink_rounded, const Color(0xFF06B6D4), _buildMinuman()),
      ],
    );
  }

  Widget _buildSubMateri(String title, IconData icon, Color color, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildMakananPokok() {
    return _buildKategoriTable([
      {'kategori': 'Disarankan', 'contoh': 'Singkong rebus, nasi merah', 'color': const Color(0xFF10B981)},
      {'kategori': 'Dibatasi', 'contoh': 'Roti gandum, kentang rebus, jagung rebus', 'color': const Color(0xFFF59E0B)},
      {'kategori': 'Dihindari', 'contoh': 'Roti tawar, kentang goreng, nasi putih, mie instan', 'color': const Color(0xFFEF4444)},
    ]);
  }

  Widget _buildBuah() {
    return _buildKategoriTable([
      {'kategori': 'Disarankan', 'contoh': 'Apel, Pir, Jeruk, Jambu biji, Stroberi, Alpukat', 'color': const Color(0xFF10B981)},
      {'kategori': 'Dibatasi', 'contoh': 'Mangga, Pisang kuning, Kiwi, Pepaya, Nangka', 'color': const Color(0xFFF59E0B)},
      {'kategori': 'Dihindari', 'contoh': 'Semangka, Nanas, Melon, Kurma kering, Leci', 'color': const Color(0xFFEF4444)},
    ]);
  }

  Widget _buildSayuran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSayurGroup('Kelompok A - Boleh Bebas', 
          'Brokoli, Kembang kol, Bayam, Kangkung, Mentimun, Terong, Pare, Jamur',
          const Color(0xFF10B981)),
        const SizedBox(height: 8),
        _buildSayurGroup('Kelompok B - Batasi Jumlah', 
          'Wortel, Bengkuang, Labu kuning, Tomat, Bawang bombay',
          const Color(0xFFF59E0B)),
        const SizedBox(height: 8),
        _buildSayurGroup('Kelompok C - Perlu Pembatasan', 
          'Kacang panjang, Buncis, Kapri',
          const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildSayurGroup(String title, String items, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          const SizedBox(height: 6),
          Text(
            items,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtein() {
    return _buildKategoriTable([
      {'kategori': 'Pilih', 'contoh': 'Ikan (nila, tuna, sarden), Ayam tanpa kulit, Tahu, Tempe, Kacang-kacangan', 'color': const Color(0xFF10B981)},
      {'kategori': 'Dibatasi', 'contoh': 'Daging sapi/kambing berlemak, Telur utuh (maks 3/minggu)', 'color': const Color(0xFFF59E0B)},
      {'kategori': 'Hindari', 'contoh': 'Daging olahan (sosis, nugget), Ayam goreng, Keju penuh lemak', 'color': const Color(0xFFEF4444)},
    ]);
  }

  Widget _buildMinuman() {
    return _buildKategoriTable([
      {'kategori': 'Pilih', 'contoh': 'Air putih, Teh tawar, Kopi tanpa gula, Susu rendah lemak', 'color': const Color(0xFF10B981)},
      {'kategori': 'Batasi', 'contoh': 'Jus buah segar tanpa gula, Air kelapa (1 gelas kecil), Pemanis buatan', 'color': const Color(0xFFF59E0B)},
      {'kategori': 'Hindari', 'contoh': 'Soda, Jus kemasan, Minuman boba, Teh/kopi manis', 'color': const Color(0xFFEF4444)},
    ]);
  }

  Widget _buildKategoriTable(List<Map<String, dynamic>> data) {
    return Column(
      children: data.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: item['color'].withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: item['color'].withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    item['kategori'] == 'Disarankan' || item['kategori'] == 'Pilih'
                        ? Icons.check_circle_rounded
                        : item['kategori'] == 'Dibatasi' || item['kategori'] == 'Batasi'
                            ? Icons.warning_rounded
                            : Icons.cancel_rounded,
                    color: item['color'],
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['kategori'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: item['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item['contoh'],
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTipsMakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tip 1: Cara Memasak - with images
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.kitchen_rounded,
                      color: Color(0xFFEC4899),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '1. Cara Memasak',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Pilih cara masak sehat: kukus, rebus, tumis sedikit minyak, atau panggang. Hindari menggoreng.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 12),
              // Images Grid
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/edukasi/pilar2/41caramemasak1.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/edukasi/pilar2/41caramemasak2.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/edukasi/pilar2/41caramemasak3.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Tip 2: Urutan Makan - with image
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.format_list_numbered_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '2. Urutan Makan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Makan sayur dulu → protein → karbohidrat terakhir. Menurunkan lonjakan gula darah.',
                style: TextStyle(fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/edukasi/pilar2/42urutanmakan1.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
        _buildTipCard(
          '3. Kunyah dengan Baik',
          'Kunyah minimal 30-40 kali per suapan. Membantu pencernaan dan kontrol gula darah.',
          Icons.restaurant_rounded,
          const Color(0xFF06B6D4),
        ),
        _buildTipCard(
          '4. Piring Seimbang',
          '½ sayuran + ¼ karbohidrat + ¼ protein. Tambah buah dan air putih secukupnya.',
          Icons.pie_chart_rounded,
          const Color(0xFF10B981),
        ),
        _buildTipCard(
          '5. Saat Bepergian',
          'Bawa camilan sehat, pilih makanan bijak, jaga hidrasi, dan tetap cek gula darah.',
          Icons.luggage_rounded,
          const Color(0xFFF59E0B),
        ),
        _buildTipCard(
          '6. Bulan Ramadhan',
          'Sahur dekat imsak, berbuka hindari gula tinggi. Pantau gula darah: <70 mg/dL batalkan puasa.',
          Icons.mosque_rounded,
          const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String desc, IconData icon, Color color) {
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

  Widget _buildInfoBox(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}