import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/reminder_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final ReminderService _reminderService = ReminderService();
  final _auth = FirebaseAuth.instance;

  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  IconData _getIconByType(String type) {
    switch (type) {
      case 'makan':
        return Icons.restaurant;
      case 'minum_obat':
        return Icons.medication;
      case 'perawatan_kaki':
        return Icons.health_and_safety;
      case 'manajemen_stress':
        return Icons.self_improvement;
      case 'latihan_fisik':
        return Icons.fitness_center;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'makan':
        return const Color(0xFFB83B7E);
      case 'minum_obat':
        return Colors.blue;
      case 'perawatan_kaki':
        return Colors.green;
      case 'manajemen_stress':
        return Colors.purple;
      case 'latihan_fisik':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFB83B7E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            'Notifikasi',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black87,
                ),
          ),
        ),
        body: const Center(
          child: Text('Silakan login terlebih dahulu'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFB83B7E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Notifikasi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reminderService.getRemindersForCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          final reminders = snapshot.data!.docs;

          // Group reminders by date
          final today = <QueryDocumentSnapshot>[];
          final older = <QueryDocumentSnapshot>[];
          final now = DateTime.now();

          for (var doc in reminders) {
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = data['createdAt'] as Timestamp?;
            
            if (createdAt != null) {
              final date = createdAt.toDate();
              if (date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day) {
                today.add(doc);
              } else {
                older.add(doc);
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Hari Ini
                if (today.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionDivider('Hari Ini'),
                  const SizedBox(height: 24),
                  ...today.map((doc) => _buildReminderItem(doc)),
                ],

                // Sebelumnya
                if (older.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionDivider('Sebelumnya'),
                  const SizedBox(height: 24),
                  ...older.map((doc) => _buildReminderItem(doc)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: DashedLinePainter(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: CustomPaint(
            painter: DashedLinePainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] ?? '';
    final message = data['message'] ?? '';
    final fromUserName = data['fromUserName'] ?? 'Keluarga';
    final isRead = data['isRead'] ?? false;
    final createdAt = data['createdAt'] as Timestamp?;

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _reminderService.deleteReminder(doc.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () async {
          if (!isRead) {
            await _reminderService.markAsRead(doc.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFFFF5F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead
                  ? Colors.grey.shade200
                  : const Color(0xFFB83B7E).withOpacity(0.3),
            ),
            boxShadow: [
              if (!isRead)
                BoxShadow(
                  color: const Color(0xFFB83B7E).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorByType(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconByType(type),
                  color: _getColorByType(type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pengingat dari $fromUserName',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB83B7E),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getTimeAgo(createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}