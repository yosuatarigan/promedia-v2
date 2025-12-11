import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UbahProfilScreen extends StatefulWidget {
  const UbahProfilScreen({super.key});

  @override
  State<UbahProfilScreen> createState() => _UbahProfilScreenState();
}

class _UbahProfilScreenState extends State<UbahProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  String? selectedJenisKelamin;
  File? _imageFile;
  String? _currentPhotoUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  // Support berbagai format jenis kelamin dari database (mutable list)
  List<String> jenisKelaminOptions = [
    'Laki-laki',
    'Perempuan',
    'Pria',
    'Wanita'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists && mounted) {
        final data = userDoc.data()!;
        
        // Get jenis kelamin dari database
        String? jenisKelaminFromDb = data['jenisKelamin'];
        
        // Jika value dari database tidak ada di options, tambahkan
        if (jenisKelaminFromDb != null && 
            !jenisKelaminOptions.contains(jenisKelaminFromDb)) {
          jenisKelaminOptions.add(jenisKelaminFromDb);
        }
        
        setState(() {
          _namaController.text = data['namaLengkap'] ?? '';
          _alamatController.text = data['alamat'] ?? '';
          _noHpController.text = data['noHp'] ?? '';
          selectedJenisKelamin = jenisKelaminFromDb;
          _currentPhotoUrl = data['photoUrl'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String?> _uploadProfilePhoto() async {
    if (_imageFile == null) return _currentPhotoUrl;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;

      // Delete old photo if exists
      if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
        try {
          final oldRef = _storage.refFromURL(_currentPhotoUrl!);
          await oldRef.delete();
        } catch (e) {
          print('Error deleting old photo: $e');
        }
      }

      // Upload new photo
      final fileName = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_photos/$fileName');
      final uploadTask = await ref.putFile(_imageFile!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal upload foto: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Upload photo if changed
      final photoUrl = await _uploadProfilePhoto();

      // Update Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'namaLengkap': _namaController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'jenisKelamin': selectedJenisKelamin,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Profil Anda telah berhasil diperbarui',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to profile
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Edit Profil'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFB83B7E),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _imageFile != null
                          ? Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            )
                          : _currentPhotoUrl != null
                              ? Image.network(
                                  _currentPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFB83B7E),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFFB83B7E),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB83B7E),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap untuk ubah foto',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Nama Lengkap
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: _buildInputDecoration(
                  'Masukkan nama lengkap',
                  Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Alamat
              _buildLabel('Alamat'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alamatController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  'Masukkan alamat lengkap',
                  Icons.location_on_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // No HP
              _buildLabel('No. HP'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(
                  'Masukkan nomor HP',
                  Icons.phone_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'No. HP harus diisi';
                  }
                  if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                    return 'Format nomor HP tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Jenis Kelamin
              _buildLabel('Jenis Kelamin'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedJenisKelamin,
                decoration: _buildInputDecoration(
                  'Pilih jenis kelamin',
                  Icons.wc_outlined,
                ),
                items: jenisKelaminOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJenisKelamin = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis kelamin harus dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFB83B7E)),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB83B7E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}