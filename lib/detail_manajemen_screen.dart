import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/stress_managemen_service.dart';

class DetailManajemenStressScreen extends StatefulWidget {
  const DetailManajemenStressScreen({super.key});

  @override
  State<DetailManajemenStressScreen> createState() =>
      _DetailManajemenStressScreenState();
}

class _DetailManajemenStressScreenState
    extends State<DetailManajemenStressScreen> {
  final StressManagementService _stressService = StressManagementService();
  DateTime selectedDate = DateTime.now();
  String? noKode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNoKode();
  }

  Future<void> _loadNoKode() async {
    final userNoKode = await _stressService.getCurrentUserNoKode();
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
    final canDelete = await _stressService.canDeleteLog(logId);

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
        await _stressService.deleteStressLog(logId);
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
    final skorStress = data['skorStress'] as int;
    final statusStress = data['statusStress'] as String;
    final analisaTekananDarah = data['analisaTekananDarah'] as String;
    final analisisPerasaan = data['analisisPerasaan'] as String;
    final rekomendasi = List<String>.from(data['rekomendasi'] ?? []);

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
                    const Icon(Icons.psychology,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Detail Manajemen Stress',
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
                      // Status Stress
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getStatusColor(skorStress).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  _getStatusColor(skorStress).withOpacity(0.3),
                              width: 2),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(skorStress),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    skorStress >= 15
                                        ? Icons.warning
                                        : skorStress >= 10
                                            ? Icons.error_outline
                                            : skorStress >= 6
                                                ? Icons.info
                                                : skorStress >= 3
                                                    ? Icons.check_circle
                                                    : Icons.thumb_up,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        statusStress,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(skorStress),
                                        ),
                                      ),
                                      Text(
                                        'Skor: $skorStress',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Analisis Detail
                      const Text(
                        'Analisis Detail:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D2E46),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tekanan Darah
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.favorite,
                                    size: 16, color: Color(0xFFE65100)),
                                SizedBox(width: 6),
                                Text(
                                  'Tekanan Darah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              analisaTekananDarah,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kondisi Emosional
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.sentiment_satisfied,
                                    size: 16, color: Color(0xFF2E7D32)),
                                SizedBox(width: 6),
                                Text(
                                  'Kondisi Emosional',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              analisisPerasaan,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ],
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
                        bool isPrioritas = entry.value.contains("SEGERA") ||
                            entry.value.contains("PENTING");

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isPrioritas
                                ? const Color(0xFFFFEBEE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isPrioritas
                                  ? Colors.red.shade200
                                  : const Color(0xFFE0E0E0),
                              width: isPrioritas ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: isPrioritas
                                      ? Colors.red
                                      : const Color(0xFFB83B7E),
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    height: 1.4,
                                    fontWeight: isPrioritas
                                        ? FontWeight.w600
                                        : FontWeight.normal,
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

  Color _getStatusColor(int skorStress) {
    if (skorStress >= 15) {
      return Colors.red;
    } else if (skorStress >= 10) {
      return Colors.deepOrange;
    } else if (skorStress >= 6) {
      return Colors.orange;
    } else if (skorStress >= 3) {
      return Colors.blue;
    } else {
      return Colors.green;
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
            'Aktivitas Manajemen Stress',
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
            'Aktivitas Manajemen Stress',
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
          'Aktivitas Manajemen Stress',
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
              stream: _stressService.getStressLogsByDate(
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
                          Icons.psychology,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data manajemen stress\npada tanggal ini',
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
                      // Description Text
                      Text(
                        'Berikut ini adalah list manajemen stress pada tanggal ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
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
                          const Icon(Icons.psychology,
                              color: Color(0xFFB83B7E)),
                          const SizedBox(width: 8),
                          Text(
                            'Manajemen Stress (${logs.length} item)',
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

                      // List Manajemen Stress
                      ...logs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildStressItem(
                            context,
                            doc.id,
                            data['jam'] ?? '',
                            data['tekananDarah'] ?? '',
                            data['statusStress'] ?? '',
                            data['userName'] ?? '',
                            data['skorStress'] as int? ?? 0,
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

  Widget _buildStressItem(
    BuildContext context,
    String logId,
    String time,
    String tekananDarah,
    String statusStress,
    String userName,
    int skorStress,
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
                            color: _getStatusColor(skorStress),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusStress.split(' - ')[0],
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
                      'TD $tekananDarah mmHg',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusStress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
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
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(skorStress).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Skor: $skorStress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(skorStress),
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