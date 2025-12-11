import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/home_pasien_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controllers untuk Pasien
  final _nikController = TextEditingController();
  final _noHpController = TextEditingController();
  final _noKodeController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordPasienController = TextEditingController();
  final _confirmPasswordPasienController = TextEditingController();

  // Controllers untuk Keluarga
  final _nikKeluargaController = TextEditingController();
  final _noHpKeluargaController = TextEditingController();
  final _noKodeKeluargaController = TextEditingController();
  final _namaLengkapKeluargaController = TextEditingController();
  final _alamatKeluargaController = TextEditingController();
  final _emailKeluargaController = TextEditingController();
  final _jenisKelaminController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscurePasswordPasien = true;
  bool _obscureConfirmPasswordPasien = true;
  bool _isLoading = false;
  String? _selectedJenisKelamin;
  String? _selectedJenisKelaminPasien;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Validasi NIK unik
  Future<bool> _isNikUnique(String nik) async {
    final result = await _firestore
        .collection('users')
        .where('nik', isEqualTo: nik)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  // Validasi kombinasi noKode + role unik (noKode boleh sama untuk family linking)
  Future<bool> _isNoKodeRoleUnique(String noKode, String role) async {
    final result = await _firestore
        .collection('users')
        .where('noKode', isEqualTo: noKode)
        .where('role', isEqualTo: role)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  // Register Pasien
  Future<void> _registerPasien() async {
    // Validasi form
    if (_nikController.text.isEmpty ||
        _noHpController.text.isEmpty ||
        _noKodeController.text.isEmpty ||
        _namaLengkapController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordPasienController.text.isEmpty ||
        _confirmPasswordPasienController.text.isEmpty ||
        _selectedJenisKelaminPasien == null) {
      _showError('Mohon lengkapi semua field');
      return;
    }

    // Validasi password
    if (_passwordPasienController.text != _confirmPasswordPasienController.text) {
      _showError('Password tidak cocok');
      return;
    }

    if (_passwordPasienController.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cek NIK unik
      final nikUnique = await _isNikUnique(_nikController.text);
      if (!nikUnique) {
        _showError('NIK sudah terdaftar');
        setState(() => _isLoading = false);
        return;
      }

      // Cek kombinasi noKode + role unik (noKode boleh sama untuk family linking)
      final noKodeRoleUnique = await _isNoKodeRoleUnique(_noKodeController.text, 'pasien');
      if (!noKodeRoleUnique) {
        _showError('Nomor Kode untuk Pasien sudah terdaftar');
        setState(() => _isLoading = false);
        return;
      }

      // Register ke Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordPasienController.text,
      );

      // Simpan data ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nik': _nikController.text,
        'noHp': '+62${_noHpController.text}',
        'noKode': _noKodeController.text,
        'namaLengkap': _namaLengkapController.text,
        'alamat': _alamatController.text,
        'email': _emailController.text.trim(),
        'jenisKelamin': _selectedJenisKelaminPasien,
        'role': 'pasien',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // Navigate ke home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePasienScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'email-already-in-use') {
        _showError('Email sudah terdaftar');
      } else if (e.code == 'invalid-email') {
        _showError('Format email tidak valid');
      } else if (e.code == 'weak-password') {
        _showError('Password terlalu lemah');
      } else {
        _showError('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Terjadi kesalahan: $e');
    }
  }

  // Register Keluarga
  Future<void> _registerKeluarga() async {
    // Validasi form
    if (_nikKeluargaController.text.isEmpty ||
        _noHpKeluargaController.text.isEmpty ||
        _noKodeKeluargaController.text.isEmpty ||
        _namaLengkapKeluargaController.text.isEmpty ||
        _alamatKeluargaController.text.isEmpty ||
        _emailKeluargaController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedJenisKelamin == null) {
      _showError('Mohon lengkapi semua field');
      return;
    }

    // Validasi password
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Password tidak cocok');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cek NIK unik
      final nikUnique = await _isNikUnique(_nikKeluargaController.text);
      if (!nikUnique) {
        _showError('NIK sudah terdaftar');
        setState(() => _isLoading = false);
        return;
      }

      // Cek kombinasi noKode + role unik (noKode boleh sama untuk family linking)
      final noKodeRoleUnique = await _isNoKodeRoleUnique(_noKodeKeluargaController.text, 'keluarga');
      if (!noKodeRoleUnique) {
        _showError('Nomor Kode untuk Keluarga sudah terdaftar');
        setState(() => _isLoading = false);
        return;
      }

      // Register ke Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailKeluargaController.text.trim(),
        password: _passwordController.text,
      );

      // Simpan data ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'nik': _nikKeluargaController.text,
        'noHp': '+62${_noHpKeluargaController.text}',
        'noKode': _noKodeKeluargaController.text,
        'namaLengkap': _namaLengkapKeluargaController.text,
        'alamat': _alamatKeluargaController.text,
        'email': _emailKeluargaController.text.trim(),
        'jenisKelamin': _selectedJenisKelamin,
        'role': 'keluarga',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (e.code == 'email-already-in-use') {
        _showError('Email sudah terdaftar');
      } else if (e.code == 'invalid-email') {
        _showError('Format email tidak valid');
      } else if (e.code == 'weak-password') {
        _showError('Password terlalu lemah');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daftar',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFB83B7E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black38,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  tabs: const [Tab(text: 'Pasien'), Tab(text: 'Keluarga')],
                ),
              ),

              // Tab Bar View
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      children: [_buildPasienForm(), _buildKeluargaForm()],
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

  Widget _buildPasienForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Silahkan lengkapi form dibawah ini untuk mendaftar aplikasi Program Manajemen Edukasi Diabetes',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // NIK
          _buildLabel('NIK :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nikController,
            hint: 'Masukan NIK Anda',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // No HP
          _buildLabel('No HP :'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB83B7E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+62',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _noHpController,
                  hint: 'Masukan No HP Anda',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // No Kode
          _buildLabel('No Kode :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _noKodeController,
            hint: 'Masukan no Kode Anda',
          ),
          const SizedBox(height: 16),

          // Nama Lengkap
          _buildLabel('Nama Lengkap :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _namaLengkapController,
            hint: 'Masukan Nama Lengkap Anda',
          ),
          const SizedBox(height: 16),

          // Alamat Tempat Tinggal
          _buildLabel('Alamat Tempat Tinggal :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _alamatController,
            hint: 'Masukan Alamat Anda',
          ),
          const SizedBox(height: 16),

          // Email
          _buildLabel('Masukan Alamat Email :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'Masukan Alamat Email Anda',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _buildLabel('Jenis Kelamin :'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedJenisKelaminPasien,
            decoration: InputDecoration(
              hintText: 'Pilih Jenis Kelamin',
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
              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedJenisKelaminPasien = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Password
          _buildLabel('Password :'),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordPasienController,
            obscureText: _obscurePasswordPasien,
            decoration: InputDecoration(
              hintText: 'Masukan Password Anda',
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
                  _obscurePasswordPasien
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePasswordPasien = !_obscurePasswordPasien;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Konfirmasi Password
          _buildLabel('Konfirmasi Password Anda :'),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordPasienController,
            obscureText: _obscureConfirmPasswordPasien,
            decoration: InputDecoration(
              hintText: 'Masukan Kembali Password Anda',
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
                  _obscureConfirmPasswordPasien
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPasswordPasien =
                        !_obscureConfirmPasswordPasien;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Button Daftar
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerPasien,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB83B7E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildKeluargaForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Silahkan lengkapi form dibawah ini untuk mendaftar aplikasi Program Manajemen Edukasi Diabetes',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // NIK
          _buildLabel('NIK :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nikKeluargaController,
            hint: 'Masukan NIK Anda',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // No HP
          _buildLabel('No HP :'),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFB83B7E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+62',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  controller: _noHpKeluargaController,
                  hint: 'Masukan No HP Anda',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // No Kode
          _buildLabel('No Kode :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _noKodeKeluargaController,
            hint: 'Masukan no Kode Anda',
          ),
          const SizedBox(height: 16),

          // Nama Lengkap
          _buildLabel('Nama Lengkap :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _namaLengkapKeluargaController,
            hint: 'Masukan Nama Lengkap Anda',
          ),
          const SizedBox(height: 16),

          // Alamat Tempat Tinggal
          _buildLabel('Alamat Tempat Tinggal :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _alamatKeluargaController,
            hint: 'Masukan Alamat Anda',
          ),
          const SizedBox(height: 16),

          // Email
          _buildLabel('Masukan Alamat Email :'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailKeluargaController,
            hint: 'Masukan Alamat Email Anda',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Jenis Kelamin
          _buildLabel('Jenis Kelamin :'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedJenisKelamin,
            decoration: InputDecoration(
              hintText: 'Pilih Jenis Kelamin',
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
              DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
              DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedJenisKelamin = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Password
          _buildLabel('Password :'),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Masukan Password Anda',
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
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
          const SizedBox(height: 16),

          // Konfirmasi Password
          _buildLabel('Konfirmasi Password Anda :'),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              hintText: 'Masukan Kembali Password Anda',
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
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Button Daftar
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerKeluarga,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB83B7E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nikController.dispose();
    _noHpController.dispose();
    _noKodeController.dispose();
    _namaLengkapController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _passwordPasienController.dispose();
    _confirmPasswordPasienController.dispose();
    _nikKeluargaController.dispose();
    _noHpKeluargaController.dispose();
    _noKodeKeluargaController.dispose();
    _namaLengkapKeluargaController.dispose();
    _alamatKeluargaController.dispose();
    _emailKeluargaController.dispose();
    _jenisKelaminController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}