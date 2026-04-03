import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InputAktivitasTidurScreen extends StatefulWidget {
  const InputAktivitasTidurScreen({super.key});

  @override
  State<InputAktivitasTidurScreen> createState() =>
      _InputAktivitasTidurScreenState();
}

class _InputAktivitasTidurScreenState
    extends State<InputAktivitasTidurScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay? jamTidur;
  TimeOfDay? jamBangun;
  String? kualitas;
  final _catatanController = TextEditingController();

  static const List<String> _kualitasOptions = ['Baik', 'Cukup', 'Kurang'];

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  int? get _durasiMenit {
    if (jamTidur == null || jamBangun == null) return null;
    final tidurMinutes = jamTidur!.hour * 60 + jamTidur!.minute;
    int bangunMinutes = jamBangun!.hour * 60 + jamBangun!.minute;
    // Jika bangun < tidur, berarti melewati tengah malam
    if (bangunMinutes <= tidurMinutes) bangunMinutes += 24 * 60;
    return bangunMinutes - tidurMinutes;
  }

  String get _durasiText {
    final menit = _durasiMenit;
    if (menit == null) return '-';
    final jam = menit ~/ 60;
    final sisa = menit % 60;
    if (sisa == 0) return '$jam jam';
    return '$jam jam $sisa menit';
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickJamTidur() async {
    final time = await showTimePicker(
      context: context,
      initialTime: jamTidur ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => jamTidur = time);
  }

  Future<void> _pickJamBangun() async {
    final time = await showTimePicker(
      context: context,
      initialTime: jamBangun ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => jamBangun = time);
  }

  Future<void> _simpan() async {
    if (jamTidur == null) {
      _showError('Mohon isi jam tidur');
      return;
    }
    if (jamBangun == null) {
      _showError('Mohon isi jam bangun');
      return;
    }
    if (kualitas == null) {
      _showError('Mohon pilih kualitas tidur');
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

      await _firestore.collection('aktivitas_tidur_logs').add({
        'userId': currentUser.uid,
        'noKode': noKode,
        'userName': namaLengkap,
        'userRole': role,
        'tanggal': Timestamp.fromDate(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        ),
        'jamTidur': _formatTime(jamTidur!),
        'jamBangun': _formatTime(jamBangun!),
        'durasiMenit': _durasiMenit,
        'kualitas': kualitas,
        'catatan': _catatanController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data aktivitas tidur berhasil disimpan'),
            backgroundColor: Colors.green,
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required IconData icon,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE4EC),
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: const Color(0xFFB83B7E).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB83B7E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null ? _formatTime(value) : label,
                style: TextStyle(
                  fontSize: 15,
                  color: value != null
                      ? Colors.black87
                      : const Color(0xFFB83B7E),
                  fontWeight:
                      value != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            const Icon(Icons.access_time,
                size: 16, color: Color(0xFFB83B7E)),
          ],
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
          'Catat Aktivitas Tidur',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                // Tanggal
                const Text(
                  'Tanggal :',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
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
                        const Icon(Icons.calendar_today,
                            color: Color(0xFFB83B7E), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy', 'id')
                              .format(selectedDate),
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Color(0xFFB83B7E)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Jam Tidur & Jam Bangun
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jam Tidur :',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          _buildTimePicker(
                            label: '--:--',
                            icon: Icons.bedtime_outlined,
                            value: jamTidur,
                            onTap: _pickJamTidur,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jam Bangun :',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          _buildTimePicker(
                            label: '--:--',
                            icon: Icons.wb_sunny_outlined,
                            value: jamBangun,
                            onTap: _pickJamBangun,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Durasi otomatis
                if (_durasiMenit != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timelapse, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Durasi tidur: $_durasiText',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Kualitas Tidur
                const Text(
                  'Kualitas Tidur :',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _kualitasOptions.map((k) {
                    final isSelected = kualitas == k;
                    final color = k == 'Baik'
                        ? Colors.green
                        : k == 'Cukup'
                            ? Colors.orange
                            : Colors.red;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => kualitas = k),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.15)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  k == 'Baik'
                                      ? Icons.sentiment_very_satisfied
                                      : k == 'Cukup'
                                          ? Icons.sentiment_neutral
                                          : Icons.sentiment_dissatisfied,
                                  color: isSelected
                                      ? color
                                      : Colors.grey.shade400,
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  k,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? color
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Catatan
                const Text(
                  'Catatan (opsional) :',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _catatanController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: tidur nyenyak, sering terbangun, dll.',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFFCE4EC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFFB83B7E), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Tombol Simpan
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _simpan,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Simpan Data Tidur',
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
}
