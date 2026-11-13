import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/promedia_api.dart';

const _labels = {
  'food_logs': 'Catatan makan',
  'medication_logs': 'Catatan obat',
  'foot_care_logs': 'Catatan perawatan kaki',
  'stress_management_logs': 'Catatan manajemen stress',
  'latihan_fisik_logs': 'Catatan latihan fisik',
  'aktivitas_tidur_logs': 'Catatan tidur',
  'blood_sugar_logs': 'Catatan gula darah',
  'glucose_logs': 'Catatan glukosa',
  'hba1c_logs': 'Catatan HbA1c',
  'chat_messages': 'Pesan chat',
  'reminders (diterima)': 'Notifikasi diterima',
  'reminders (dikirim)': 'Notifikasi dikirim',
  'reminders (noKode, belum terdaftar)': 'Notifikasi untuk no kode ini',
};

/// Dialog hapus pengguna: nonaktifkan akun (bisa dipulihkan) atau hapus
/// permanen beserta seluruh datanya (lewat layanan Promedia di VPS).
/// Mengembalikan pesan hasil bila ada perubahan.
Future<String?> showDeleteUserDialog(BuildContext context, DocumentSnapshot doc) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeleteUserDialog(doc: doc),
  );
}

class _DeleteUserDialog extends StatefulWidget {
  final DocumentSnapshot doc;
  const _DeleteUserDialog({required this.doc});

  @override
  State<_DeleteUserDialog> createState() => _DeleteUserDialogState();
}

enum _Mode { choose, disable, delete }

class _DeleteUserDialogState extends State<_DeleteUserDialog> {
  _Mode _mode = _Mode.choose;
  bool _busy = false;
  String? _error;
  Future<Map<String, dynamic>>? _preview;
  final _confirm = TextEditingController();

  Map<String, dynamic> get _data => widget.doc.data() as Map<String, dynamic>;
  String get _nama => (_data['namaLengkap'] ?? '-').toString();
  String get _role => (_data['role'] ?? '-').toString();
  bool get _disabled => _data['accountDisabled'] == true;

