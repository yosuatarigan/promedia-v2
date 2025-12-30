import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/detail_latihan_fisik.dart';
import 'package:promedia_v2/detail_manajemen_screen.dart';
import 'package:promedia_v2/edukasi_diabetes.dart';
import 'package:promedia_v2/manajemen_stress.dart';
import 'package:promedia_v2/profile_pasien.dart';
import 'detail_makan_screen.dart';
import 'detail_minum_obat_screen.dart';
import 'detail_perawatan_kaki_screen.dart';
import 'chat_list_screen.dart';
import 'notifikasi_screen.dart';
import 'pengelolaan_makanan_screen.dart';
import 'terapi_obat_screen.dart';
import 'latihan_fisik_screen.dart';
import 'perawatan_kaki_screen.dart';

class HomePasienScreen extends StatefulWidget {
  const HomePasienScreen({super.key});

  @override
  State<HomePasienScreen> createState() => _HomePasienScreenState();
}

class _HomePasienScreenState extends State<HomePasienScreen> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache semua gambar aktivitas agar tidak flickering
    precacheImage(const AssetImage('assets/21.png'), context);
    precacheImage(const AssetImage('assets/22.png'), context);
    precacheImage(const AssetImage('assets/23.png'), context);
    precacheImage(const AssetImage('assets/24.png'), context);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Pagi';
    } else if (hour < 15) {
      return 'Siang';
    } else if (hour < 18) {
      return 'Sore';
    } else {
      return 'Malam';
    }
  }

  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildBerandaPage(),
          _buildRiwayatPage(),
          _buildChatPage(),
          _buildProfilPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // BERANDA PAGE
  Widget _buildBerandaPage() {
    final currentUser = _auth.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFB3D9), Color(0xFFE8C5F5)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with StreamBuilder
            StreamBuilder<DocumentSnapshot>(
              stream:
                  currentUser != null
                      ? _firestore
                          .collection('users')
                          .doc(currentUser.uid)
                          .snapshots()
                      : null,
              builder: (context, snapshot) {
                // Default values
                String namaLengkap = 'User';
                String? photoUrl;
                String jenisKelamin = 'Laki-laki';

                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  namaLengkap = userData['namaLengkap'] ?? 'User';
                  photoUrl = userData['photoUrl'];
                  jenisKelamin = userData['jenisKelamin'] ?? 'Laki-laki';
                }

                // Tentukan sapaan berdasarkan jenis kelamin
                String title = jenisKelamin == 'Laki-laki' ? 'Bapak' : 'Ibu';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Profile Picture
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFB83B7E),
                        ),
                        child:
                            photoUrl != null && photoUrl.isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          _getInitials(namaLengkap),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : Center(
                                  child: Text(
                                    _getInitials(namaLengkap),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, $title $namaLengkap',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'Anda punya ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '10',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const Text(
                                  ' aktivitas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Notification Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotifikasiScreen(),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade600,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Aktivitas Saya Hari Ini
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Aktivitas Saya Hari Ini',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildActivityCard(
                              'assets/21.png',
                              'Makan',
                              hasNotification: true,
                            ),
                            const SizedBox(width: 16),
                            _buildActivityCard(
                              'assets/22.png',
                              'Minum Obat',
                              hasNotification: true,
                            ),
                            const SizedBox(width: 16),
                            _buildActivityCard(
                              'assets/23.png',
                              'Perawatan Kaki',
                              hasNotification: true,
                            ),
                            const SizedBox(width: 16),
                            _buildActivityCard(
                              'assets/24.png',
                              'Manajemen Stress',
                              hasNotification: true,
                            ),
                            const SizedBox(width: 16),
                            _buildActivityCard(
                              'assets/exercise.png',
                              'Latihan Fisik',
                              hasNotification: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Program Manajemen Diabetes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Materi Edukasi Diabetes Melitus',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const DiabetesEducationPage(),
                                    ),
                                  ),
                              child: _buildProgramCard(
                                'assets/25.png',
                                'Pengelolaan\nDiabetes',
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Catatan - Horizontal Scroll
                            Text(
                              'Catatan Kesehatan',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.black87),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 280,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildChartCard(
                              'Gula Darah',
                              _buildBloodSugarChart(),
                            ),
                            const SizedBox(width: 16),
                            _buildChartCard('HbA1c', _buildHbA1cChart()),
                            const SizedBox(width: 16),
                            _buildChartCard(
                              'Olahraga Harian',
                              _buildOlahragaChart(),
                            ),
                          ],
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
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
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
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: chart),
        ],
      ),
    );
  }

  // RIWAYAT PAGE
  Widget _buildRiwayatPage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aktivitas Anda',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.black87),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Berikut ini adalah list aktivitas harian Anda pada tanggal 15 Agustus 2025',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.9,
                      children: [
                        _buildRiwayatCard('assets/21.png', 'Makan', true, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DetailMakanScreen(),
                            ),
                          );
                        }),
                        _buildRiwayatCard(
                          'assets/22.png',
                          'Minum Obat',
                          true,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DetailMinumObatScreen(),
                              ),
                            );
                          },
                        ),
                        _buildRiwayatCard(
                          'assets/23.png',
                          'Perawatan Kaki',
                          true,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const DetailPerawatanKakiScreen(),
                              ),
                            );
                          },
                        ),
                        _buildRiwayatCard(
                          'assets/24.png',
                          'Manajemen Stress',
                          true,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const DetailManajemenStressScreen(),
                              ),
                            );
                          },
                        ),
                        _buildRiwayatCard(
                          'assets/exercise.png',
                          'Latihan Fisik',
                          true,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DetailLatihanFisikScreen(),
                              ),
                            );
                          },
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CHAT PAGE
  Widget _buildChatPage() {
    return const ChatListScreen();
  }

  // PROFIL PAGE
  Widget _buildProfilPage() {
    return const ProfilPasienScreen();
  }

  Widget _buildActivityCard(
    String iconPath,
    String title, {
    bool hasNotification = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (title == 'Makan') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PengelolaanMakananScreen(),
            ),
          );
        } else if (title == 'Minum Obat') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TerapiObatScreen()),
          );
        } else if (title == 'Perawatan Kaki') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PerawatanKakiScreen(),
            ),
          );
        } else if (title == 'Manajemen Stress') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManajemenStressScreen(),
            ),
          );
        } else if (title == 'Latihan Fisik') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LatihanFisikScreen()),
          );
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  height: 60,
                  width: 60,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (hasNotification)
            Positioned(
              top: -5,
              right: 5,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(
    String iconPath,
    String title,
    bool hasNotification,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(iconPath, height: 80, fit: BoxFit.contain),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (hasNotification)
            Positioned(
              top: -5,
              right: 20,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(
    String iconPath,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, height: 100),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodSugarChart() {
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
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const dates = [
                  '15 Agustus',
                  '16 Agustus',
                  '17 Agustus',
                  '18 Agustus',
                  '19 Agustus',
                  '20 Agustus',
                  '21 Agustus',
                ];
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[value.toInt()],
                      style: const TextStyle(fontSize: 8),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 250,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 100),
              const FlSpot(1, 140),
              const FlSpot(2, 160),
              const FlSpot(3, 200),
              const FlSpot(4, 180),
              const FlSpot(5, 210),
              const FlSpot(6, 150),
            ],
            isCurved: true,
            color: const Color(0xFF4DD0E1),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildHbA1cChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const dates = [
                  '15 Agustus',
                  '16 Agustus',
                  '17 Agustus',
                  '18 Agustus',
                  '19 Agustus',
                  '20 Agustus',
                  '21 Agustus',
                ];
                if (value.toInt() >= 0 && value.toInt() < dates.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[value.toInt()],
                      style: const TextStyle(fontSize: 8),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 6),
              const FlSpot(1, 5),
              const FlSpot(2, 9),
              const FlSpot(3, 5.5),
              const FlSpot(4, 6),
              const FlSpot(5, 7.5),
              const FlSpot(6, 8),
            ],
            isCurved: true,
            color: const Color(0xFF4DD0E1),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildOlahragaChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const times = ['Jam 07.00', 'Jam 10.00'];
                if (value.toInt() >= 0 && value.toInt() < times.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      times[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 1,
        minY: 0,
        maxY: 40,
        lineBarsData: [
          LineChartBarData(
            spots: [const FlSpot(0, 30), const FlSpot(1, 40)],
            isCurved: true,
            color: const Color(0xFF4DD0E1),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFB83B7E),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
