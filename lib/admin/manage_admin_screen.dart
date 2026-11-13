import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/secondary_auth.dart';

/// Halaman khusus superadmin untuk mengelola akun yang bisa mengakses admin web.
class ManageAdminScreen extends StatefulWidget {
  final AdminProfile currentAdmin;
  const ManageAdminScreen({super.key, required this.currentAdmin});

  @override
  State<ManageAdminScreen> createState() => _ManageAdminScreenState();
}

class _ManageAdminScreenState extends State<ManageAdminScreen> {
  final _admins = FirebaseFirestore.instance.collection(kAdminsCollection);
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _adminsStream =
      _admins.snapshots();

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  /// Superadmin aktif selain [exceptUid]. Dipakai agar sistem tidak pernah
  /// kehilangan superadmin terakhir.
  Future<int> _otherActiveSuperadmins(String exceptUid) async {
    final snap = await _admins.where('role', isEqualTo: 'superadmin').get();
    return snap.docs
        .where((d) => d.id != exceptUid && d.data()['isActive'] != false)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Kelola Admin',
      subtitle:
          'Atur siapa saja yang bisa mengakses Admin Panel. Admin dapat mengelola '
          'pengguna dan message framing; hanya Super Admin yang dapat mengelola admin.',
      scrollable: false,
      actions: [
        ElevatedButton.icon(
          onPressed: _showAddAdmin,
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
          label: const Text('Tambah Admin'),
        ),
      ],
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _adminsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AdminCard(
              child: AdminEmptyState(
                icon: Icons.error_outline,
                title: 'Gagal memuat admin',
                message: '${snapshot.error}',
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              // Superadmin di atas, lalu urut nama
              final ra = a.data()['role'] == 'superadmin' ? 0 : 1;
              final rb = b.data()['role'] == 'superadmin' ? 0 : 1;
              if (ra != rb) return ra - rb;
              return (a.data()['namaLengkap'] ?? '')
                  .toString()
                  .toLowerCase()
                  .compareTo(
                      (b.data()['namaLengkap'] ?? '').toString().toLowerCase());
            });
          final active = docs.where((d) => d.data()['isActive'] != false).length;

          return AdminCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  child: Text(
                    '${docs.length} admin  ·  $active aktif',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AdminColors.textMuted,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: docs.isEmpty
                      ? const AdminEmptyState(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Belum ada admin',
                        )
                      : ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) =>
                              const Divider(indent: 20, endIndent: 20),
                          itemBuilder: (context, i) => _buildAdminTile(docs[i]),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final isSelf = doc.id == widget.currentAdmin.uid;
    final isSuper = data['role'] == 'superadmin';
    final isActive = data['isActive'] != false;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final nama = (data['namaLengkap'] ?? '-').toString();

    return Opacity(
      opacity: isActive ? 1 : 0.6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
        child: Row(
          children: [
            AdminAvatar(nama,
                size: 40,
                color: isSuper ? AdminColors.primaryDark : AdminColors.info),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(nama,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AdminColors.text)),
                      if (isSelf)
                        const AdminBadge('Anda', color: AdminColors.success),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      data['email'] ?? '-',
                      if (createdAt != null)
                        'ditambahkan ${DateFormat('d MMM yyyy', 'id_ID').format(createdAt)}',
                    ].join('  ·  '),
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AdminBadge.role(isSuper ? 'superadmin' : 'admin'),
            const SizedBox(width: 8),
            SizedBox(
              width: 86,
              child: Align(
                alignment: Alignment.centerLeft,
                child: isActive
                    ? const AdminBadge('Aktif',
                        color: AdminColors.success, icon: Icons.circle)
                    : const AdminBadge('Nonaktif',
                        color: AdminColors.textMuted, icon: Icons.circle),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Aksi',
              icon: const Icon(Icons.more_horiz, color: AdminColors.textMuted),
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'edit', child: Text('Edit nama & role')),
                const PopupMenuItem(
                    value: 'reset', child: Text('Kirim email reset password')),
                if (!isSelf)
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      isActive ? 'Nonaktifkan akses' : 'Aktifkan akses',
                      style: TextStyle(
                          color: isActive ? AdminColors.danger : null),
                    ),
                  ),
              ],
              onSelected: (v) {
                if (v == 'edit') _showEditAdmin(doc);
                if (v == 'reset') _sendReset(data['email']);
                if (v == 'toggle') _toggleActive(doc);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendReset(String? email) async {
    if (email == null || email.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _snack('Link reset password dikirim ke $email');
    } catch (e) {
      _snack('Gagal mengirim email: ${SecondaryAuth.describeError(e)}',
          error: true);
    }
  }

  Future<void> _toggleActive(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final isActive = data['isActive'] != false;
    if (isActive &&
        data['role'] == 'superadmin' &&
        await _otherActiveSuperadmins(doc.id) == 0) {
      _snack('Tidak bisa menonaktifkan Super Admin terakhir', error: true);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isActive ? 'Nonaktifkan Admin' : 'Aktifkan Admin'),
        content: Text(isActive
            ? '${data['namaLengkap']} tidak akan bisa login ke Admin Panel. Lanjutkan?'
            : '${data['namaLengkap']} akan bisa login kembali ke Admin Panel. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.red : kAdminPrimary),
            child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await doc.reference.update({
        'isActive': !isActive,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': widget.currentAdmin.uid,
      });
      _snack(isActive ? 'Admin dinonaktifkan' : 'Admin diaktifkan');
    } catch (e) {
      _snack('Gagal: $e', error: true);
    }
  }

  Future<void> _showEditAdmin(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data();
    final isSelf = doc.id == widget.currentAdmin.uid;
    final namaController = TextEditingController(text: data['namaLengkap']);
    String role = data['role'] ?? 'admin';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Admin'),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: data['email'],
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      helperText: 'Email login tidak dapat diubah dari web',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      helperText:
                          isSelf ? 'Anda tidak dapat mengubah role sendiri' : null,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'superadmin', child: Text('Super Admin')),
                    ],
                    onChanged: isSelf
                        ? null
                        : (v) => setDialogState(() => role = v ?? role),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (data['role'] == 'superadmin' &&
                    role != 'superadmin' &&
                    await _otherActiveSuperadmins(doc.id) == 0) {
                  _snack('Harus ada minimal satu Super Admin aktif',
                      error: true);
                  return;
                }
                try {
                  await doc.reference.update({
                    'namaLengkap': namaController.text.trim(),
                    'role': role,
                    'updatedAt': FieldValue.serverTimestamp(),
                    'updatedBy': widget.currentAdmin.uid,
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  _snack('Data admin diperbarui');
                } catch (e) {
                  _snack('Gagal menyimpan: $e', error: true);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddAdmin() async {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'admin';
    bool obscure = true;
    bool saving = false;
    String? error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setDialogState(() {
              saving = true;
              error = null;
            });
            try {
              final email = emailController.text.trim();
              final uid = await SecondaryAuth.createAccount(
                email: email,
                password: passwordController.text,
              );
              await _admins.doc(uid).set({
                'uid': uid,
                'namaLengkap': namaController.text.trim(),
                'email': email,
                'role': role,
                'isActive': true,
                'createdAt': FieldValue.serverTimestamp(),
                'createdBy': widget.currentAdmin.uid,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _snack('Admin ${namaController.text.trim()} berhasil ditambahkan');
            } catch (e) {
              setDialogState(() {
                saving = false;
                error = SecondaryAuth.describeError(e);
              });
            }
          }

          return AlertDialog(
            title: const Text('Tambah Admin'),
            content: SizedBox(
              width: 380,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration:
                            const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return 'Email wajib diisi';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Password awal',
                          helperText:
                              'Minimal 6 karakter. Admin bisa menggantinya lewat "Lupa password".',
                          helperMaxLines: 2,
                          suffixIcon: IconButton(
                            icon: Icon(obscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setDialogState(() => obscure = !obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Password minimal 6 karakter'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'superadmin', child: Text('Super Admin')),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => role = v ?? 'admin'),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(error!, style: const TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kAdminPrimary),
                onPressed: saving ? null : submit,
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tambah',
                        style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
