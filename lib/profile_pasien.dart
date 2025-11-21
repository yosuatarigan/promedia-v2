import 'package:flutter/material.dart';
import 'package:promedia_v2/ubah_password.dart';
import 'package:promedia_v2/ubah_profile.dart';

class ProfilPasienScreen extends StatelessWidget {
  const ProfilPasienScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name
              const Text(
                'Alvi Riansyah',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Phone
              const Text(
                '+62-8731 7318 324',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Kode
              const Text(
                'No. Kode R25',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UbahProfilScreen(),
                              ),
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
                              child: _buildInfoCard(
                                'Data Diri',
                                [
                                  InfoItem('NIK', '32**************23123'),
                                  InfoItem('Alamat', 'Jl. Raya Cicalengka'),
                                  InfoItem('Jenis Kelamin', 'Pria'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Profil Kesehatan',
                                [
                                  InfoItem('Gula Darah Sewaktu', '220 mg/dL'),
                                  InfoItem('HbA1c', '5,6 %'),
                                  InfoItem('Olahraga', '30 menit (15 Agustus)'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 2: Riwayat Makan & Riwayat Minum Obat
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Riwayat Makan',
                                [
                                  InfoItem('Pagi (07.30 WIB)', 'Nasi Kuning (250 kal)'),
                                  InfoItem('Siang (14.30 WIB)', 'Nasi Putih (250 kal)'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Riwayat Minum Obat',
                                [
                                  InfoItem('Pagi (07.30 WIB)', 'Metformin (2 Tablet)'),
                                  InfoItem('Siang (14.30 WIB)', 'Insulin (2 Unit)'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 3: Perawatan Kaki & Manajemen Stres
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Perawatan Kaki',
                                [
                                  InfoItem('Pagi (07.30 WIB)', 'Baik'),
                                  InfoItem('Malam (19.30WIB)', 'Baik'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Manajemen Stres',
                                [
                                  InfoItem('Tekanan Darah', '140/80 mmHg'),
                                  InfoItem('Kondisi', 'Baik'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Ubah Password
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UbahPasswordScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
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
                              onPressed: () {
                                // Logout
                                _showLogoutDialog(context);
                              },
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

  Widget _buildInfoCard(String title, List<InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB83B7E),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}