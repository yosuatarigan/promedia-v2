import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KebutuhanKaloriScreen extends StatefulWidget {
  const KebutuhanKaloriScreen({super.key});

  @override
  State<KebutuhanKaloriScreen> createState() => _KebutuhanKaloriScreenState();
}

class _KebutuhanKaloriScreenState extends State<KebutuhanKaloriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usiaController = TextEditingController();
  final _tbController = TextEditingController();
  final _bbController = TextEditingController();
  
  String _jenisKelamin = 'Laki-laki';
  String _aktivitas = 'Ringan: +20% (pegawai kantor, guru, ibu rumah tangga)';
  double? _hasilKalori;
  bool _isLoading = false;

  final List<String> _aktivitasList = [
    'Istirahat: +10%',
    'Ringan: +20% (pegawai kantor, guru, ibu rumah tangga)',
    'Sedang: +30% (industri ringan, mahasiswa)',
    'Berat: +40% (petani, buruh, atlet latihan)',
    'Sangat berat: +50% (tukang becak, tukang gali)',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.exists) {
      final data = userData.data()!;
      setState(() {
        _usiaController.text = data['usiaKalori']?.toString() ?? '';
        _tbController.text = data['tbKalori']?.toString() ?? '';
        _bbController.text = data['bbKalori']?.toString() ?? '';
        _jenisKelamin = data['jenisKelaminKalori'] ?? data['jenisKelamin'] ?? 'Laki-laki';
        _aktivitas = data['aktivitasKalori'] ?? _aktivitas;
        _hasilKalori = data['kebutuhanKalori']?.toDouble();
      });
    }
  }

  void _hitungKalori() {
    if (!_formKey.currentState!.validate()) return;

    final usia = int.parse(_usiaController.text);
    final tb = double.parse(_tbController.text);
    final bb = double.parse(_bbController.text);

    // Langkah 1: Hitung BBI
    double bbi;
    if ((_jenisKelamin == 'Laki-laki' && tb >= 160) || 
        (_jenisKelamin == 'Perempuan' && tb >= 150)) {
      bbi = 0.9 * (tb - 100);
    } else {
      bbi = tb - 100;
    }

    // Langkah 2: Tentukan status berat badan
    double bbiBawah = bbi - (bbi * 0.1);
    double bbiAtas = bbi + (bbi * 0.1);
    String statusBB = bb < bbiBawah ? 'Kurus' : (bb > bbiAtas ? 'Gemuk' : 'Normal');

    // Langkah 3: Hitung kebutuhan basal
    double faktorBasal = _jenisKelamin == 'Laki-laki' ? 30 : 25;
    double kebutuhanBasal = bbi * faktorBasal;

    // Langkah 4: Penyesuaian usia
    double faktorUsia = 1.0;
    if (usia >= 40 && usia < 60) {
      int dekadeAtas40 = ((usia - 40) / 10).floor();
      faktorUsia = 1.0 - (0.05 * dekadeAtas40);
    } else if (usia >= 60 && usia < 70) {
      faktorUsia = 0.9;
    } else if (usia >= 70) {
      faktorUsia = 0.8;
    }

    double kaloriSetelahUsia = kebutuhanBasal * faktorUsia;

    // Langkah 5: Penyesuaian aktivitas
    double faktorAktivitas = 1.1; // default istirahat
    if (_aktivitas.contains('Ringan')) {
      faktorAktivitas = 1.2;
    } else if (_aktivitas.contains('Sedang')) {
      faktorAktivitas = 1.3;
    } else if (_aktivitas.contains('Berat') && !_aktivitas.contains('Sangat')) {
      faktorAktivitas = 1.4;
    } else if (_aktivitas.contains('Sangat berat')) {
      faktorAktivitas = 1.5;
    }

    double kaloriAkhir = kaloriSetelahUsia * faktorAktivitas;

    // Langkah 6: Penyesuaian status BB untuk DM
    if (statusBB == 'Gemuk') {
      kaloriAkhir = kaloriAkhir * 0.9; // kurangi 10%
    } else if (statusBB == 'Kurus') {
      kaloriAkhir = kaloriAkhir * 1.1; // tambah 10%
    }

    // Pastikan minimal
    double minimal = _jenisKelamin == 'Laki-laki' ? 1200 : 1000;
    if (kaloriAkhir < minimal) {
      kaloriAkhir = minimal;
    }

    setState(() {
      _hasilKalori = kaloriAkhir;
    });
  }

  Future<void> _simpanData() async {
    if (_hasilKalori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan hitung kalori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'usiaKalori': int.parse(_usiaController.text),
        'tbKalori': double.parse(_tbController.text),
        'bbKalori': double.parse(_bbController.text),
        'jenisKelaminKalori': _jenisKelamin,
        'aktivitasKalori': _aktivitas,
        'kebutuhanKalori': _hasilKalori,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kebutuhan Kalori',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Silakan untuk menginput data untuk dilakukan perhitungan kebutuhan kalori Anda.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Usia
              const Text('Usia :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usiaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '50 Tahun',
                  filled: true,
                  fillColor: const Color(0xFFFFF0F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Usia harus diisi';
                  if (int.tryParse(value) == null) return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // TB dan BB
              const Text(
                'Tinggi Badan dan Berat Badan :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tbController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '165 cm',
                        filled: true,
                        fillColor: const Color(0xFFFFF0F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'TB harus diisi';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bbController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '55 Kg',
                        filled: true,
                        fillColor: const Color(0xFFFFF0F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'BB harus diisi';
                        if (double.tryParse(value) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin
              const Text(
                'Jenis Kelamin :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _jenisKelamin = 'Laki-laki'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _jenisKelamin == 'Laki-laki' 
                              ? const Color(0xFFB83B7E) 
                              : const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Laki-laki',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _jenisKelamin == 'Laki-laki' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _jenisKelamin = 'Perempuan'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _jenisKelamin == 'Perempuan' 
                              ? const Color(0xFFB83B7E) 
                              : const Color(0xFFFFF0F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Perempuan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _jenisKelamin == 'Perempuan' ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Faktor Aktivitas
              const Text(
                'Faktor Aktivitas :',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _aktivitas,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFB83B7E)),
                    items: _aktivitasList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _aktivitas = value!);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button Hitung
              Center(
                child: ElevatedButton(
                  onPressed: _hitungKalori,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Hitung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Hasil Kalori
              if (_hasilKalori != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Hasil Perhitungan Kebutuhan Kalori Anda :',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_hasilKalori!.toStringAsFixed(0)} Kalori',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB83B7E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Button Simpan
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _simpanData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB83B7E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usiaController.dispose();
    _tbController.dispose();
    _bbController.dispose();
    super.dispose();
  }
}