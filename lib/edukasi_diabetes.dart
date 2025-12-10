import 'package:flutter/material.dart';
import 'pilar1_edukasi.dart';
import 'pilar2_makan_sehat.dart';
import 'pilar3_latihan_fisik.dart';
import 'pilar4_pemantauan.dart';
import 'pilar5_penggunaan_obat.dart';
import 'pilar6.dart';

class DiabetesEducationPage extends StatelessWidget {
  const DiabetesEducationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
              Colors.purple[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Materi Edukasi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Diabetes Melitus',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Cards List
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 8),
                      _buildPillarCard(
                        context,
                        '1',
                        'Edukasi',
                        'Pemahaman dasar diabetes',
                        Icons.lightbulb_rounded,
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar1EdukasiPage(),
                            ),
                          );
                        },
                      ),
                      _buildPillarCard(
                        context,
                        '2',
                        'Makan Sehat',
                        'Pengaturan pola makan',
                        Icons.restaurant_rounded,
                        const Color(0xFF10B981),
                        const Color(0xFF059669),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar2MakanSehatPage(),
                            ),
                          );
                        },
                      ),
                      _buildPillarCard(
                        context,
                        '3',
                        'Latihan Fisik',
                        'Aktivitas & olahraga teratur',
                        Icons.fitness_center_rounded,
                        const Color(0xFFEC4899),
                        const Color(0xFFDB2777),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar3LatihanFisikPage(),
                            ),
                          );
                        },
                      ),
                      _buildPillarCard(
                        context,
                        '4',
                        'Pemantauan Gula Darah',
                        'Monitor rutin gula darah',
                        Icons.monitor_heart_rounded,
                        const Color(0xFFF59E0B),
                        const Color(0xFFD97706),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar4PemantauanPage(),
                            ),
                          );
                        },
                      ),
                      _buildPillarCard(
                        context,
                        '5',
                        'Penggunaan Obat',
                        'Kepatuhan minum obat',
                        Icons.medication_rounded,
                        const Color(0xFF3B82F6),
                        const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar5PenggunaanObatPage(),
                            ),
                          );
                        },
                      ),
                      _buildPillarCard(
                        context,
                        '6',
                        'Pencegahan Komplikasi',
                        'Cegah komplikasi diabetes',
                        Icons.shield_rounded,
                        const Color(0xFFEF4444),
                        const Color(0xFFDC2626),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Pilar6PencegahanKomplikasiPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarCard(
    BuildContext context,
    String number,
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Pilar $number',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}