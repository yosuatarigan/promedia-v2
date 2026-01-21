import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PasienDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> foodLogs;
  final List<Map<String, dynamic>> medicationLogs;
  final List<Map<String, dynamic>> footCareLogs;
  final List<Map<String, dynamic>> stressLogs;
  final List<Map<String, dynamic>> latihanFisikLogs;

  const PasienDetailScreen({
    required this.userData,
    required this.foodLogs,
    required this.medicationLogs,
    required this.footCareLogs,
    required this.stressLogs,
    required this.latihanFisikLogs,
  });

  @override
  State<PasienDetailScreen> createState() => PasienDetailScreenState();
}

class PasienDetailScreenState extends State<PasienDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  int _selectedTab = 0;

  String _maskNIK(String? nik) {
    if (nik == null || nik.isEmpty) return '-';
    if (nik.length < 6) return nik;
    return '${nik.substring(0, 2)}${'*' * (nik.length - 4)}${nik.substring(nik.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB83B7E),
        foregroundColor: Colors.white,
        title: Text(widget.userData['namaLengkap'] ?? 'Detail Pasien'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab menu tetap di atas
          _buildTabMenu(),
          // Konten yang bisa scroll
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPatientInfoCard(),
                  _buildPatientSummaryCards(),
                  // Konten tab
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFB83B7E).withOpacity(0.1),
            child: const Icon(Icons.person, size: 40, color: Color(0xFFB83B7E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userData['namaLengkap'] ?? '-',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIK: ${widget.userData['nik'] ?? '-'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  widget.userData['email'] ?? '-',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSummaryCards() {
    final noKode = widget.userData['noKode'] as String?;
    
    if (noKode == null || noKode.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Ringkasan Profil Pasien',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB83B7E),
              ),
            ),
          ),
          // Row 1: Data Diri & Profil Kesehatan
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildDataDiriCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildProfilKesehatanCard(noKode)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Riwayat Makan & Obat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRiwayatMakanCard(noKode)),
              const SizedBox(width: 12),
              Expanded(child: _buildRiwayatObatCard(noKode)),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3: Perawatan Kaki & Manajemen Stress
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPerawatanKakiCard(noKode)),
              const SizedBox(width: 12),
              Expanded(child: _buildManajemenStressCard(noKode)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDataDiriCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Data Diri',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildSummaryItem('NIK', _maskNIK(widget.userData['nik'])),
          _buildSummaryItem('Jenis Kelamin', widget.userData['jenisKelamin'] ?? '-'),
          _buildSummaryItem('No. Kode', widget.userData['noKode'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildProfilKesehatanCard(String noKode) {
    final kebutuhanKalori = widget.userData['kebutuhanKalori'];
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Profil Kesehatan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (kebutuhanKalori != null) ...[
            _buildSummaryItem(
              'Kebutuhan Kalori',
              '${kebutuhanKalori.toStringAsFixed(0)} kal/hari',
            ),
            _buildSummaryItem(
              'TB / BB',
              '${widget.userData['tbKalori']?.toStringAsFixed(0) ?? '-'} cm / ${widget.userData['bbKalori']?.toStringAsFixed(0) ?? '-'} kg',
            ),
          ] else ...[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('food_logs')
                  .where('noKode', isEqualTo: noKode)
                  .orderBy('tanggal', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final latestFood = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final totalCalories = latestFood['calories'] ?? 0;
                  final date = (latestFood['tanggal'] as Timestamp).toDate();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryItem(
                        'Kalori Terakhir',
                        '${totalCalories.toStringAsFixed(0)} kal',
                      ),
                      _buildSummaryItem(
                        'Tanggal',
                        DateFormat('dd MMM yyyy').format(date),
                      ),
                    ],
                  );
                }
                return _buildSummaryItem('Status', 'Belum ada data');
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatMakanCard(String noKode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Riwayat Makan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('food_logs')
                .where('noKode', isEqualTo: noKode)
                .orderBy('tanggal', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildSummaryItem('Status', 'Belum ada data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final waktu = data['waktu'] ?? '';
                  final foodName = data['foodName'] ?? '';
                  final calories = data['calories'] ?? 0;

                  return _buildSummaryItem(
                    waktu,
                    '${foodName.length > 15 ? foodName.substring(0, 15) + '...' : foodName} (${calories.toStringAsFixed(0)} kal)',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatObatCard(String noKode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medication, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Riwayat Obat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('medication_logs')
                .where('noKode', isEqualTo: noKode)
                .orderBy('tanggal', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildSummaryItem('Status', 'Belum ada data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final waktu = data['waktu'] ?? '';
                  final jenisObat = data['jenisObat'] ?? '';
                  final dosis = data['dosis'] ?? 0;
                  final satuan = data['satuan'] ?? '';

                  return _buildSummaryItem(
                    waktu,
                    '$jenisObat ($dosis $satuan)',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerawatanKakiCard(String noKode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.accessibility, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Perawatan Kaki',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('foot_care_logs')
                .where('noKode', isEqualTo: noKode)
                .orderBy('tanggal', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildSummaryItem('Status', 'Belum ada data');
              }

              final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final statusKondisi = data['statusKondisi'] ?? '-';
              final skorRisiko = data['skorRisiko'] ?? 0;
              final date = (data['tanggal'] as Timestamp).toDate();
              final waktu = DateFormat('dd MMM').format(date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Terakhir', waktu),
                  _buildSummaryItem('Status', statusKondisi),
                  _buildSummaryItem('Skor Risiko', skorRisiko.toString()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManajemenStressCard(String noKode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, size: 16, color: Color(0xFFB83B7E)),
              const SizedBox(width: 6),
              const Text(
                'Manajemen Stress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB83B7E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('stress_management_logs')
                .where('noKode', isEqualTo: noKode)
                .orderBy('tanggal', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryItem('Tekanan Darah', '-'),
                    _buildSummaryItem('Status', 'Belum ada data'),
                  ],
                );
              }

              final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final tekananDarah = data['tekananDarah'] ?? '-';
              final statusStress = data['statusStress'] ?? '-';
              final status = statusStress.split(' - ')[0];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Tekanan Darah', '$tekananDarah mmHg'),
                  _buildSummaryItem('Status', status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabMenu() {
    final tabs = [
      {'icon': Icons.show_chart, 'label': 'Grafik'},
      {'icon': Icons.restaurant, 'label': 'Makan'},
      {'icon': Icons.medication, 'label': 'Obat'},
      {'icon': Icons.self_improvement, 'label': 'Stress'},
      {'icon': Icons.directions_run, 'label': 'Fisik'},
      {'icon': Icons.accessibility, 'label': 'Kaki'},
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTab == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFB83B7E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFFB83B7E).withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[index]['icon'] as IconData,
                    color: isSelected ? Colors.white : const Color(0xFFB83B7E),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tabs[index]['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildGrafikTab();
      case 1:
        return _buildMakanTab();
      case 2:
        return _buildObatTab();
      case 3:
        return _buildManajemenStressTab();
      case 4:
        return _buildLatihanFisikTab();
      case 5:
        return _buildPerawatanKakiTab();
      default:
        return const SizedBox();
    }
  }

  // Tab khusus untuk data makan (real data dari Firestore)
  Widget _buildMakanTab() {
    if (widget.foodLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data makanan',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pasien belum mencatat aktivitas makan',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.foodLogs.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['menu'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB83B7E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['kategori'],
                                  style: const TextStyle(
                                    color: Color(0xFFB83B7E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['waktuMakan'],
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item['gram'].toStringAsFixed(0)}g',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB83B7E),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientInfo(
                        'Kalori',
                        '${item['kalori'].toStringAsFixed(0)} kkal',
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildNutrientInfo(
                        'Karbo',
                        '${item['karbohidrat'].toStringAsFixed(1)}g',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientInfo(
                        'Protein',
                        '${item['protein'].toStringAsFixed(1)}g',
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildNutrientInfo(
                        'Lemak',
                        '${item['lemak'].toStringAsFixed(1)}g',
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['tanggal'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      item['waktu'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Tab khusus untuk data minum obat (real data dari Firestore)
  Widget _buildObatTab() {
    if (widget.medicationLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.medication, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data minum obat',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pasien belum mencatat aktivitas minum obat',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.medicationLogs.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['jenisObat'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Minum ${item['waktuMinum']}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${item['dosis'].toStringAsFixed(item['dosis'] % 1 == 0 ? 0 : 1)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB83B7E),
                          ),
                        ),
                        Text(
                          item['satuan'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['tanggal'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['waktu'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Oleh: ${item['userName']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Tab khusus untuk data latihan fisik (real data dari Firestore)
  Widget _buildLatihanFisikTab() {
    if (widget.latihanFisikLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data latihan fisik',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pasien belum mencatat aktivitas latihan fisik',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.latihanFisikLogs.map((item) {
          final kategori = item['kategoriIntensitas'] as String;
          final durasi = item['durasi'] as int;
          final kalori = item['kaloriTerbakar'] as int;
          final jenisOlahraga = item['jenisOlahraga'] as String;
          final manfaat = item['manfaat'] as List<String>;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getLatihanIntensitasColor(kategori).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getLatihanIcon(jenisOlahraga),
                        color: _getLatihanIntensitasColor(kategori),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jenisOlahraga,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getLatihanIntensitasColor(kategori).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              kategori.split(' - ')[0],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getLatihanIntensitasColor(kategori),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer, size: 18, color: Colors.blue),
                                const SizedBox(width: 4),
                                const Text(
                                  'Durasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$durasi',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'Menit',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_fire_department, 
                                  size: 18, color: Colors.orange),
                                const SizedBox(width: 4),
                                const Text(
                                  'Kalori',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$kalori',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              'kal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (manfaat.isNotEmpty) ...[
                  const Text(
                    'Manfaat Utama:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...manfaat.take(2).map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, 
                          size: 14, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            m.replaceAll('✓ ', ''),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  if (manfaat.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${manfaat.length - 2} manfaat lainnya',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['tanggal'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['waktu'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${item['userName']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getLatihanIntensitasColor(String kategori) {
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

  IconData _getLatihanIcon(String jenisOlahraga) {
    switch (jenisOlahraga) {
      case 'Jalan Kaki':
        return Icons.directions_walk;
      case 'Jogging':
      case 'Lari':
        return Icons.directions_run;
      case 'Bersepeda':
        return Icons.directions_bike;
      case 'Berenang':
        return Icons.pool;
      case 'Senam':
      case 'Yoga':
        return Icons.self_improvement;
      case 'Angkat Beban':
        return Icons.fitness_center;
      case 'Badminton':
      case 'Tenis':
        return Icons.sports_tennis;
      case 'Futsal':
      case 'Basket':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }

  // Tab khusus untuk data perawatan kaki (real data dari Firestore)
  Widget _buildPerawatanKakiTab() {
    if (widget.footCareLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data perawatan kaki',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pasien belum mencatat observasi perawatan kaki',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.footCareLogs.map((item) {
          final skorRisiko = item['skorRisiko'] as int;
          final kondisiKaki = item['kondisiKaki'] as List<String>;
          final rekomendasi = item['rekomendasi'] as List<String>;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _getFootCareStatusColor(skorRisiko),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _getFootCareIcon(skorRisiko),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['statusKondisi'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _getFootCareStatusColor(skorRisiko),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getFootCareStatusColor(skorRisiko).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Skor Risiko: $skorRisiko',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getFootCareStatusColor(skorRisiko),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                
                const Text(
                  'Kondisi yang Terdeteksi:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kondisiKaki.take(3).map((kondisi) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFB83B7E).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        kondisi,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB83B7E),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (kondisiKaki.length > 3) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${kondisiKaki.length - 3} kondisi lainnya',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                
                if (rekomendasi.isNotEmpty) ...[
                  const Text(
                    'Rekomendasi Utama:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: rekomendasi.first.contains('SEGERA')
                          ? const Color(0xFFFFEBEE)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rekomendasi.first.contains('SEGERA')
                            ? Colors.red.shade200
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          rekomendasi.first.contains('SEGERA')
                              ? Icons.priority_high
                              : Icons.info_outline,
                          size: 16,
                          color: rekomendasi.first.contains('SEGERA')
                              ? Colors.red
                              : Colors.grey[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rekomendasi.first,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['tanggal'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['waktu'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${item['userName']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Tab khusus untuk data manajemen stress (real data dari Firestore)
  Widget _buildManajemenStressTab() {
    if (widget.stressLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada data manajemen stress',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Pasien belum mencatat aktivitas manajemen stress',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: widget.stressLogs.map((item) {
          final skorStress = item['skorStress'] as int;
          final tekananDarah = item['tekananDarah'] as String;
          final perasaan = item['perasaan'] as String;
          final rekomendasi = item['rekomendasi'] as List<String>;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStressStatusColor(skorStress),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStressIcon(skorStress),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['statusStress'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _getStressStatusColor(skorStress),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStressStatusColor(skorStress).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Skor: $skorStress',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStressStatusColor(skorStress),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.favorite, size: 14, color: Color(0xFFE65100)),
                                const SizedBox(width: 4),
                                const Text(
                                  'Tekanan Darah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$tekananDarah mmHg',
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getEmotionIcon(perasaan),
                                  size: 14,
                                  color: const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 4),
                                const Expanded(
                                  child: Text(
                                    'Perasaan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              perasaan.replaceAll('Perasaan ', ''),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (rekomendasi.isNotEmpty) ...[
                  const Text(
                    'Rekomendasi Utama:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: rekomendasi.first.contains('SEGERA') || rekomendasi.first.contains('PENTING')
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rekomendasi.first.contains('SEGERA') || rekomendasi.first.contains('PENTING')
                            ? Colors.red.shade200
                            : Colors.purple.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          rekomendasi.first.contains('SEGERA') || rekomendasi.first.contains('PENTING')
                              ? Icons.priority_high
                              : Icons.lightbulb_outline,
                          size: 16,
                          color: rekomendasi.first.contains('SEGERA') || rekomendasi.first.contains('PENTING')
                              ? Colors.red
                              : Colors.purple[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rekomendasi.first,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['tanggal'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['waktu'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Oleh: ${item['userName']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStressStatusColor(int skorStress) {
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

  IconData _getStressIcon(int skorStress) {
    if (skorStress >= 15) {
      return Icons.warning;
    } else if (skorStress >= 10) {
      return Icons.error_outline;
    } else if (skorStress >= 6) {
      return Icons.info;
    } else if (skorStress >= 3) {
      return Icons.check_circle;
    } else {
      return Icons.thumb_up;
    }
  }

  IconData _getEmotionIcon(String perasaan) {
    if (perasaan.contains('Senang')) {
      return Icons.sentiment_very_satisfied;
    } else if (perasaan.contains('Marah')) {
      return Icons.sentiment_very_dissatisfied;
    } else if (perasaan.contains('Takut')) {
      return Icons.sentiment_dissatisfied;
    } else if (perasaan.contains('Stres') || perasaan.contains('Cemas')) {
      return Icons.sentiment_neutral;
    } else if (perasaan.contains('Sedih')) {
      return Icons.sentiment_dissatisfied;
    } else if (perasaan.contains('Depresi') || perasaan.contains('Obsesi')) {
      return Icons.sentiment_very_dissatisfied;
    } else {
      return Icons.sentiment_satisfied;
    }
  }

  Color _getFootCareStatusColor(int skorRisiko) {
    if (skorRisiko >= 10) {
      return Colors.red;
    } else if (skorRisiko >= 6) {
      return Colors.orange;
    } else if (skorRisiko >= 3) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData _getFootCareIcon(int skorRisiko) {
    if (skorRisiko >= 10) {
      return Icons.warning;
    } else if (skorRisiko >= 6) {
      return Icons.info;
    } else if (skorRisiko >= 3) {
      return Icons.check_circle;
    } else {
      return Icons.thumb_up;
    }
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGrafikTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildChartCard(
            'Grafik Gula Darah (mg/dL)',
            _buildGulaDarahChart(),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Grafik HbA1c (%)',
            _buildHbA1cChart(),
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Grafik Olahraga Harian (Kalori)',
            _buildOlahragaChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildGulaDarahChart() {
    final noKode = widget.userData['noKode'] as String?;
    
    if (noKode == null || noKode.isEmpty) {
      return Center(
        child: Text(
          'Data tidak tersedia',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('blood_sugar_logs')
          .where('noKode', isEqualTo: noKode)
          .orderBy('tanggal', descending: false)
          .limit(7)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada data gula darah',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final List<FlSpot> spots = [];
        final List<String> dates = [];

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;
          final gulaDarahPuasa = (data['gulaDarahPuasa'] as num?)?.toDouble() ?? 0;
          final tanggal = (data['tanggal'] as Timestamp).toDate();
          
          spots.add(FlSpot(i.toDouble(), gulaDarahPuasa));
          dates.add(DateFormat('dd/MM').format(tanggal));
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 50,
              getDrawingHorizontalLine: (value) {
                return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 50,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < dates.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          dates[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (spots.length - 1).toDouble(),
            minY: 0,
            maxY: 250,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: const Color(0xFFB83B7E),
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: const Color(0xFFB83B7E).withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHbA1cChart() {
    final noKode = widget.userData['noKode'] as String?;
    
    if (noKode == null || noKode.isEmpty) {
      return Center(
        child: Text(
          'Data tidak tersedia',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('hba1c_logs')
          .where('noKode', isEqualTo: noKode)
          .orderBy('tanggal', descending: false)
          .limit(6)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Belum ada data HbA1c',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        final List<BarChartGroupData> barGroups = [];
        final List<String> labels = [];

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;
          final nilaiHbA1c = (data['nilaiHbA1c'] as num?)?.toDouble() ?? 0;
          final tanggal = (data['tanggal'] as Timestamp).toDate();
          
          barGroups.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: nilaiHbA1c,
                  color: Colors.green,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          );
          labels.add(DateFormat('MMM').format(tanggal));
        }

        return BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < labels.length) {
                      return Text(
                        labels[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: barGroups,
            minY: 0,
            maxY: 12,
          ),
        );
      },
    );
  }

  Widget _buildOlahragaChart() {
    final olahragaData = widget.latihanFisikLogs;
    
    if (olahragaData.isEmpty) {
      return Center(
        child: Text(
          'Belum ada data latihan fisik',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < olahragaData.length) {
                  final tanggal = olahragaData[value.toInt()]['tanggal'];
                  return Text(
                    tanggal.substring(8),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: olahragaData.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['kaloriTerbakar'] as int).toDouble(),
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}