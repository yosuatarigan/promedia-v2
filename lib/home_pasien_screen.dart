import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/catatan_hba1c.dart';
import 'package:promedia_v2/detail_latihan_fisik.dart';
import 'package:promedia_v2/detail_manajemen_screen.dart';
import 'package:promedia_v2/edukasi_diabetes.dart';
import 'package:promedia_v2/manajemen_stress.dart';
import 'package:promedia_v2/profile_pasien.dart';
import 'package:promedia_v2/catatan_gula_darah_screen.dart';
import 'package:promedia_v2/reminder_service.dart';
import 'package:promedia_v2/reminder_popup_banner.dart';
import 'detail_makan_screen.dart';
import 'detail_minum_obat_screen.dart';
import 'detail_perawatan_kaki_screen.dart';
import 'chat_list_screen.dart';
import 'notifikasi_screen.dart';
import 'pengelolaan_makanan_screen.dart';
import 'terapi_obat_screen.dart';
import 'latihan_fisik_screen.dart';
import 'perawatan_kaki_screen.dart';
import 'package:intl/intl.dart';

class HomePasienScreen extends StatefulWidget {
  const HomePasienScreen({super.key});

  @override
  State<HomePasienScreen> createState() => _HomePasienScreenState();
}

class _HomePasienScreenState extends State<HomePasienScreen> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _reminderService = ReminderService();
  
  // Pop-up notifikasi state
  bool _isCheckingReminder = false;
  String? _currentReminderId;
  OverlayEntry? _popupOverlay;

  @override
  void initState() {
    super.initState();
    // Check for reminders setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowReminder();
    });
  }

  @override
  void dispose() {
    _popupOverlay?.remove();
    _popupOverlay = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/21.png'), context);
    precacheImage(const AssetImage('assets/22.png'), context);
    precacheImage(const AssetImage('assets/23.png'), context);
    precacheImage(const AssetImage('assets/24.png'), context);
  }

  // Check dan tampilkan reminder pop-up
  Future<void> _checkAndShowReminder() async {
    if (_isCheckingReminder) return;
    
    setState(() => _isCheckingReminder = true);

    try {
      final latestReminder = await _reminderService.getLatestUnreadReminder();
      
      if (latestReminder != null && mounted) {
        final data = latestReminder.data() as Map<String, dynamic>;
        final type = data['type'] as String;
        final message = data['message'] as String;
        
        _currentReminderId = latestReminder.id;

        String title = _getTitleFromType(type);
        String subtitle = message;

        _showReminderPopup(
          type: type,
          title: title,
          subtitle: subtitle,
          reminderId: latestReminder.id,
        );
      }
    } catch (e) {
      print('Error checking reminder: $e');
    } finally {
      setState(() => _isCheckingReminder = false);
    }
  }

  String _getTitleFromType(String type) {
    switch (type) {
      case 'makan':
        return 'Waktunya Makan!';
      case 'minum_obat':
        return 'Waktunya Minum Obat!';
      case 'perawatan_kaki':
        return 'Waktunya Perawatan Kaki!';
      case 'manajemen_stress':
        return 'Waktunya Kelola Stress!';
      case 'latihan_fisik':
        return 'Waktunya Olahraga!';
      default:
        return 'Pengingat untuk Anda';
    }
  }

  Widget? _getActivityScreen(String type) {
    switch (type) {
      case 'makan':
        return const PengelolaanMakananScreen();
      case 'minum_obat':
        return const TerapiObatScreen();
      case 'perawatan_kaki':
        return const PerawatanKakiScreen();
      case 'manajemen_stress':
        return const ManajemenStressScreen();
      case 'latihan_fisik':
        return const LatihanFisikScreen();
      default:
        return null;
    }
  }

  void _showReminderPopup({
    required String type,
    required String title,
    required String subtitle,
    required String reminderId,
  }) {
    _popupOverlay?.remove();
    _popupOverlay = null;

    _popupOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: ReminderPopupBanner(
            activityType: type,
            title: title,
            subtitle: subtitle,
            onMulaSekarang: () async {
              _popupOverlay?.remove();
              _popupOverlay = null;

              await _reminderService.markAsRead(reminderId);

              final screen = _getActivityScreen(type);
              if (screen != null && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              }
            },
            onTunda: () async {
              _popupOverlay?.remove();
              _popupOverlay = null;

              await _reminderService.snoozeReminder(reminderId);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengingat ditunda 10 menit'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            onDismiss: () {
              _popupOverlay?.remove();
              _popupOverlay = null;
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_popupOverlay!);

    Future.delayed(const Duration(seconds: 30), () {
      _popupOverlay?.remove();
      _popupOverlay = null;
    });
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

  Widget _buildBerandaPage() {
    // Check reminder when beranda is opened
    if (_selectedIndex == 0 && !_isCheckingReminder) {
      Future.delayed(Duration.zero, () => _checkAndShowReminder());
    }

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
            StreamBuilder<DocumentSnapshot>(
              stream:
                  currentUser != null
                      ? _firestore
                          .collection('users')
                          .doc(currentUser.uid)
                          .snapshots()
                      : null,
              builder: (context, snapshot) {
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

                String title = jenisKelamin == 'Laki-laki' ? 'Bapak' : 'Ibu';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotifikasiScreen(),
                            ),
                          );
                        },
                        child: StreamBuilder<int>(
                          stream: _reminderService.getUnreadReminderCount(),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;

                            return Stack(
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
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Text(
                                        unreadCount > 9
                                            ? '9+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

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
                            _buildChartCardWithTap(
                              'Gula Darah',
                              _buildBloodSugarChart(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const CatatanGulaDarahScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            _buildChartCardWithTap(
                              'HbA1c',
                              _buildHbA1cChart(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const CatatanHbA1cScreen(),
                                  ),
                                );
                              },
                            ),
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

  Widget _buildChartCardWithTap(
    String title,
    Widget chart, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.add_circle, color: Colors.blue.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatPage() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aktivitas Anda',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.black87),
              ),
            ),
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
                                builder:
                                    (context) =>
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

  Widget _buildChatPage() {
    return const ChatListScreen();
  }

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
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Login terlebih dahulu'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final noKode = userSnapshot.data?.get('noKode') ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('blood_sugar_logs')
                  .where('noKode', isEqualTo: noKode)
                  .orderBy('tanggal', descending: false)
                  .limit(7)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada data gula darah.\nTap untuk menambah data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final List<FlSpot> spots = [];
            final List<String> dates = [];

            for (int i = 0; i < docs.length; i++) {
              final data = docs[i].data() as Map<String, dynamic>;
              final gulaDarahPuasa = (data['gulaDarahPuasa'] ?? 0).toDouble();
              final tanggal = (data['tanggal'] as Timestamp).toDate();

              spots.add(FlSpot(i.toDouble(), gulaDarahPuasa));
              dates.add(DateFormat('dd MMM').format(tanggal));
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
                        if (value.toInt() >= 0 &&
                            value.toInt() < dates.length) {
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
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 250,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4DD0E1),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHbA1cChart() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Login terlebih dahulu'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final noKode = userSnapshot.data?.get('noKode') ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('hba1c_logs')
                  .where('noKode', isEqualTo: noKode)
                  .orderBy('tanggal', descending: false)
                  .limit(7)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada data HbA1c.\nTap untuk menambah data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final List<FlSpot> spots = [];
            final List<String> dates = [];

            for (int i = 0; i < docs.length; i++) {
              final data = docs[i].data() as Map<String, dynamic>;
              final nilaiHbA1c = (data['nilaiHbA1c'] ?? 0).toDouble();
              final tanggal = (data['tanggal'] as Timestamp).toDate();

              spots.add(FlSpot(i.toDouble(), nilaiHbA1c));
              dates.add(DateFormat('dd MMM').format(tanggal));
            }

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
                        if (value.toInt() >= 0 &&
                            value.toInt() < dates.length) {
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
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: 12,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4DD0E1),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOlahragaChart() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Login terlebih dahulu'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final noKode = userSnapshot.data?.get('noKode') ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('latihan_fisik_logs')
                  .where('noKode', isEqualTo: noKode)
                  .orderBy('tanggal', descending: false)
                  .limit(7)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada data latihan fisik.\nMulai catat aktivitas olahraga Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            final List<FlSpot> spots = [];
            final List<String> labels = [];

            for (int i = 0; i < docs.length; i++) {
              final data = docs[i].data() as Map<String, dynamic>;
              final durasi = (data['durasi'] ?? 0).toDouble();
              final tanggal = (data['tanggal'] as Timestamp).toDate();
              final jam = data['jam'] ?? '';

              spots.add(FlSpot(i.toDouble(), durasi));
              labels.add('${DateFormat('dd MMM').format(tanggal)}\n$jam');
            }

            double maxDurasi = spots
                .map((s) => s.y)
                .reduce((a, b) => a > b ? a : b);
            double maxY =
                (maxDurasi * 1.2).ceilToDouble();
            if (maxY < 60) maxY = 60;

            return LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 4,
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
                        if (value.toInt() >= 0 &&
                            value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              textAlign: TextAlign.center,
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
                maxX: (spots.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4DD0E1),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4DD0E1).withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < docs.length) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final jenisOlahraga = data['jenisOlahraga'] ?? '';
                          return LineTooltipItem(
                            '$jenisOlahraga\n${spot.y.toInt()} menit',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }
                        return LineTooltipItem(
                          '${spot.y.toInt()} menit',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
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