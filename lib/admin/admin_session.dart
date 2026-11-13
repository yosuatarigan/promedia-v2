import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_login_screen.dart';
import 'package:promedia_v2/admin_dashboard.dart';

const kAdminPrimary = Color(0xFFB83B7E);

/// Koleksi Firestore berisi akun yang boleh mengakses admin web.
/// Dokumen: admins/{uid} { uid, namaLengkap, email, role, isActive, createdAt, createdBy }
/// role: 'superadmin' | 'admin'
const kAdminsCollection = 'admins';

class AdminProfile {
  final String uid;
  final String email;
  final String nama;
  final String role;

  const AdminProfile({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
  });

  bool get isSuperadmin => role == 'superadmin';

  String get roleLabel => isSuperadmin ? 'Super Admin' : 'Admin';

  static AdminProfile? fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    final role = data['role'];
    if (data['isActive'] == false) return null;
    if (role != 'admin' && role != 'superadmin') return null;
    return AdminProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      nama: data['namaLengkap'] ?? data['email'] ?? 'Admin',
      role: role,
    );
  }
}

/// Pintu masuk admin web: belum login → halaman login,
/// login tapi bukan admin aktif → akses ditolak, admin → dashboard.
/// Data admin didengarkan secara live, jadi admin yang dinonaktifkan
/// langsung kehilangan akses.
class AdminAuthGate extends StatelessWidget {
  const AdminAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final user = authSnap.data;
        if (user == null) return const AdminLoginScreen();

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection(kAdminsCollection)
              .doc(user.uid)
              .snapshots(),
          builder: (context, adminSnap) {
            if (adminSnap.hasError) {
              return _AccessDenied(
                message: 'Gagal memeriksa akses admin: ${adminSnap.error}',
              );
            }
            if (!adminSnap.hasData) return const _Loading();
            final admin = AdminProfile.fromDoc(adminSnap.data!);
            if (admin == null) {
              return _AccessDenied(
                message:
                    'Akun ${user.email ?? ''} tidak memiliki akses ke Admin Panel, '
                    'atau akses admin sudah dinonaktifkan.',
              );
            }
            return AdminDashboardScreen(key: ValueKey(admin.uid), admin: admin);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAdminPrimary),
        ),
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final String message;
  const _AccessDenied({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: kAdminPrimary),
                const SizedBox(height: 16),
                const Text(
                  'Akses ditolak',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Kembali ke Login',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
