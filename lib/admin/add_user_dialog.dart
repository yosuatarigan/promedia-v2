import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/secondary_auth.dart';

/// Menampilkan form tambah pengguna (pasien / keluarga).
/// Mengembalikan nama pengguna yang berhasil dibuat, atau null bila batal.
Future<String?> showAddUserDialog(BuildContext context,
    {required AdminProfile admin}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AddUserDialog(admin: admin),
  );
}

class _AddUserDialog extends StatefulWidget {
  final AdminProfile admin;
  const _AddUserDialog({required this.admin});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final _nama = TextEditingController();
  final _nik = TextEditingController();
  final _noHp = TextEditingController();
  final _alamat = TextEditingController();
  final _noKode = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String _role = 'pasien';
  String? _jenisKelamin;
  bool _obscure = true;
  bool _saving = false;
  bool _attempted = false;
  String? _error;

  // Info pasien yang terhubung lewat no kode (untuk akun keluarga).
  Timer? _kodeDebounce;
  bool _checkingKode = false;
  String? _linkedPasien; // nama pasien bila ditemukan
  bool _kodeChecked = false;

  @override
  void initState() {
    super.initState();
    _noKode.addListener(_onKodeChanged);
  }

  @override
  void dispose() {
    _kodeDebounce?.cancel();
    for (final c in [_nama, _nik, _noHp, _alamat, _noKode, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onKodeChanged() {
    _kodeDebounce?.cancel();
    if (_role != 'keluarga') return;
    final kode = _noKode.text.trim();
    if (kode.isEmpty) {
      setState(() {
        _kodeChecked = false;
        _linkedPasien = null;
      });
      return;
    }
    _kodeDebounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() => _checkingKode = true);
      try {
        final snap = await _firestore
            .collection('users')
            .where('noKode', isEqualTo: kode)
            .where('role', isEqualTo: 'pasien')
            .limit(1)
            .get();
        if (!mounted || _noKode.text.trim() != kode) return;
        setState(() {
          _kodeChecked = true;
          _linkedPasien = snap.docs.isEmpty
              ? null
              : (snap.docs.first.data()['namaLengkap'] ?? '-').toString();
        });
      } catch (_) {
        // Abaikan: hanya informasi pendukung.
      } finally {
        if (mounted) setState(() => _checkingKode = false);
      }
    });
  }

  void _setRole(String role) {
    if (_saving) return;
    setState(() {
      _role = role;
      _kodeChecked = false;
      _linkedPasien = null;
    });
    _onKodeChanged();
  }

