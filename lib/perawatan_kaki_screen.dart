import 'package:flutter/material.dart';

class PerawatanKakiScreen extends StatefulWidget {
  const PerawatanKakiScreen({super.key});

  @override
  State<PerawatanKakiScreen> createState() => _PerawatanKakiScreenState();
}

class _PerawatanKakiScreenState extends State<PerawatanKakiScreen> {
  String? kondisiKaki;
  String? pemberianLotion;
  String? senamKaki;
  String? terasaKebas;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Silahkan lengkapi form dibawah ini untuk melakukan pencatatan perawatan kaki',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Kondisi Kaki
            const Text(
              'Bagaimana Kondisi Kaki Anda Saat Ini :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('kondisiKaki', 'Tidak Ada Luka', kondisiKaki),
            _buildRadioOption('kondisiKaki', 'Ada Luka Kecil', kondisiKaki),
            _buildRadioOption('kondisiKaki', 'Kering', kondisiKaki),
            _buildRadioOption('kondisiKaki', 'Ada Luka Berat', kondisiKaki),
            const SizedBox(height: 16),

            // Pemberian Lotion
            const Text(
              'Apakah Anda Melakukan Pemberian Lotion :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('pemberianLotion', 'Ya', pemberianLotion),
            _buildRadioOption('pemberianLotion', 'Tidak', pemberianLotion),
            const SizedBox(height: 16),

            // Senam Kaki
            const Text(
              'Apakah Anda Melakukan Senam Kaki :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('senamKaki', 'Ya', senamKaki),
            _buildRadioOption('senamKaki', 'Tidak', senamKaki),
            const SizedBox(height: 16),

            // Terasa Kebas
            const Text(
              'Apakah Terasa Kebas Pada Kaki :',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildRadioOption('terasaKebas', 'Ya', terasaKebas),
            _buildRadioOption('terasaKebas', 'Tidak', terasaKebas),
            const SizedBox(height: 32),

            // Tombol Simpan
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data perawatan kaki berhasil disimpan')),
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

  Widget _buildRadioOption(String group, String value, String? groupValue) {
    return GestureDetector(
      onTap: () {
        setState(() {
          switch (group) {
            case 'kondisiKaki':
              kondisiKaki = value;
              break;
            case 'pemberianLotion':
              pemberianLotion = value;
              break;
            case 'senamKaki':
              senamKaki = value;
              break;
            case 'terasaKebas':
              terasaKebas = value;
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}