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
        InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 5.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/edukasi/pilar2/1jadwalmakan.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
        _buildImg('assets/materibaru/jumlahmakan/1.png'),
        _buildImg('assets/materibaru/jumlahmakan/2.png'),
        _buildImg('assets/materibaru/jumlahmakan/4.jpeg'),
        _buildKisahCard(),
      ],
    );
  }

  Widget _buildKisahCard() {
    return _buildImg('assets/materibaru/jumlahmakan/pakyaya.png');
  }

  Widget _buildJenisMakanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pilihan Makan Image
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.8,
            maxScale: 5.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/edukasi/pilar2/pilihanmakan.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
    return Column(
      children: [
        _buildImg('assets/materibaru/jenismakanan/makananpokok.png'),
        _buildImg('assets/materibaru/jenismakanan/makananpokok2.png'),
      ],
    );
  }

  Widget _buildBuah() {
    return _buildImg('assets/materibaru/jenismakanan/buahaman.png');
  }

  Widget _buildSayuran() {
    return Column(
      children: [
        _buildImg('assets/materibaru/jenismakanan/sayuran/1.png'),
        _buildImg('assets/materibaru/jenismakanan/sayuran/2.png'),
        _buildImg('assets/materibaru/jenismakanan/sayuran/3.png'),
      ],
    );
  }

  Widget _buildProtein() {
    return Column(
      children: [
        _buildImg('assets/materibaru/jenismakanan/protein/1.png'),
        _buildImg('assets/materibaru/jenismakanan/protein/2.png'),
      ],
    );
  }

  Widget _buildMinuman() {
    return Column(
      children: [
        _buildImg('assets/materibaru/jenismakanan/minuman/1.png'),
        _buildImg('assets/materibaru/jenismakanan/minuman/2.png'),
      ],
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
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/edukasi/pilar2/41caramemasak1.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/edukasi/pilar2/41caramemasak2.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.8,
                    maxScale: 5.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/edukasi/pilar2/41caramemasak3.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 5.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/edukasi/pilar2/42urutanmakan1.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
        _buildTipImageSection(
          '4. Agar Porsi Makan Seimbang',
          Icons.pie_chart_rounded,
          const Color(0xFF10B981),
          ['assets/materibaru/tipspilar2/agarporsimakanseimbang.png'],
        ),
        _buildTipImageSection(
          '5. Pengelolaan Makan Saat Bepergian',
          Icons.luggage_rounded,
          const Color(0xFFF59E0B),
          [
            'assets/materibaru/tipspilar2/tipsberpergian1.png',
            'assets/materibaru/tipspilar2/tipsberpergian2.png',
          ],
        ),
        _buildTipImageSection(
          '6. Pengelolaan Diet Bulan Ramadhan',
          Icons.mosque_rounded,
          const Color(0xFF6366F1),
          [
            'assets/materibaru/tipspilar2/tipspuasa1.png',
            'assets/materibaru/tipspilar2/tipspuasa2.png',
          ],
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

  Widget _buildImg(String path) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.8,
        maxScale: 5.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            path,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTipImageSection(String title, IconData icon, Color color, List<String> imagePaths) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...imagePaths.map((path) => _buildImg(path)),
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