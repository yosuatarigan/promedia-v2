import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
  
  // Fungsi untuk mengambil data aktivitas makan real dari Firestore
  Future<List<Map<String, dynamic>>> _fetchFoodLogs(String userId, String noKode) async {
    try {
      // Query menggunakan noKode karena lebih reliable
      final snapshot = await _firestore
          .collection('food_logs')
          .where('noKode', isEqualTo: noKode)
          .get();

      if (snapshot.docs.isEmpty) {
        print('No food logs found for noKode: $noKode');
        return [];
      }

      // Sort by timestamp descending
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Take only last 20
      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'kategori': data['kategori'] ?? '-',
          'waktuMakan': data['waktu'] ?? '-', // Pagi/Siang/Malam
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

      // Sort by timestamp descending
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Take only last 20
      final limitedDocs = docs.take(20).toList();

      return limitedDocs.map((doc) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        
        return {
          'tanggal': DateFormat('yyyy-MM-dd').format(tanggal),
          'waktu': data['jam'] ?? '-',
          'waktuMinum': data['waktu'] ?? '-', // Pagi/Siang/Malam
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

      // Sort by timestamp descending
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Take only last 20
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

      // Sort by timestamp descending
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Take only last 20
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

      // Sort by timestamp descending
      final docs = snapshot.docs;
      docs.sort((a, b) {
        final aTime = (a.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime = (b.data()['tanggal'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      // Take only last 20
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
      currentIndex: _selectedIndex > 1 ? 1 : _selectedIndex,
      onTap: (index) {
        if (index == 2) {
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
          const Spacer(),
          _buildSidebarItem(
            icon: Icons.logout,
            title: 'Logout',
            index: -1,
            onTap: () => _confirmLogout(),
          ),
          const SizedBox(height: 20),
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
              _selectedIndex == 0 ? 'Dashboard' : 'Manage Users',
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
    } else {
      return _buildUserManagement();
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

        // Filter by role
        if (_selectedRole != 'all') {
          users = users.where((doc) => doc['role'] == _selectedRole).toList();
        }

        // Filter by search query
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
            DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: users.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DataRow(
              cells: [
                DataCell(Text(data['namaLengkap'] ?? '-')),
                DataCell(Text(data['email'] ?? '-')),
                DataCell(Text(data['nik'] ?? '-')),
                DataCell(_buildRoleBadge(data['role'] ?? '-')),
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
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
        ),
      ),
    );
    
    // Fetch data real dari Firestore
    final foodLogs = await _fetchFoodLogs(userId, noKode);
    final medicationLogs = await _fetchMedicationLogs(userId, noKode);
    final footCareLogs = await _fetchFootCareLogs(userId, noKode);
    final stressLogs = await _fetchStressLogs(userId, noKode);
    final latihanFisikLogs = await _fetchLatihanFisikLogs(userId, noKode);
    
    if (!mounted) return;
    
    // Hide loading
    Navigator.pop(context);
    
    // Debug print
    print('Food logs: ${foodLogs.length} items');
    print('Medication logs: ${medicationLogs.length} items');
    print('Foot care logs: ${footCareLogs.length} items');
    print('Stress logs: ${stressLogs.length} items');
    print('Latihan fisik logs: ${latihanFisikLogs.length} items');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PasienDetailScreen(
          userData: data,
          foodLogs: foodLogs,
          medicationLogs: medicationLogs,
          footCareLogs: footCareLogs,
          stressLogs: stressLogs,
          latihanFisikLogs: latihanFisikLogs,
        ),
      ),
    );
  }

  void _showUserDetail(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Jika pasien, tampilkan detail lengkap dengan aktivitas dan grafik
    if (data['role'] == 'pasien') {
      _showPasienDetail(doc);
      return;
    }
    
    // Jika keluarga, tampilkan detail biasa
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

// Screen untuk detail pasien dengan aktivitas dan grafik
class _PasienDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> foodLogs;
  final List<Map<String, dynamic>> medicationLogs;
  final List<Map<String, dynamic>> footCareLogs;
  final List<Map<String, dynamic>> stressLogs;
  final List<Map<String, dynamic>> latihanFisikLogs;

  const _PasienDetailScreen({
    required this.userData,
    required this.foodLogs,
    required this.medicationLogs,
    required this.footCareLogs,
    required this.stressLogs,
    required this.latihanFisikLogs,
  });

  @override
  State<_PasienDetailScreen> createState() => _PasienDetailScreenState();
}

class _PasienDetailScreenState extends State<_PasienDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  int _selectedTab = 0;

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
          _buildPatientInfoCard(),
          _buildTabMenu(),
          Expanded(child: _buildTabContent()),
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
                color: isSelected ? const Color(0xFFB83B7E) : Colors.white,
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.foodLogs.length,
      itemBuilder: (context, index) {
        final item = widget.foodLogs[index];
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
      },
    );
  }

  // Tab khusus untuk data minum obat (real data dari Firestore)
  Widget _buildObatTab() {
    if (widget.medicationLogs.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.medicationLogs.length,
      itemBuilder: (context, index) {
        final item = widget.medicationLogs[index];
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
      },
    );
  }

  // Tab khusus untuk data latihan fisik (real data dari Firestore)
  Widget _buildLatihanFisikTab() {
    if (widget.latihanFisikLogs.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.latihanFisikLogs.length,
      itemBuilder: (context, index) {
        final item = widget.latihanFisikLogs[index];
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
              // Header dengan jenis olahraga dan kategori
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
              
              // Info durasi dan kalori
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
              
              // Manfaat utama (max 2)
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
              
              // Footer info
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
      },
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.footCareLogs.length,
      itemBuilder: (context, index) {
        final item = widget.footCareLogs[index];
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
              // Header dengan status dan skor
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
              
              // Kondisi kaki yang terdeteksi
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
              
              // Rekomendasi prioritas
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
                          style: TextStyle(
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
              
              // Footer info
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
      },
    );
  }

  // Tab khusus untuk data manajemen stress (real data dari Firestore)
  Widget _buildManajemenStressTab() {
    if (widget.stressLogs.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.stressLogs.length,
      itemBuilder: (context, index) {
        final item = widget.stressLogs[index];
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
              // Header dengan status dan skor
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
              
              // Info vital signs
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
              
              // Rekomendasi prioritas
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
                          style: TextStyle(
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
              
              // Footer info
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
      },
    );
  }

  // Tab khusus untuk data latihan fisik (real data dari Firestore)
  // Widget _buildLatihanFisikTab() {
  //   if (widget.latihanFisikLogs.isEmpty) {
  //     return Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
  //           const SizedBox(height: 16),
  //           Text(
  //             'Belum ada data latihan fisik',
  //             style: TextStyle(color: Colors.grey[600], fontSize: 16),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Pasien belum mencatat aktivitas latihan fisik',
  //             style: TextStyle(color: Colors.grey[500], fontSize: 14),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: widget.latihanFisikLogs.length,
  //     itemBuilder: (context, index) {
  //       final item = widget.latihanFisikLogs[index];
  //       final durasi = item['durasi'] as int;
  //       final kalori = item['kaloriTerbakar'] as int;
  //       final kategori = item['kategoriIntensitas'] as String;
  //       final manfaat = item['manfaat'] as List<String>;
  //       final rekomendasi = item['rekomendasi'] as List<String>;
        
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 12),
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 5,
  //               offset: const Offset(0, 2),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Header dengan jenis olahraga
  //             Row(
  //               children: [
  //                 Container(
  //                   padding: const EdgeInsets.all(10),
  //                   decoration: BoxDecoration(
  //                     color: _getLatihanFisikColor(kategori).withOpacity(0.2),
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: Icon(
  //                     _getLatihanFisikIcon(item['jenisOlahraga']),
  //                     color: _getLatihanFisikColor(kategori),
  //                     size: 24,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         item['jenisOlahraga'],
  //                         style: const TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           fontSize: 16,
  //                           color: Colors.black87,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Container(
  //                         padding: const EdgeInsets.symmetric(
  //                           horizontal: 8,
  //                           vertical: 3,
  //                         ),
  //                         decoration: BoxDecoration(
  //                           color: _getLatihanFisikColor(kategori),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: Text(
  //                           kategori.split(' - ')[0],
  //                           style: const TextStyle(
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const Divider(height: 20),
              
  //             // Info durasi dan kalori
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     padding: const EdgeInsets.all(12),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFE3F2FD),
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(color: const Color(0xFFBBDEFB)),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         const Icon(Icons.timer, color: Colors.blue, size: 28),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           '$durasi',
  //                           style: const TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                           ),
  //                         ),
  //                         const Text(
  //                           'Menit',
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             color: Colors.black54,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 10),
  //                 Expanded(
  //                   child: Container(
  //                     padding: const EdgeInsets.all(12),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFFFF3E0),
  //                       borderRadius: BorderRadius.circular(8),
  //                       border: Border.all(color: const Color(0xFFFFE0B2)),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         const Icon(Icons.local_fire_department, 
  //                           color: Colors.orange, size: 28),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           '$kalori',
  //                           style: const TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                             color: Colors.black87,
  //                           ),
  //                         ),
  //                         const Text(
  //                           'Kalori',
  //                           style: TextStyle(
  //                             fontSize: 11,
  //                             color: Colors.black54,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 12),
              
  //             // Manfaat highlight (tampilkan 2 manfaat pertama)
  //             if (manfaat.isNotEmpty) ...[
  //               const Text(
  //                 'Manfaat Utama:',
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //               const SizedBox(height: 6),
  //               Container(
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFFE8F5E9),
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: const Color(0xFFC8E6C9)),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: manfaat.take(2).map((m) => Padding(
  //                     padding: const EdgeInsets.only(bottom: 4),
  //                     child: Text(
  //                       m,
  //                       style: const TextStyle(
  //                         fontSize: 11,
  //                         color: Colors.black87,
  //                         height: 1.3,
  //                       ),
  //                     ),
  //                   )).toList(),
  //                 ),
  //               ),
  //               if (manfaat.length > 2) ...[
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   '+${manfaat.length - 2} manfaat lainnya',
  //                   style: TextStyle(
  //                     fontSize: 10,
  //                     color: Colors.grey[600],
  //                     fontStyle: FontStyle.italic,
  //                   ),
  //                 ),
  //               ],
  //             ],
  //             const SizedBox(height: 12),
              
  //             // Footer info
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
  //                     const SizedBox(width: 4),
  //                     Text(
  //                       item['tanggal'],
  //                       style: TextStyle(
  //                         color: Colors.grey[600],
  //                         fontSize: 11,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
  //                     const SizedBox(width: 4),
  //                     Text(
  //                       item['waktu'],
  //                       style: TextStyle(
  //                         color: Colors.grey[600],
  //                         fontSize: 11,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               'Oleh: ${item['userName']}',
  //               style: TextStyle(
  //                 fontSize: 11,
  //                 color: Colors.grey[500],
  //                 fontStyle: FontStyle.italic,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Color _getLatihanFisikColor(String kategori) {
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

  IconData _getLatihanFisikIcon(String jenisOlahraga) {
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
      case 'Futsal':
      case 'Basket':
      case 'Tenis':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
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
    return SingleChildScrollView(
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