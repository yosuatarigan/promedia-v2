import 'package:flutter/material.dart';

class PengelolaanMakananScreen extends StatefulWidget {
  const PengelolaanMakananScreen({super.key});

  @override
  State<PengelolaanMakananScreen> createState() => _PengelolaanMakananScreenState();
}

class _PengelolaanMakananScreenState extends State<PengelolaanMakananScreen> {
  // Kategori Makan
  String? selectedKategori;
  String? selectedWaktu;
  TimeOfDay? selectedJam;

  // Jenis Makanan
  String? selectedJenisMakanan;
  String? selectedPorsi;
  String? selectedKalori;

  String get kategoriMakanText {
    if (selectedWaktu != null && selectedJam != null && selectedKategori != null) {
      final jam = '${selectedJam!.hour.toString().padLeft(2, '0')}.${selectedJam!.minute.toString().padLeft(2, '0')}';
      return '$selectedWaktu $jam  $selectedKategori';
    }
    return '';
  }

  String get jenisMakananText => selectedJenisMakanan ?? '';

  String get porsiText {
    if (selectedPorsi != null && selectedKalori != null) {
      return '$selectedPorsi   $selectedKalori';
    }
    return '';
  }

  void _showKategoriMakanSheet() {
    String? tempKategori = selectedKategori;
    String? tempWaktu = selectedWaktu;
    TimeOfDay? tempJam = selectedJam;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF5D2E46),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kategori Makan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Snack', tempKategori == 'Snack', () {
                      setModalState(() => tempKategori = 'Snack');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Makan Utama', tempKategori == 'Makan Utama', () {
                      setModalState(() => tempKategori = 'Makan Utama');
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Waktu Makan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Hari ------', false, () {}),
                    const SizedBox(width: 12),
                    _buildChip(
                      tempJam != null
                          ? 'Jam ${tempJam!.hour.toString().padLeft(2, '0')}.${tempJam!.minute.toString().padLeft(2, '0')} WIB'
                          : 'Jam --.-- WIB',
                      false,
                      () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: tempJam ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setModalState(() => tempJam = time);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Pagi', tempWaktu == 'Pagi', () {
                      setModalState(() => tempWaktu = 'Pagi');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Siang', tempWaktu == 'Siang', () {
                      setModalState(() => tempWaktu = 'Siang');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Malam', tempWaktu == 'Malam', () {
                      setModalState(() => tempWaktu = 'Malam');
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedKategori = tempKategori;
                      selectedWaktu = tempWaktu;
                      selectedJam = tempJam;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showJenisMakananSheet() {
    String? tempJenis = selectedJenisMakanan;
    String? tempPorsi = selectedPorsi;
    String? tempKalori = selectedKalori;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF5D2E46),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Jenis Makanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChip('Nasi Kuning dan lain-lain', tempJenis == 'Nasi Kuning', () {
                  setModalState(() => tempJenis = 'Nasi Kuning');
                }),
                const SizedBox(height: 24),
                const Text(
                  'Porsi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChip('1 Porsi', tempPorsi == '1 Porsi', () {
                  setModalState(() => tempPorsi = '1 Porsi');
                }),
                const SizedBox(height: 24),
                const Text(
                  'Kalori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChip('240 kal', tempKalori == '240 kal', () {
                  setModalState(() => tempKalori = '240 kal');
                }),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedJenisMakanan = tempJenis;
                      selectedPorsi = tempPorsi;
                      selectedKalori = tempKalori;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFB83B7E),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
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
          'Pengelolaan Makanan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silahkan pilih kategori makan, kemudian isi nama makanan yang Anda makan beserta porsinya',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Kategori Makan
            const Text(
              'Kategori Makan :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showKategoriMakanSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  kategoriMakanText.isEmpty ? 'Pilih Kategori Makan' : kategoriMakanText,
                  style: TextStyle(
                    color: kategoriMakanText.isEmpty ? const Color(0xFFB83B7E) : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Makanan 1 label
            Row(
              children: [
                const Text(
                  'Makanan 1',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: CustomPaint(
                      painter: DashedLinePainter(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Jenis Makanan
            const Text(
              'Jenis Makanan :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showJenisMakananSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  jenisMakananText.isEmpty ? 'Pilih Jenis Makanan' : jenisMakananText,
                  style: TextStyle(
                    color: jenisMakananText.isEmpty ? const Color(0xFFB83B7E) : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Porsi
            const Text(
              'Porsi :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB83B7E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Piring',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      porsiText.isEmpty ? 'Masukan Porsi Makanan (Cth. 1/4)' : porsiText,
                      style: TextStyle(
                        color: porsiText.isEmpty ? Colors.grey : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Simpan data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data makanan berhasil disimpan')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB83B7E),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}