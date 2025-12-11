import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TerapiObatScreen extends StatefulWidget {
  const TerapiObatScreen({super.key});

  @override
  State<TerapiObatScreen> createState() => _TerapiObatScreenState();
}

class _TerapiObatScreenState extends State<TerapiObatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String? selectedJenisObat;
  String? selectedSatuan;
  String? selectedWaktu;
  DateTime? selectedDate;
  TimeOfDay? selectedJam;
  final TextEditingController _dosisController = TextEditingController();

  // Daftar jenis obat diabetes
  final List<String> jenisObatList = [
    'Insulin',
    'Metformin',
    'Glibenclamide',
    'Gliclazide',
    'Acarbose',
    'Pioglitazone',
  ];

  String get waktuMakanText {
    if (selectedWaktu != null &&
        selectedDate != null &&
        selectedJam != null) {
      final tanggal = DateFormat('dd MMM yyyy').format(selectedDate!);
      final jam =
          '${selectedJam!.hour.toString().padLeft(2, '0')}.${selectedJam!.minute.toString().padLeft(2, '0')}';
      return '$selectedWaktu, $tanggal Jam $jam';
    }
    return '';
  }

  void _showPilihObatSheet() {
    String? tempJenis = selectedJenisObat;
    String? tempSatuan = selectedSatuan;
    String? tempWaktu = selectedWaktu;
    DateTime? tempDate = selectedDate;
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih Jenis Obat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: jenisObatList.map((obat) {
                      return _buildChip(obat, tempJenis == obat, () {
                        setModalState(() => tempJenis = obat);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Satuan',
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
                      _buildChip('Tablet', tempSatuan == 'Tablet', () {
                        setModalState(() => tempSatuan = 'Tablet');
                      }),
                      const SizedBox(width: 12),
                      _buildChip('Unit', tempSatuan == 'Unit', () {
                        setModalState(() => tempSatuan = 'Unit');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Waktu Minum Obat',
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
                      _buildChip(
                        tempDate != null
                            ? DateFormat('dd MMM').format(tempDate!)
                            : 'Pilih Tanggal',
                        false,
                        () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: tempDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setModalState(() => tempDate = date);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildChip(
                        tempJam != null
                            ? 'Jam ${tempJam!.hour.toString().padLeft(2, '0')}.${tempJam!.minute.toString().padLeft(2, '0')}'
                            : 'Jam --.--',
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
                        selectedJenisObat = tempJenis;
                        selectedSatuan = tempSatuan;
                        selectedWaktu = tempWaktu;
                        selectedDate = tempDate;
                        selectedJam = tempJam;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 12),
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
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveMedicationLog() async {
    // Validasi
    if (selectedJenisObat == null ||
        selectedSatuan == null ||
        selectedWaktu == null ||
        selectedDate == null ||
        selectedJam == null) {
      _showError('Mohon lengkapi jenis obat dan waktu');
      return;
    }

    final dosis = double.tryParse(_dosisController.text);
    if (dosis == null || dosis <= 0) {
      _showError('Mohon masukkan dosis yang valid');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _showError('User tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Ambil noKode user dari Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        _showError('Data user tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      final userData = userDoc.data()!;
      final noKode = userData['noKode'] as String;
      final namaLengkap = userData['namaLengkap'] as String;
      final role = userData['role'] as String;

      // Gabungkan tanggal dan jam
      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedJam!.hour,
        selectedJam!.minute,
      );

      // Simpan ke Firestore (top-level collection)
      await _firestore.collection('medication_logs').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': namaLengkap,
        'userRole': role,
        'jenisObat': selectedJenisObat,
        'dosis': dosis,
        'satuan': selectedSatuan,
        'waktu': selectedWaktu,
        'tanggal': Timestamp.fromDate(dateTime),
        'jam':
            '${selectedJam!.hour.toString().padLeft(2, '0')}:${selectedJam!.minute.toString().padLeft(2, '0')}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Berhasil! $selectedJenisObat ${dosis.toStringAsFixed(0)} $selectedSatuan tersimpan',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
          border:
              isSelected ? Border.all(color: Colors.white, width: 2) : null,
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
          'Terapi Obat',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pilih jenis obat, waktu, dan masukkan dosis obat yang akan diminum',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Waktu Minum Obat
                const Text(
                  'Waktu Minum Obat :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _showPilihObatSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFFB83B7E).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medication,
                            color: Color(0xFFB83B7E), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            waktuMakanText.isEmpty
                                ? 'Pilih Jenis Obat & Waktu'
                                : waktuMakanText,
                            style: TextStyle(
                              color: waktuMakanText.isEmpty
                                  ? const Color(0xFFB83B7E)
                                  : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Color(0xFFB83B7E)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (selectedJenisObat != null) ...[
                  // Display Selected
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dipilih: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Text(
                          '$selectedJenisObat ($selectedSatuan)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Dosis Obat
                const Text(
                  'Dosis Obat :',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dosisController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
                  ],
                  decoration: InputDecoration(
                    hintText: 'Contoh: 2 atau 2.5',
                    prefixIcon: const Icon(Icons.medical_services,
                        color: Color(0xFFB83B7E)),
                    suffixText: selectedSatuan ?? 'Tablet/Unit',
                    filled: true,
                    fillColor: const Color(0xFFFCE4EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color: const Color(0xFFB83B7E).withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: Color(0xFFB83B7E), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Simpan
                Center(
                  child: ElevatedButton.icon(
                    onPressed:
                        selectedJenisObat != null && !_isLoading
                            ? _saveMedicationLog
                            : null,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan Data Obat',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _dosisController.dispose();
    super.dispose();
  }
}