  @override
  void initState() {
    super.initState();
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final msg = await action();
      if (mounted) Navigator.pop(context, msg);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      title: Row(
        children: [
          AdminAvatar(_nama,
              size: 44,
              color: _role == 'keluarga' ? AdminColors.keluarga : AdminColors.pasien),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (_mode) {
                  _Mode.choose => 'Hapus atau nonaktifkan?',
                  _Mode.disable => _disabled ? 'Aktifkan kembali akun' : 'Nonaktifkan akun',
                  _Mode.delete => 'Hapus permanen',
                }),
                const SizedBox(height: 2),
                Text('$_nama  ·  ${_role == 'keluarga' ? 'Keluarga' : 'Pasien'}  ·  Kode ${_data['noKode'] ?? '-'}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w400, color: AdminColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AdminColors.textMuted),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mode == _Mode.choose) ..._buildChoose(),
              if (_mode == _Mode.disable) _buildDisable(),
              if (_mode == _Mode.delete) _buildDelete(),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AdminColors.danger, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: _buildActions(),
    );
  }

  List<Widget> _buildChoose() => [
        _OptionCard(
          icon: _disabled ? Icons.lock_open_outlined : Icons.block_outlined,
          color: AdminColors.warning,
          title: _disabled ? 'Aktifkan kembali akun' : 'Nonaktifkan akun',
          subtitle: _disabled
              ? 'Akun ini sedang nonaktif. Aktifkan agar bisa login lagi.'
              : 'Pengguna tidak bisa login. Semua data tetap tersimpan dan akun bisa diaktifkan kembali kapan saja.',
          onTap: () => setState(() => _mode = _Mode.disable),
        ),
        const SizedBox(height: 10),
        _OptionCard(
          icon: Icons.delete_forever_outlined,
          color: AdminColors.danger,
          title: 'Hapus permanen',
          subtitle:
              'Akun login, profil, ${_role == 'pasien' ? 'semua catatan aktivitas, chat, ' : ''}dan notifikasinya dihapus. Tidak bisa dibatalkan.',
          onTap: () => setState(() {
            _mode = _Mode.delete;
            _preview = PromediaApi.deletePreview(widget.doc.id);
          }),
        ),
      ];

  Widget _buildDisable() => Text(
        _disabled
            ? '$_nama akan bisa login kembali ke aplikasi dengan no kode dan password yang sama.'
            : '$_nama tidak akan bisa login ke aplikasi, dan sesi yang sedang aktif akan diputus. '
                'Data profil, catatan, dan notifikasi tetap tersimpan.',
        style: const TextStyle(height: 1.5),
      );

  Widget _buildDelete() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _preview,
      builder: (context, snap) {
        Widget body;
        if (snap.connectionState != ConnectionState.done) {
          body = const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snap.hasError) {
          body = Text('Gagal menghitung data: ${snap.error}',
              style: const TextStyle(color: AdminColors.danger));
        } else {
          final counts = (snap.data!['counts'] as Map?)?.cast<String, dynamic>() ?? {};
          final fmt = NumberFormat.decimalPattern('id_ID');
          body = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Yang akan dihapus permanen:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _row('Akun login & profil pengguna', '1'),
              for (final e in counts.entries)
                _row(_labels[e.key] ?? e.key, fmt.format(e.value)),
              if (_role == 'keluarga')
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Catatan aktivitas pasien yang didampingi tidak ikut terhapus.',
                      style: TextStyle(fontSize: 12, color: AdminColors.textMuted)),
                ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AdminColors.danger.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.danger.withOpacity(0.25)),
              ),
              child: body,
            ),
            const SizedBox(height: 16),
            const Text('Ketik HAPUS untuk mengonfirmasi',
                style: TextStyle(fontSize: 13, color: AdminColors.textMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _confirm,
              enabled: !_busy,
              decoration: const InputDecoration(hintText: 'HAPUS'),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            const Icon(Icons.remove_circle_outline, size: 16, color: AdminColors.danger),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );

  List<Widget> _buildActions() {
    final back = OutlinedButton(
      onPressed: _busy
          ? null
          : () => _mode == _Mode.choose
              ? Navigator.pop(context)
              : setState(() {
                  _mode = _Mode.choose;
                  _error = null;
                  _confirm.clear();
                }),
      child: Text(_mode == _Mode.choose ? 'Batal' : 'Kembali'),
    );
    Widget spinner() => const SizedBox(
        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));

    switch (_mode) {
      case _Mode.choose:
        return [back];
      case _Mode.disable:
        return [
          back,
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.warning),
            onPressed: _busy
                ? null
                : () => _run(() async {
                      await PromediaApi.setDisabled(widget.doc.id, !_disabled);
                      return _disabled
                          ? 'Akun $_nama diaktifkan kembali'
                          : 'Akun $_nama dinonaktifkan';
                    }),
            icon: _busy ? spinner() : Icon(_disabled ? Icons.lock_open : Icons.block, size: 18),
            label: Text(_disabled ? 'Aktifkan' : 'Nonaktifkan'),
          ),
        ];
      case _Mode.delete:
        final ok = _confirm.text.trim().toUpperCase() == 'HAPUS';
        return [
          back,
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: _busy || !ok
                ? null
                : () => _run(() async {
                      await PromediaApi.deleteUser(widget.doc.id);
                      return '$_nama dan seluruh datanya dihapus permanen';
                    }),
            icon: _busy ? spinner() : const Icon(Icons.delete_forever, size: 18),
            label: const Text('Hapus permanen'),
          ),
        ];
    }
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AdminColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
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
                      style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: AdminColors.textMuted, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AdminColors.textSubtle),
          ],
        ),
      ),
    );
  }
}
