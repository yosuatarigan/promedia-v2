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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEC4899),
              const Color(0xFFF472B6),
              const Color(0xFFFBBF24),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header dengan Title dalam satu baris
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: Color(0xFFEC4899),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Materi Edukasi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Diabetes Melitus',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cards Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildPillarCard(
                        context,
                        '1',
                        'Edukasi',
                        'Pemahaman dasar diabetes',
                        Icons.lightbulb_rounded,
                        const Color(0xFFF472B6),
                        const Color(0xFFEC4899),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar1EdukasiPage()),
                        ),
                      ),
                      _buildPillarCard(
                        context,
                        '2',
                        'Makan Sehat',
                        'Pengaturan pola makan',
                        Icons.restaurant_rounded,
                        const Color(0xFFEC4899),
                        const Color(0xFFDB2777),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar2MakanSehatPage()),
                        ),
                      ),
                      _buildPillarCard(
                        context,
                        '3',
                        'Latihan Fisik',
                        'Aktivitas & olahraga teratur',
                        Icons.fitness_center_rounded,
                        const Color(0xFFFBBF24),
                        const Color(0xFFF59E0B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar3LatihanFisikPage()),
                        ),
                      ),
                      _buildPillarCard(
                        context,
                        '4',
                        'Pemantauan Gula Darah',
                        'Monitor rutin gula darah',
                        Icons.monitor_heart_rounded,
                        const Color(0xFFF472B6),
                        const Color(0xFFEC4899),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar4PemantauanPage()),
                        ),
                      ),
                      _buildPillarCard(
                        context,
                        '5',
                        'Penggunaan Obat',
                        'Kepatuhan minum obat',
                        Icons.medication_rounded,
                        const Color(0xFFEC4899),
                        const Color(0xFFDB2777),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar5PenggunaanObatPage()),
                        ),
                      ),
                      _buildPillarCard(
                        context,
                        '6',
                        'Pencegahan Komplikasi',
                        'Cegah komplikasi diabetes',
                        Icons.shield_rounded,
                        const Color(0xFFFBBF24),
                        const Color(0xFFF59E0B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Pilar6PencegahanKomplikasiPage()),
                        ),
                      ),
                      const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: endColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Pilar $number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 18,
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