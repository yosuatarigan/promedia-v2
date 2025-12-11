import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/home_keluarga_screen.dart';
import 'package:promedia_v2/login_screen.dart';
import 'package:promedia_v2/home_pasien_screen.dart';
// import 'package:promedia_v2/home_keluarga_screen.dart'; // Uncomment jika sudah ada

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
              ),
            ),
          );
        }

        // Jika user tidak login
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Jika user sudah login, check role
        return _RoleBasedHome(user: snapshot.data!);
      },
    );
  }
}

class _RoleBasedHome extends StatelessWidget {
  final User user;

  const _RoleBasedHome({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
              ),
            ),
          );
        }

        // Error state
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi kesalahan saat mengambil data user',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get user role
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final role = userData['role'] as String?;

        // Navigate based on role
        if (role == 'pasien') {
          return const HomePasienScreen();
        } else if (role == 'keluarga') {
          // Return HomeKeluargaScreen() jika sudah dibuat
          // Sementara pakai HomePasienScreen sebagai placeholder
          return const HomeKeluargaScreen(); // Ganti dengan: return const HomeKeluargaScreen();
        } else {
          // Role tidak valid
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 60, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Role user tidak valid',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB83B7E),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}