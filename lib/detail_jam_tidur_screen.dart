import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailJamTidurScreen extends StatefulWidget {
  const DetailJamTidurScreen({super.key});

  @override
  State<DetailJamTidurScreen> createState() => _DetailJamTidurScreenState();
}

class _DetailJamTidurScreenState extends State<DetailJamTidurScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  DateTime selectedDate = DateTime.now();
  String? noKode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }

    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    if (userDoc.exists) {
      setState(() {
        noKode = userDoc.data()?['noKode'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Stream<QuerySnapshot> _getJamTidurStream() {
    final startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('latihan_fisik_logs')
        .where('noKode', isEqualTo: noKode)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('tanggal', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('tanggal', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Jam Tidur',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );
    }

    if (noKode == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Jam Tidur',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: const Center(child: Text('Data user tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Jam Tidur',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Color(0xFFB83B7E)),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB83B7E).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month,
                        color: Color(0xFFB83B7E)),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
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
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getJamTidurStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Filter hanya yang punya data jamTidur
                final allDocs = snapshot.data?.docs ?? [];
                final docs = allDocs
                    .where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['jamTidur'] != null &&
                          (data['jamTidur'] as String).isNotEmpty;
                    })
                    .toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bedtime_outlined,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data jam tidur\npada tanggal ini',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Berikut ini adalah data jam tidur pada tanggal '
                        '${DateFormat('dd MMMM yyyy').format(selectedDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Icon(Icons.bedtime_outlined,
                              color: Color(0xFFB83B7E)),
                          const SizedBox(width: 8),
                          Text(
                            'Jam Tidur (${docs.length} catatan)',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildJamTidurItem(data),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJamTidurItem(Map<String, dynamic> data) {
    final jamTidur = data['jamTidur'] as String? ?? '-';
    final jenisOlahraga = data['jenisOlahraga'] as String? ?? '-';
    final jam = data['jam'] as String? ?? '-';
    final userName = data['userName'] as String? ?? '-';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFB83B7E).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFB83B7E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bedtime_outlined,
                  color: Color(0xFFB83B7E),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round,
                            size: 16, color: Colors.indigo),
                        const SizedBox(width: 4),
                        const Text(
                          'Jam Tidur',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$jamTidur WIB',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.fitness_center,
                            size: 14, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          'Setelah: $jenisOlahraga • $jam WIB',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(
                'Oleh: $userName',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
