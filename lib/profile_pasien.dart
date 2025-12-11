import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilPasienScreen extends StatefulWidget {
  const ProfilPasienScreen({super.key});

  @override
  State<ProfilPasienScreen> createState() => _ProfilPasienScreenState();
}

class _ProfilPasienScreenState extends State<ProfilPasienScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading user data: $e');
    }
  }

  String _maskNIK(String? nik) {
    if (nik == null || nik.isEmpty) return '-';
    if (nik.length < 6) return nik;
    return '${nik.substring(0, 2)}${'*' * (nik.length - 4)}${nik.substring(nik.length - 2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE040A0), Color(0xFFD070C0)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE040A0), Color(0xFFD070C0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Photo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white,
                ),
                child: userData?['photoUrl'] != null
                    ? ClipOval(
                        child: Image.network(
                          userData!['photoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  size: 50, color: Color(0xFFB83B7E)),
                        ),
                      )
                    : const Icon(Icons.person,
                        size: 50, color: Color(0xFFB83B7E)),
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                userData?['namaLengkap'] ?? 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Phone
              Text(
                userData?['noHp'] ?? '-',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 4),
              // Kode
              Text(
                'No. Kode ${userData?['noKode'] ?? '-'}',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Main Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Ubah Button
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Navigate to edit profile
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Fitur edit profile')),
                            );
                          },
                          icon: const Text(
                            'ubah',
                            style: TextStyle(
                              color: Color(0xFFB83B7E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          label: const Icon(
                            Icons.edit,
                            color: Color(0xFFB83B7E),
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Row 1: Data Diri & Profil Kesehatan
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDataDiriCard(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildProfilKesehatanCard(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 2: Riwayat Makan & Riwayat Minum Obat
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildRiwayatMakanCard(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRiwayatObatCard(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 3: Perawatan Kaki & Manajemen Stres
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildPerawatanKakiCard(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildManajemenStressCard(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Ubah Password
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              // TODO: Navigate to change password
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Fitur ubah password')),
                              );
                            },
                            icon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFB83B7E),
                              size: 18,
                            ),
                            label: const Text(
                              'Ubah Password',
                              style: TextStyle(
                                color: Color(0xFFB83B7E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Keluar Button
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => _showLogoutDialog(context),
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Keluar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB83B7E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildDataDiriCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Diri',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoItem('NIK', _maskNIK(userData?['nik'])),
          _buildInfoItem('Alamat', userData?['alamat'] ?? '-'),
          _buildInfoItem('Jenis Kelamin', userData?['jenisKelamin'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildProfilKesehatanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Kesehatan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('food_logs')
                .where('noKode', isEqualTo: userData?['noKode'])
                .orderBy('tanggal', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final latestFood =
                    snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final totalCalories = latestFood['calories'] ?? 0;
                final date = (latestFood['tanggal'] as Timestamp).toDate();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      'Kalori Terakhir',
                      '${totalCalories.toStringAsFixed(0)} kal',
                    ),
                    _buildInfoItem(
                      'Tanggal',
                      DateFormat('dd MMM yyyy').format(date),
                    ),
                    _buildInfoItem('Status', 'Aktif Monitoring'),
                  ],
                );
              }
              return _buildInfoItem('Status', 'Belum ada data');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatMakanCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Makan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('food_logs')
                .where('noKode', isEqualTo: userData?['noKode'])
                .orderBy('tanggal', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildInfoItem('Status', 'Belum ada data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final waktu = data['waktu'] ?? '';
                  final jam = data['jam'] ?? '';
                  final foodName = data['foodName'] ?? '';
                  final calories = data['calories'] ?? 0;

                  return _buildInfoItem(
                    '$waktu ($jam WIB)',
                    '$foodName (${calories.toStringAsFixed(0)} kal)',
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatObatCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Minum Obat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('medication_logs')
                .where('noKode', isEqualTo: userData?['noKode'])
                .orderBy('tanggal', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildInfoItem('Status', 'Belum ada data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final waktu = data['waktu'] ?? '';
                  final jam = data['jam'] ?? '';
                  final jenisObat = data['jenisObat'] ?? '';
                  final dosis = data['dosis'] ?? 0;
                  final satuan = data['satuan'] ?? '';

                  return _buildInfoItem(
                    '$waktu ($jam WIB)',
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

  Widget _buildPerawatanKakiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perawatan Kaki',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('foot_care_logs')
                .where('noKode', isEqualTo: userData?['noKode'])
                .orderBy('tanggal', descending: true)
                .limit(2)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildInfoItem('Status', 'Belum ada data');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final jam = data['jam'] ?? '';
                  final statusKondisi = data['statusKondisi'] ?? '';
                  final date = (data['tanggal'] as Timestamp).toDate();
                  final waktu = DateFormat('dd MMM').format(date);

                  return _buildInfoItem(
                    '$waktu ($jam WIB)',
                    statusKondisi,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManajemenStressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Stres',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('stress_management_logs')
                .where('noKode', isEqualTo: userData?['noKode'])
                .orderBy('tanggal', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Tekanan Darah', '-'),
                    _buildInfoItem('Kondisi', 'Belum ada data'),
                  ],
                );
              }

              final data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final tekananDarah = data['tekananDarah'] ?? '-';
              final statusStress = data['statusStress'] ?? '-';
              final status = statusStress.split(' - ')[0]; // Ambil status saja

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoItem('Tekanan Darah', '$tekananDarah mmHg'),
                  _buildInfoItem('Kondisi', status),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ), 
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}