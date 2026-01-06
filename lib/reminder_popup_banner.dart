import 'package:flutter/material.dart';

class ReminderPopupBanner extends StatelessWidget {
  final String activityType;
  final String title;
  final String subtitle;
  final VoidCallback onMulaSekarang;
  final VoidCallback onTunda;
  final VoidCallback onDismiss;

  const ReminderPopupBanner({
    super.key,
    required this.activityType,
    required this.title,
    required this.subtitle,
    required this.onMulaSekarang,
    required this.onTunda,
    required this.onDismiss,
  });

  IconData _getActivityIcon() {
    switch (activityType) {
      case 'makan':
        return Icons.restaurant;
      case 'minum_obat':
        return Icons.medication;
      case 'perawatan_kaki':
        return Icons.health_and_safety;
      case 'manajemen_stress':
        return Icons.psychology;
      case 'latihan_fisik':
        return Icons.fitness_center;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor() {
    switch (activityType) {
      case 'makan':
        return Colors.orange;
      case 'minum_obat':
        return Colors.blue;
      case 'perawatan_kaki':
        return Colors.green;
      case 'manajemen_stress':
        return Colors.purple;
      case 'latihan_fisik':
        return Colors.deepOrange;
      default:
        return const Color(0xFFB83B7E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.pink.shade300,
            Colors.red.shade300,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon & Close Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade500, Colors.pink.shade700],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTunda,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.pink.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tunda 10 menit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onMulaSekarang,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Mula Sekarang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Activity Icon (small, bottom)
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getActivityIcon(),
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.medication,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}