  void _generatePassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final r = Random.secure();
    final pass = List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
    setState(() {
      _password.text = pass;
      _obscure = false;
    });
  }

  /// "08123…" / "+628123…" / "628123…" → "8123…"
  String _normalizePhone(String raw) {
    var p = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('62')) p = p.substring(2);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _attempted = true;
    });
    if (!_formKey.currentState!.validate()) return;
    if (_jenisKelamin == null) {
      setState(() => _error = 'Pilih jenis kelamin');
      return;
    }

    final nama = _nama.text.trim();
    final nik = _nik.text.trim();
    final noKode = _noKode.text.trim();
    final email = _email.text.trim();
    final roleLabel = _role == 'pasien' ? 'Pasien' : 'Keluarga';

    setState(() => _saving = true);
    try {
      final users = _firestore.collection('users');

      final nikTaken =
          await users.where('nik', isEqualTo: nik).limit(1).get();
      if (nikTaken.docs.isNotEmpty) {
        throw _FormError('NIK $nik sudah terdaftar atas nama '
            '${nikTaken.docs.first.data()['namaLengkap'] ?? '-'}');
      }

      final kodeTaken = await users
          .where('noKode', isEqualTo: noKode)
          .where('role', isEqualTo: _role)
          .limit(1)
          .get();
      if (kodeTaken.docs.isNotEmpty) {
        throw _FormError('No kode $noKode untuk $roleLabel sudah dipakai '
            '${kodeTaken.docs.first.data()['namaLengkap'] ?? '-'}');
      }

      final uid = await SecondaryAuth.createAccount(
        email: email,
        password: _password.text,
      );

      // Struktur dokumen sama dengan registrasi di aplikasi mobile.
      await users.doc(uid).set({
        'uid': uid,
        'nik': nik,
        'noHp': '+62${_normalizePhone(_noHp.text)}',
        'noKode': noKode,
        'namaLengkap': nama,
        'alamat': _alamat.text.trim(),
        'email': email,
        'password': _password.text,
        'jenisKelamin': _jenisKelamin,
        'role': _role,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': widget.admin.uid,
        'createdVia': 'admin_web',
      });

      if (mounted) Navigator.pop(context, nama);
    } on _FormError catch (e) {
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _saving = false;
        _error = SecondaryAuth.describeError(e);
      });
    }
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoCol = width >= 720;

    Widget pair(Widget a, Widget b) => twoCol
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 16), b]);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add_alt_1_outlined,
                color: AdminColors.primary),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tambah Pengguna'),
                SizedBox(height: 2),
                Text(
                  'Akun langsung bisa dipakai login di aplikasi Promedia.',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AdminColors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tutup',
            onPressed: _saving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AdminColors.textMuted),
          ),
        ],
      ),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          autovalidateMode: _attempted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SectionLabel('Jenis akun'),
                Row(
                  children: [
                    Expanded(
                      child: _RoleOption(
                        selected: _role == 'pasien',
                        icon: Icons.favorite_border,
                        title: 'Pasien',
                        subtitle: 'Penderita diabetes yang dipantau',
                        color: AdminColors.pasien,
                        onTap: () => _setRole('pasien'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleOption(
                        selected: _role == 'keluarga',
                        icon: Icons.family_restroom_outlined,
                        title: 'Keluarga',
                        subtitle: 'Pendamping pasien',
                        color: AdminColors.keluarga,
                        onTap: () => _setRole('keluarga'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Data diri'),
                _field(_nama, 'Nama lengkap',
                    hint: 'Sesuai KTP',
                    validator: _required('Nama lengkap')),
                const SizedBox(height: 16),
                pair(
                  _field(_nik, 'NIK',
                      hint: '16 digit NIK',
                      keyboard: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _required('NIK')),
                  DropdownButtonFormField<String>(
                    value: _jenisKelamin,
                    decoration: const InputDecoration(labelText: 'Jenis kelamin'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Laki-laki', child: Text('Laki-laki')),
                      DropdownMenuItem(
                          value: 'Perempuan', child: Text('Perempuan')),
                    ],
                    validator: (v) => v == null ? 'Pilih jenis kelamin' : null,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _jenisKelamin = v),
                  ),
                ),
                const SizedBox(height: 16),
                _field(_noHp, 'No HP',
                    hint: '81234567890',
                    keyboard: TextInputType.phone,
                    prefixText: '+62 ',
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final p = _normalizePhone(v ?? '');
                      if (p.isEmpty) return 'No HP wajib diisi';
                      if (p.length < 8) return 'No HP terlalu pendek';
                      return null;
                    }),
                const SizedBox(height: 16),
                _field(_alamat, 'Alamat',
                    maxLines: 2, validator: _required('Alamat')),
                const SizedBox(height: 24),
                const _SectionLabel('Akun login'),
                _field(_noKode, 'No kode',
                    hint: _role == 'pasien'
                        ? 'Kode unik pasien, mis. 79'
                        : 'Sama dengan no kode pasien yang didampingi',
                    helper: _role == 'pasien'
                        ? 'Dipakai pasien untuk login dan untuk menghubungkan akun keluarga.'
                        : null,
                    validator: _required('No kode')),
                if (_role == 'keluarga') _buildLinkInfo(),
                const SizedBox(height: 16),
                pair(
                  _field(_email, 'Email',
                      hint: 'nama@email.com',
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      }),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    enabled: !_saving,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Buat password acak',
                            onPressed: _saving ? null : _generatePassword,
                            icon: const Icon(Icons.auto_fix_high_outlined,
                                size: 19),
                          ),
                          IconButton(
                            tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19),
                          ),
                        ],
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimal 6 karakter'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.info.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AdminColors.info),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Di aplikasi, ${_role == 'pasien' ? 'pasien' : 'keluarga'} '
                          'login dengan memilih role ${_role == 'pasien' ? 'Pasien' : 'Keluarga'}, '
                          'lalu memasukkan no kode dan password di atas.',
                          style: const TextStyle(
                              fontSize: 13, color: AdminColors.text, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AdminColors.danger.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 18, color: AdminColors.danger),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: AdminColors.danger, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(_saving
              ? 'Menyimpan…'
              : 'Tambah ${_role == 'pasien' ? 'Pasien' : 'Keluarga'}'),
        ),
      ],
    );
  }

  Widget _buildLinkInfo() {
    if (_noKode.text.trim().isEmpty) return const SizedBox.shrink();
    Widget line(IconData icon, Color color, String text) => Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(text, style: TextStyle(fontSize: 13, color: color)),
              ),
            ],
          ),
        );
    if (_checkingKode || !_kodeChecked) {
      return line(Icons.hourglass_empty, AdminColors.textMuted,
          'Mencari pasien dengan kode ini…');
    }
    if (_linkedPasien != null) {
      return line(Icons.link, AdminColors.success,
          'Terhubung ke pasien: $_linkedPasien');
    }
    return line(Icons.warning_amber_rounded, AdminColors.warning,
        'Belum ada pasien dengan kode ini. Akun tetap bisa dibuat, dan akan terhubung otomatis saat pasiennya terdaftar.');
  }

  FormFieldValidator<String> _required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    String? helper,
    String? prefixText,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: c,
      enabled: !_saving,
      keyboardType: keyboard,
      inputFormatters: formatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        prefixText: prefixText,
      ),
    );
  }
}

class _FormError implements Exception {
  final String message;
  _FormError(this.message);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AdminColors.textSubtle,
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : AdminColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AdminColors.text)),
                  Text(subtitle,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textMuted)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? color : AdminColors.textSubtle,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
