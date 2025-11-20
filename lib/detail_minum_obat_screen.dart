import 'package:flutter/material.dart';

class DetailMinumObatScreen extends StatelessWidget {
  const DetailMinumObatScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Text
            const Text(
              'Berikut ini adalah list aktivitas harian Anda pada tanggal 15 Agustus 2025',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Minum Obat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 24),

            // List Minum Obat
            _buildObatItem('Minum Obat Pagi', '08.00 WIB', 'Insulin', 'Dosis : 6 Unit'),
            const SizedBox(height: 16),
            _buildObatItem('Minum Obat Siang', '14.00 WIB', 'Metformin', 'Dosis : 2 Tablet'),
            const SizedBox(height: 16),
            _buildObatItem('Minum Obat Malam', '18.30 WIB', 'Insulin', 'Dosis : 6 Unit'),
          ],
        ),
      ),
    );
  }

  Widget _buildObatItem(String title, String time, String obat, String dosis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
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
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                obat,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dosis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}