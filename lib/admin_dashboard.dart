import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:promedia_v2/message_framing_screen.dart';
import 'package:promedia_v2/pasien_detail_screen_admin.dart';
import 'utils/file_downloader.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firestore = FirebaseFirestore.instance;
  String _selectedRole = 'all';
  String _searchQuery = '';
  int _selectedIndex = 0;
  final Set<String> _revealedPasswords = {};
  bool _isExportingExcel = false;
  
  // Fungsi untuk mengambil data aktivitas makan real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchFoodLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('food_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No food logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'kategori': data['kategori'] ?? '-',
          'waktuMakan': data['waktu'] ?? '-',
          'menu': data['foodName'] ?? '-',
          'gram': (data['grams'] as num?)?.toDouble() ?? 0.0,
          'kalori': (data['calories'] as num?)?.toDouble() ?? 0.0,
          'karbohidrat': (data['carbohydrate'] as num?)?.toDouble() ?? 0.0,
          'protein': (data['protein'] as num?)?.toDouble() ?? 0.0,
          'lemak': (data['fat'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching food logs: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data minum obat real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchMedicationLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('medication_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No medication logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'waktuMinum': data['waktu'] ?? '-',
          'jenisObat': data['jenisObat'] ?? '-',
          'dosis': (data['dosis'] as num?)?.toDouble() ?? 0.0,
          'satuan': data['satuan'] ?? '-',
          'userName': data['userName'] ?? '-',
        };
      }).toList();
    } catch (e) {
      print('Error fetching medication logs: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data perawatan kaki real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchFootCareLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('foot_care_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No foot care logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'kondisiKaki': List<String>.from(data['kondisiKaki'] ?? []),
          'skorRisiko': (data['skorRisiko'] as num?)?.toInt() ?? 0,
          'statusKondisi': data['statusKondisi'] ?? '-',
          'deskripsiObservasi': data['deskripsiObservasi'] ?? '-',
          'rekomendasi': List<String>.from(data['rekomendasi'] ?? []),
          'userName': data['userName'] ?? '-',
        };
      }).toList();
    } catch (e) {
      print('Error fetching foot care logs: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data manajemen stress real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchStressLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('stress_management_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No stress logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'tekananDarah': data['tekananDarah'] ?? '-',
          'perasaan': data['perasaan'] ?? '-',
          'skorStress': (data['skorStress'] as num?)?.toInt() ?? 0,
          'statusStress': data['statusStress'] ?? '-',
          'deskripsiObservasi': data['deskripsiObservasi'] ?? '-',
          'analisaTekananDarah': data['analisaTekananDarah'] ?? '-',
          'analisisPerasaan': data['analisisPerasaan'] ?? '-',
          'rekomendasi': List<String>.from(data['rekomendasi'] ?? []),
          'userName': data['userName'] ?? '-',
        };
      }).toList();
    } catch (e) {
      print('Error fetching stress logs: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data aktivitas tidur real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchAktivitasTidurLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('aktivitas_tidur_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No aktivitas tidur logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();

        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'jamTidur': data['jamTidur'] ?? '-',
          'jamBangun': data['jamBangun'] ?? '-',
          'durasiMenit': (data['durasiMenit'] as num?)?.toInt() ?? 0,
          'kualitas': data['kualitas'] ?? '-',
          'catatan': data['catatan'] ?? '',
          'userName': data['userName'] ?? '-',
        };
      }).toList();
    } catch (e) {
      print('Error fetching aktivitas tidur logs: $e');
      return [];
    }
  }

  // Fungsi untuk mengambil data latihan fisik real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchLatihanFisikLogs(String userId, String noKode) async {
    try {
      final snapshot = await _firestore
          .collection('latihan_fisik_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No latihan fisik logs found for noKode: $noKode');
        return [];
      }

      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'jenisOlahraga': data['jenisOlahraga'] ?? '-',
          'durasi': (data['durasi'] as num?)?.toInt() ?? 0,
          'satuanDurasi': data['satuanDurasi'] ?? 'Menit',
          'kaloriTerbakar': (data['kaloriTerbakar'] as num?)?.toInt() ?? 0,
          'kategoriIntensitas': data['kategoriIntensitas'] ?? '-',
          'manfaat': List<String>.from(data['manfaat'] ?? []),
          'rekomendasi': List<String>.from(data['rekomendasi'] ?? []),
          'userName': data['userName'] ?? '-',
        };
      }).toList();
    } catch (e) {
      print('Error fetching latihan fisik logs: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(child: _buildMainContent()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Column(
        children: [
          _buildMobileAppBar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex > 2 ? 2 : _selectedIndex,
      onTap: (index) {
        if (index == 3) {
          _confirmLogout();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      selectedItemColor: const Color(0xFFB83B7E),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Message',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFFB83B7E),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),
          _buildSidebarItem(
            icon: Icons.people,
            title: 'Manage Users',
            index: 1,
          ),
          _buildSidebarItem(
            icon: Icons.message,
            title: 'Message Framing',
            index: 2,
          ),
          // const Spacer(),
          // _buildSidebarItem(
          //   icon: Icons.logout,
          //   title: 'Logout',
          //   index: -1,
          //   onTap: () => _confirmLogout(),
          // ),
          // const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ??
          () {
            setState(() => _selectedIndex = index);
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileAppBar() {
    final titles = ['Dashboard', 'Manage Users', 'Message Framing'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB83B7E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              _selectedIndex < titles.length ? titles[_selectedIndex] : 'Dashboard',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedIndex == 0) {
      return _buildDashboardOverview();
    } else if (_selectedIndex == 1) {
      return _buildUserManagement();
    } else if (_selectedIndex == 2) {
      return const MessageFramingScreen();
    } else {
      return _buildDashboardOverview();
    }
  }

  Widget _buildDashboardOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data!.docs;
              final pasienCount = users.where((doc) => doc['role'] == 'pasien').length;
              final keluargaCount = users.where((doc) => doc['role'] == 'keluarga').length;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 768;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        users.length.toString(),
                        Icons.people,
                        Colors.blue,
                        isDesktop ? constraints.maxWidth / 3 - 32 : constraints.maxWidth,
                      ),
                      _buildStatCard(
                        'Pasien',
                        pasienCount.toString(),
                        Icons.person,
                        const Color(0xFFB83B7E),
                        isDesktop ? constraints.maxWidth / 3 - 32 : constraints.maxWidth,
                      ),
                      _buildStatCard(
                        'Keluarga',
                        keluargaCount.toString(),
                        Icons.family_restroom,
                        Colors.green,
                        isDesktop ? constraints.maxWidth / 3 - 32 : constraints.maxWidth,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return Column(
      children: [
        _buildUserFilters(),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  // ─── CSV Import ───────────────────────────────────────────────
  Future<void> _importFromCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final content = utf8.decode(result.files.single.bytes!);
    final rows = CsvDecoder().convert(content);

    if (rows.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File CSV kosong atau tidak valid')),
        );
      }
      return;
    }

    final header = rows.first.map((e) => e.toString().trim()).toList();
    final required = ['namaLengkap', 'email', 'password', 'role', 'noKode'];
    final missing = required.where((c) => !header.contains(c)).toList();
    if (missing.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kolom tidak lengkap: ${missing.join(', ')}')),
        );
      }
      return;
    }

    final dataRows = rows.skip(1).where((r) => r.any((c) => c.toString().trim().isNotEmpty)).toList();
    final users = dataRows.map((row) {
      final map = <String, String>{};
      for (int i = 0; i < header.length && i < row.length; i++) {
        map[header[i]] = row[i].toString().trim();
      }
      return map;
    }).toList();

    if (mounted) _showImportPreview(users);
  }

  // ─── Excel Export Semua Data ─────────────────────────────────
  Future<void> _exportAllToExcel() async {
    setState(() => _isExportingExcel = true);

    try {
      // Fetch semua user + 6 koleksi aktivitas secara paralel
      final results = await Future.wait([
        _firestore.collection('users').orderBy('noKode').get(),
        _firestore.collection('food_logs').get(),
        _firestore.collection('medication_logs').get(),
        _firestore.collection('aktivitas_tidur_logs').get(),
        _firestore.collection('latihan_fisik_logs').get(),
        _firestore.collection('stress_management_logs').get(),
        _firestore.collection('foot_care_logs').get(),
      ]);

      final users      = results[0].docs;
      final foodDocs   = results[1].docs;
      final obatDocs   = results[2].docs;
      final tidurDocs  = results[3].docs;
      final fisikDocs  = results[4].docs;
      final stressDocs = results[5].docs;
      final kakiDocs   = results[6].docs;

      String fmtDate(dynamic ts) {
        if (ts == null) return '-';
        return DateFormat('yyyy-MM-dd').format((ts as Timestamp).toDate());
      }

      int cmpDoc(QueryDocumentSnapshot a, QueryDocumentSnapshot b) {
        final da = a.data() as Map<String, dynamic>;
        final db = b.data() as Map<String, dynamic>;
        final nc = (da['noKode'] ?? '').compareTo(db['noKode'] ?? '');
        if (nc != 0) return nc;
        final at = (da['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bt = (db['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return at.compareTo(bt);
      }

      foodDocs.sort(cmpDoc);
      obatDocs.sort(cmpDoc);
      tidurDocs.sort(cmpDoc);
      fisikDocs.sort(cmpDoc);
      stressDocs.sort(cmpDoc);
      kakiDocs.sort(cmpDoc);

      // Helper: tulis header dengan warna & bold, set lebar kolom
      void addSheet(Sheet sheet, List<String> headers, List<double> widths) {
        final headerStyle = CellStyle(
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
          backgroundColorHex: ExcelColor.fromHexString('#B83B7E'),
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
          textWrapping: TextWrapping.WrapText,
        );
        sheet.setRowHeight(0, 28);
        sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
        for (int i = 0; i < headers.length; i++) {
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
              .cellStyle = headerStyle;
          if (i < widths.length) sheet.setColumnWidth(i, widths[i]);
        }
      }

      final excel = Excel.createExcel();
      // Jangan hapus Sheet1 dulu — hapus SETELAH semua sheet kustom dibuat

      // ── Sheet 1: Identitas User ──
      final sUser = excel['Identitas User'];
      addSheet(sUser,
        ['No Kode', 'Nama Lengkap', 'Email', 'No HP', 'NIK', 'Alamat', 'Jenis Kelamin', 'Role'],
        [10, 22, 28, 16, 18, 30, 14, 10],
      );
      for (final doc in users) {
        final u = doc.data() as Map<String, dynamic>;
        sUser.appendRow([
          TextCellValue(u['noKode'] ?? '-'),
          TextCellValue(u['namaLengkap'] ?? '-'),
          TextCellValue(u['email'] ?? '-'),
          TextCellValue(u['noHp'] ?? '-'),
          TextCellValue(u['nik'] ?? '-'),
          TextCellValue(u['alamat'] ?? '-'),
          TextCellValue(u['jenisKelamin'] ?? '-'),
          TextCellValue(u['role'] ?? '-'),
        ]);
      }

      // ── Sheet 2: Data Makan ──
      final sMakan = excel['Data Makan'];
      addSheet(sMakan,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Menu / Makanan', 'Kategori', 'Waktu Makan', 'Berat (g)', 'Kalori (kkal)', 'Karbohidrat (g)', 'Protein (g)', 'Lemak (g)'],
        [10, 20, 12, 8, 25, 14, 14, 10, 12, 14, 10, 10],
      );
      for (final doc in foodDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sMakan.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['foodName'] ?? '-'),
          TextCellValue(d['kategori'] ?? '-'),
          TextCellValue(d['waktu'] ?? '-'),
          DoubleCellValue((d['grams'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['calories'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['carbohydrate'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['protein'] as num?)?.toDouble() ?? 0),
          DoubleCellValue((d['fat'] as num?)?.toDouble() ?? 0),
        ]);
      }

      // ── Sheet 2: Minum Obat ──
      final sObat = excel['Minum Obat'];
      addSheet(sObat,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Waktu Minum', 'Jenis Obat', 'Dosis', 'Satuan'],
        [10, 20, 12, 8, 12, 22, 8, 10],
      );
      for (final doc in obatDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sObat.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['waktu'] ?? '-'),
          TextCellValue(d['jenisObat'] ?? '-'),
          DoubleCellValue((d['dosis'] as num?)?.toDouble() ?? 0),
          TextCellValue(d['satuan'] ?? '-'),
        ]);
      }

      // ── Sheet 3: Aktivitas Tidur ──
      final sTidur = excel['Aktivitas Tidur'];
      addSheet(sTidur,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Jam Tidur', 'Jam Bangun', 'Durasi (Menit)', 'Kualitas', 'Catatan'],
        [10, 20, 12, 10, 10, 14, 10, 30],
      );
      for (final doc in tidurDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sTidur.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jamTidur'] ?? '-'),
          TextCellValue(d['jamBangun'] ?? '-'),
          IntCellValue((d['durasiMenit'] as num?)?.toInt() ?? 0),
          TextCellValue(d['kualitas'] ?? '-'),
          TextCellValue(d['catatan'] ?? ''),
        ]);
      }

      // ── Sheet 4: Latihan Fisik ──
      final sFisik = excel['Latihan Fisik'];
      addSheet(sFisik,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Jenis Olahraga', 'Durasi', 'Satuan', 'Kalori Terbakar (kal)', 'Kategori Intensitas', 'Manfaat'],
        [10, 20, 12, 8, 18, 8, 8, 16, 20, 35],
      );
      for (final doc in fisikDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sFisik.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['jenisOlahraga'] ?? '-'),
          IntCellValue((d['durasi'] as num?)?.toInt() ?? 0),
          TextCellValue(d['satuanDurasi'] ?? 'Menit'),
          IntCellValue((d['kaloriTerbakar'] as num?)?.toInt() ?? 0),
          TextCellValue(d['kategoriIntensitas'] ?? '-'),
          TextCellValue((List<String>.from(d['manfaat'] ?? [])).join('; ')),
        ]);
      }

      // ── Sheet 5: Manajemen Stress ──
      final sStress = excel['Manajemen Stress'];
      addSheet(sStress,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Tekanan Darah', 'Perasaan', 'Skor Stress', 'Status Stress', 'Deskripsi Observasi', 'Analisa TD', 'Analisis Perasaan'],
        [10, 20, 12, 8, 14, 16, 11, 16, 30, 25, 25],
      );
      for (final doc in stressDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sStress.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue(d['tekananDarah'] ?? '-'),
          TextCellValue(d['perasaan'] ?? '-'),
          IntCellValue((d['skorStress'] as num?)?.toInt() ?? 0),
          TextCellValue(d['statusStress'] ?? '-'),
          TextCellValue(d['deskripsiObservasi'] ?? '-'),
          TextCellValue(d['analisaTekananDarah'] ?? '-'),
          TextCellValue(d['analisisPerasaan'] ?? '-'),
        ]);
      }

      // ── Sheet 6: Perawatan Kaki ──
      final sKaki = excel['Perawatan Kaki'];
      addSheet(sKaki,
        ['No Kode', 'Nama Pasien', 'Tanggal', 'Waktu', 'Kondisi Kaki', 'Skor Risiko', 'Status Kondisi', 'Deskripsi Observasi', 'Rekomendasi'],
        [10, 20, 12, 8, 30, 11, 16, 30, 35],
      );
      for (final doc in kakiDocs) {
        final d = doc.data() as Map<String, dynamic>;
        sKaki.appendRow([
          TextCellValue(d['noKode'] ?? '-'),
          TextCellValue(d['userName'] ?? '-'),
          TextCellValue(fmtDate(d['tanggal'])),
          TextCellValue(d['jam'] ?? '-'),
          TextCellValue((List<String>.from(d['kondisiKaki'] ?? [])).join('; ')),
          IntCellValue((d['skorRisiko'] as num?)?.toInt() ?? 0),
          TextCellValue(d['statusKondisi'] ?? '-'),
          TextCellValue(d['deskripsiObservasi'] ?? '-'),
          TextCellValue((List<String>.from(d['rekomendasi'] ?? [])).join('; ')),
        ]);
      }

      // Hapus Sheet1 default SETELAH semua sheet kustom dibuat
      // (package tidak bisa hapus sheet jika itu satu-satunya sheet)
      excel.delete('Sheet1');

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'laporan_semua_user_$timestamp.xlsx';

      // Di web, excel.save() sudah otomatis trigger download browser.
      // Di non-web, kita handle sendiri lewat downloadFileToDevice.
      final bytes = excel.save(fileName: fileName);
      if (bytes == null) throw Exception('Gagal membuat file Excel');

      if (!kIsWeb) {
        await downloadFileToDevice(Uint8List.fromList(bytes), fileName);
      }

      if (!mounted) return;
      setState(() => _isExportingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File Excel berhasil diunduh'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExportingExcel = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImportPreview(List<Map<String, String>> users) {
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Import ${users.length} Pengguna'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text('Nama')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Role')),
                          DataColumn(label: Text('No Kode')),
                        ],
                        rows: users.take(10).map((u) => DataRow(cells: [
                          DataCell(Text(u['namaLengkap'] ?? '-')),
                          DataCell(Text(u['email'] ?? '-')),
                          DataCell(Text(u['role'] ?? '-')),
                          DataCell(Text(u['noKode'] ?? '-')),
                        ])).toList(),
                      ),
                    ),
                  ),
                  if (users.length > 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('... dan ${users.length - 10} data lainnya',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                  const SizedBox(height: 20),
                  const Text('Masukkan password admin Anda untuk melanjutkan:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: 'Password admin',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setDialogState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text('Import', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB83B7E)),
              onPressed: () async {
                final pass = passwordController.text.trim();
                if (pass.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Password admin tidak boleh kosong')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                await _processImport(users, pass);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImport(List<Map<String, String>> users, String adminPassword) async {
    final auth = FirebaseAuth.instance;
    final adminUser = auth.currentUser;
    if (adminUser == null) return;
    final adminEmail = adminUser.email!;

    int success = 0;
    int failed = 0;
    final List<String> errors = [];

    // Progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Sedang mengimpor data pengguna...')),
          ],
        ),
      ),
    );

    for (final user in users) {
      final email = user['email'] ?? '';
      final password = user['password'] ?? '';
      final nama = user['namaLengkap'] ?? '';
      final role = user['role'] ?? '';
      final noKode = user['noKode'] ?? '';

      if (email.isEmpty || password.isEmpty || nama.isEmpty || role.isEmpty || noKode.isEmpty) {
        failed++;
        errors.add('$nama: data tidak lengkap');
        continue;
      }

      try {
        // Buat akun baru
        final cred = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Simpan data ke Firestore
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'namaLengkap': nama,
          'email': email,
          'role': role,
          'noKode': noKode,
          'nik': user['nik'] ?? '',
          'nomorHP': user['nomorHP'] ?? '',
          'jenisKelamin': user['jenisKelamin'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        success++;

        // Re-login sebagai admin
        await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
      } catch (e) {
        failed++;
        errors.add('$nama ($email): $e');
        // Pastikan tetap login sebagai admin jika error
        try {
          await auth.signInWithEmailAndPassword(email: adminEmail, password: adminPassword);
        } catch (_) {}
      }
    }

    // Tutup progress dialog
    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    // Tampilkan hasil
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hasil Import'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Berhasil: $success pengguna'),
                ]),
                if (failed > 0) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Gagal: $failed pengguna'),
                  ]),
                  const SizedBox(height: 8),
                  ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(left: 32, bottom: 4),
                    child: Text('• $e', style: const TextStyle(fontSize: 12, color: Colors.red)),
                  )),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  // ─────────────────────────────────────────────────────────────

  Widget _buildUserFilters() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage Users',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, atau NIK...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Semua')),
                  DropdownMenuItem(value: 'pasien', child: Text('Pasien')),
                  DropdownMenuItem(value: 'keluarga', child: Text('Keluarga')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              // const SizedBox(width: 16),
              // ElevatedButton.icon(
              //   onPressed: _importFromCSV,
              //   icon: const Icon(Icons.upload_file, color: Colors.white),
              //   label: const Text('Import CSV', style: TextStyle(color: Colors.white)),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFFB83B7E),
              //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              //   ),
              // ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isExportingExcel ? null : _exportAllToExcel,
                icon: _isExportingExcel
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.download_outlined, color: Colors.white),
                label: Text(
                  _isExportingExcel ? 'Mengekspor...' : 'Export Excel',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada data user'));
        }

        var users = snapshot.data!.docs;

        if (_selectedRole != 'all') {
          users = users.where((doc) => doc['role'] == _selectedRole).toList();
        }

        if (_searchQuery.isNotEmpty) {
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final searchLower = _searchQuery.toLowerCase();
            return data['namaLengkap']?.toLowerCase().contains(searchLower) == true ||
                data['email']?.toLowerCase().contains(searchLower) == true ||
                data['nik']?.toLowerCase().contains(searchLower) == true;
          }).toList();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 768;
            
            if (isDesktop) {
              return _buildDesktopTable(users);
            } else {
              return _buildMobileList(users);
            }
          },
        );
      },
    );
  }

  Widget _buildDesktopTable(List<QueryDocumentSnapshot> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('NIK', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            final pass = data['password'] as String?;
            final isRevealed = _revealedPasswords.contains(docId);
            return DataRow(
              cells: [
                DataCell(Text(data['namaLengkap'] ?? '-')),
                DataCell(Text(data['email'] ?? '-')),
                DataCell(Text(data['nik'] ?? '-')),
                DataCell(_buildRoleBadge(data['role'] ?? '-')),
                DataCell(
                  pass == null
                      ? const Text('-', style: TextStyle(color: Colors.grey))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isRevealed ? pass : '••••••••',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            IconButton(
                              icon: Icon(
                                isRevealed ? Icons.visibility_off : Icons.visibility,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () => setState(() {
                                if (isRevealed) {
                                  _revealedPasswords.remove(docId);
                                } else {
                                  _revealedPasswords.add(docId);
                                }
                              }),
                            ),
                          ],
                        ),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () => _showUserDetail(doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditUser(doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(doc),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(List<QueryDocumentSnapshot> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final data = users[index].data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFB83B7E).withOpacity(0.1),
              child: Icon(
                data['role'] == 'pasien' ? Icons.person : Icons.family_restroom,
                color: const Color(0xFFB83B7E),
              ),
            ),
            title: Text(
              data['namaLengkap'] ?? '-',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(data['email'] ?? '-'),
                const SizedBox(height: 4),
                _buildRoleBadge(data['role'] ?? '-'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('Lihat Detail')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
              onSelected: (value) {
                if (value == 'view') _showUserDetail(users[index]);
                if (value == 'edit') _showEditUser(users[index]);
                if (value == 'delete') _confirmDelete(users[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = role == 'pasien' ? const Color(0xFFB83B7E) : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPasienDetail(QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['uid'] as String;
    final noKode = data['noKode'] as String;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
        ),
      ),
    );
    
    final foodLogs = await _fetchFoodLogs(userId, noKode);
    final medicationLogs = await _fetchMedicationLogs(userId, noKode);
    final footCareLogs = await _fetchFootCareLogs(userId, noKode);
    final stressLogs = await _fetchStressLogs(userId, noKode);
    final latihanFisikLogs = await _fetchLatihanFisikLogs(userId, noKode);
    final aktivitasTidurLogs = await _fetchAktivitasTidurLogs(userId, noKode);

    if (!mounted) return;

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasienDetailScreen(
          userData: data,
          foodLogs: foodLogs,
          medicationLogs: medicationLogs,
          footCareLogs: footCareLogs,
          stressLogs: stressLogs,
          latihanFisikLogs: latihanFisikLogs,
          aktivitasTidurLogs: aktivitasTidurLogs,
        ),
      ),
    );
  }

  void _showUserDetail(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    if (data['role'] == 'pasien') {
      _showPasienDetail(doc);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        bool obscurePass = true;
        final pass = data['password'] as String?;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Detail User'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Nama', data['namaLengkap'] ?? '-'),
                  _buildDetailRow('Email', data['email'] ?? '-'),
                  _buildDetailRow('NIK', data['nik'] ?? '-'),
                  _buildDetailRow('No HP', data['noHp'] ?? '-'),
                  _buildDetailRow('No Kode', data['noKode'] ?? '-'),
                  _buildDetailRow('Alamat', data['alamat'] ?? '-'),
                  _buildDetailRow('Jenis Kelamin', data['jenisKelamin'] ?? '-'),
                  _buildDetailRow('Role', data['role'] ?? '-'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Password',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              pass == null
                                  ? '-'
                                  : (obscurePass ? '••••••••' : pass),
                              style: const TextStyle(
                                  fontFamily: 'monospace', fontSize: 15),
                            ),
                            if (pass != null)
                              IconButton(
                                icon: Icon(obscurePass
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setDialogState(
                                    () => obscurePass = !obscurePass),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUser(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final namaController = TextEditingController(text: data['namaLengkap']);
    final emailController = TextEditingController(text: data['email']);
    final noHpController = TextEditingController(text: data['noHp']?.replaceFirst('+62', ''));
    final alamatController = TextEditingController(text: data['alamat']);
    String? selectedJenisKelamin = data['jenisKelamin'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(
                  labelText: 'No HP',
                  prefixText: '+62',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedJenisKelamin,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: const [
                    DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (value) => setState(() => selectedJenisKelamin = value),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(doc.id).update({
                'namaLengkap': namaController.text,
                'noHp': '+62${noHpController.text}',
                'alamat': alamatController.text,
                'jenisKelamin': selectedJenisKelamin,
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User berhasil diupdate')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(QueryDocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('users').doc(doc.id).delete();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
