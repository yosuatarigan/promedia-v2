import 'package:flutter/material.dart';
import 'package:promedia_v2/detail_manajemen_screen.dart';
import 'detail_makan_screen.dart';
import 'detail_minum_obat_screen.dart';
import 'detail_perawatan_kaki_screen.dart';

class RiwayatAktivitasScreen extends StatelessWidget {
  const RiwayatAktivitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Aktivitas Anda',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Description Text
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

            // Grid Aktivitas
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildActivityCard(
                  context,
                  'assets/21.png',
                  'Makan',
                  hasNotification: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailMakanScreen(),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  'assets/22.png',
                  'Minum Obat',
                  hasNotification: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailMinumObatScreen(),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  'assets/23.png',
                  'Perawatan Kaki',
                  hasNotification: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailPerawatanKakiScreen(),
                      ),
                    );
                  },
                ),
                _buildActivityCard(
                  context,
                  'assets/24.png',
                  'Manajemen Stress',
                  hasNotification: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DetailManajemenStressScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String iconPath,
    String title, {
    bool hasNotification = false,
    VoidCallback? onTap,
  }) {
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
                Image.asset(
                  iconPath,
                  height: 80,
                  fit: BoxFit.contain,
                ),
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
}