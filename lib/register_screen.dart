import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  String? _selectedJenisKelamin;
  String? _selectedJenisKelaminPasien;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
              tabs: const [
                Tab(text: 'Pasien'),
                Tab(text: 'Keluarga'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPasienForm(),
                    _buildKeluargaForm(),
                  ],
                ),
                // Gambar abstrak pojok kiri bawah
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/12.png',
                    width: 150,
                  ),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  _obscurePasswordPasien ? Icons.visibility_off : Icons.visibility,
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
                    _obscureConfirmPasswordPasien = !_obscureConfirmPasswordPasien;
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
              onPressed: () {
                // Handle register pasien
              },
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              onPressed: () {
                // Handle register keluarga
              },
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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