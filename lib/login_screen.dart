import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/home_pasien_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _kodeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'pasien';

  Future<void> _login() async {
    if (_kodeController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Mohon lengkapi semua field');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Query Firestore berdasarkan noKode dan role
      final querySnapshot = await _firestore
          .collection('users')
          .where('noKode', isEqualTo: _kodeController.text)
          .where('role', isEqualTo: _selectedRole)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showError('No Kode atau Role tidak ditemukan');
        setState(() => _isLoading = false);
        return;
      }

      // Ambil email dari dokumen
      final userData = querySnapshot.docs.first.data();
      final email = userData['email'] as String;

      // Login ke Firebase Auth
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      // Navigate berdasarkan role
      if (mounted) {
        if (_selectedRole == 'pasien') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePasienScreen(),
            ),
          );
        } else {
          // Navigate ke home keluarga (ganti dengan screen yang sesuai)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePasienScreen(), // Ganti dengan HomeKeluargaScreen
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'wrong-password') {
        _showError('Password salah');
      } else if (e.code == 'user-not-found') {
        _showError('User tidak ditemukan');
      } else if (e.code == 'invalid-credential') {
        _showError('Password salah');
      } else {
        _showError('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFB3D9), Color(0xFFE8C5F5)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset('assets/18.png', height: 80),
                  ),

                  const SizedBox(height: 40),

                  // Login Card
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  'Masuk',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.black87),
                                ),
                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  'Silahkan masuk dengan no Kode dan password yang sudah terdaftar di aplikasi',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 32),

                                // Dropdown Role
                                Text(
                                  'Masuk Sebagai :',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedRole,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFFFF0F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'pasien',
                                      child: Text('Pasien'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'keluarga',
                                      child: Text('Keluarga'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRole = value!;
                                    });
                                  },
                                ),
                                const SizedBox(height: 24),

                                // No Kode Field
                                Text(
                                  'No Kode :',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _kodeController,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Nomor Kode Anda',
                                    filled: true,
                                    fillColor: const Color(0xFFFFF0F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Password Field
                                Text(
                                  'Password :',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Password Anda',
                                    filled: true,
                                    fillColor: const Color(0xFFFFF0F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Lupa Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigate to forgot password
                                    },
                                    child: Text(
                                      'Lupa Password ?',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Button Masuk
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFB83B7E),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Masuk',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Daftar Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Belum Memiliki Akun ? ',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Daftar Disini',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                        // Gambar abstrak pojok kiri bawah
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Image.asset('assets/12.png', width: 150),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}