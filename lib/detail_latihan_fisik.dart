import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/latihan_fisik_service.dart';

class DetailLatihanFisikScreen extends StatefulWidget {
  const DetailLatihanFisikScreen({super.key});

  @override
  State<DetailLatihanFisikScreen> createState() =>
      _DetailLatihanFisikScreenState();
}

class _DetailLatihanFisikScreenState extends State<DetailLatihanFisikScreen> {
  final LatihanFisikService _latihanFisikService = LatihanFisikService();
  DateTime selectedDate = DateTime.now();
  String? noKode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNoKode();
  }

  Future<void> _loadNoKode() async {
    final userNoKode = await _latihanFisikService.getCurrentUserNoKode();
    setState(() {
      noKode = userNoKode;
      isLoading = false;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _deleteLog(String logId) async {
    final canDelete = await _latihanFisikService.canDeleteLog(logId);

    if (!canDelete) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda hanya bisa menghapus data yang Anda input'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _latihanFisikService.deleteLatihanFisikLog(logId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDetailDialog(Map<String, dynamic> data) {
    final kategori = data['kategoriIntensitas'] as String;
    final manfaat = List<String>.from(data['manfaat'] ?? []);
    final rekomendasi = List<String>.from(data['rekomendasi'] ?? []);
    final kalori = data['kaloriTerbakar'] as int;
    final durasi = data['durasi'] as int;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB83B7E),
                      const Color(0xFF8B2D5C),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fitness_center, 
                      color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detail Latihan Fisik',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Singkat
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8D5DF)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.orange, size: 32),
                                const SizedBox(height: 4),
                                Text(
                                  '$kalori kal',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Terbakar',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Icon(Icons.timer,
                                    color: _getKategoriColor(kategori),
                                    size: 32),
                                const SizedBox(height: 4),
                                Text(
                                  '$durasi',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Menit',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kategori
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getKategoriColor(kategori).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getKategoriColor(kategori).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getKategoriColor(kategori),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                kategori,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getKategoriColor(kategori),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Manfaat
                      const Text(
                        'Manfaat:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D2E46),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: manfaat
                              .map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rekomendasi
                      const Text(
                        'Rekomendasi:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D2E46),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...rekomendasi.asMap().entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFB83B7E),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getKategoriColor(String kategori) {
    if (kategori.contains('TINGGI')) {
      return Colors.green;
    } else if (kategori.contains('SEDANG')) {
      return Colors.blue;
    } else if (kategori.contains('RINGAN')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Aktivitas Latihan Fisik',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );
    }

    if (noKode == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Aktivitas Latihan Fisik',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(
          child: Text('Data user tidak ditemukan'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Aktivitas Latihan Fisik',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFFB83B7E)),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB83B7E).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFFB83B7E),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _latihanFisikService.getLatihanFisikByDate(
                  noKode!, selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data latihan fisik\npada tanggal ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final logs = snapshot.data!.docs;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        'Berikut ini adalah list latihan fisik pada tanggal ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Row(
                        children: [
                          const Icon(Icons.fitness_center,
                              color: Color(0xFFB83B7E)),
                          const SizedBox(width: 8),
                          Text(
                            'Latihan Fisik (${logs.length} item)',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.black87,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List
                      ...logs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildLatihanItem(
                            context,
                            doc.id,
                            data['jam'] ?? '',
                            data['jenisOlahraga'] ?? '',
                            data['durasi'] as int? ?? 0,
                            data['kaloriTerbakar'] as int? ?? 0,
                            data['kategoriIntensitas'] ?? '',
                            data['userName'] ?? '',
                            data,
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatihanItem(
    BuildContext context,
    String logId,
    String time,
    String jenisOlahraga,
    int durasi,
    int kalori,
    String kategori,
    String userName,
    Map<String, dynamic> fullData,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB83B7E).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getKategoriColor(kategori),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kategori.split(' - ')[0],
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$time WIB',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jenisOlahraga,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer, 
                          size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          '$durasi menit',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.local_fire_department,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '$kalori kal',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info_outline,
                        color: Color(0xFFB83B7E), size: 22),
                    onPressed: () => _showDetailDialog(fullData),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, 
                      color: Colors.red, size: 20),
                    onPressed: () => _deleteLog(logId),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Oleh: $userName',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getKategoriColor(kategori).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  kategori,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getKategoriColor(kategori),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}