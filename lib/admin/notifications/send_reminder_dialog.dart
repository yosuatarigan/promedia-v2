import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/notifications/user_notifications.dart';

/// Jenis yang bisa dikirim admin. Jenis aktivitas bisa tampil sebagai pop-up
/// di aplikasi pasien (tombol "Mulai sekarang" membuka layar aktivitasnya).
const _sendableTypes = [
  'makan',
  'minum_obat',
  'latihan_fisik',
  'perawatan_kaki',
  'manajemen_stress',
  'umum',
];

const _templates = {
  'makan': 'Jangan lupa makan sesuai jadwal dan catat menu makan Anda hari ini ya! 🍽️',
  'minum_obat': 'Jangan lupa minum obat sesuai dosis dan jadwal ya! 💊',
  'latihan_fisik':
      'Ayo luangkan 30 menit untuk aktivitas fisik hari ini, misalnya jalan kaki. 🚶',
  'perawatan_kaki':
      'Jangan lupa periksa dan rawat kaki Anda hari ini, lalu catat di aplikasi ya! 🦶',
  'manajemen_stress':
      'Luangkan waktu sejenak untuk relaksasi dan catat perasaan Anda hari ini ya. 🧘',
  'umum': '',
};

/// Mengembalikan true bila terkirim.
Future<bool?> showSendReminderDialog(
  BuildContext context, {
  required NotifTarget target,
  required AdminProfile admin,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _SendReminderDialog(target: target, admin: admin),
  );
}

class _SendReminderDialog extends StatefulWidget {
  final NotifTarget target;
  final AdminProfile admin;
  const _SendReminderDialog({required this.target, required this.admin});

  @override
  State<_SendReminderDialog> createState() => _SendReminderDialogState();
}

class _SendReminderDialogState extends State<_SendReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController(text: _templates['makan']);
  String _type = 'makan';
  bool _popup = true;
  bool _saving = false;
  String? _error;

  bool get _isPasien => widget.target.role == 'pasien';
  bool get _canPopup => _isPasien && _type != 'umum';

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      // Ganti isi pesan hanya bila masih berupa template bawaan / kosong.
      final current = _message.text.trim();
      if (current.isEmpty || _templates.values.contains(current)) {
        _message.text = _templates[type] ?? '';
      }
      _type = type;
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final popup = _canPopup && _popup;
      await FirebaseFirestore.instance.collection('reminders').add({
        'toUserId': widget.target.uid,
        'noKode': widget.target.noKode,
        'type': _type,
        'message': _message.text.trim(),
        // Aplikasi pasien hanya menampilkan pop-up untuk reminder yang
        // fromAdmin == false. `sentByAdmin` menandai asal sebenarnya.
        'fromAdmin': !popup,
        'sentByAdmin': true,
        'fromUserId': widget.admin.uid,
        'fromUserName': 'Admin Promedia',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'createdVia': 'admin_web',
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Gagal mengirim: $e';
      });
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AdminColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_outlined,
                color: AdminColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kirim Pengingat'),
                const SizedBox(height: 2),
                Text('Kepada ${widget.target.nama}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AdminColors.textMuted)),
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
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('JENIS PENGINGAT',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AdminColors.textSubtle)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final key in _sendableTypes)
                      _TypeChip(
                        type: reminderTypeOf(key),
                        selected: _type == key,
                        onTap: _saving ? null : () => _setType(key),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _message,
                  enabled: !_saving,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Pesan',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Pesan tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 4),
                if (_isPasien)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AdminColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SwitchListTile(
                      value: _canPopup && _popup,
                      onChanged: _canPopup && !_saving
                          ? (v) => setState(() => _popup = v)
                          : null,
                      activeColor: AdminColors.primary,
                      title: const Text('Tampilkan sebagai pop-up',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _canPopup
                            ? 'Muncul di beranda aplikasi pasien dengan tombol "Mulai sekarang" yang membuka layar ${reminderTypeOf(_type).label.toLowerCase()}.'
                            : 'Pesan admin hanya masuk ke daftar notifikasi pasien.',
                        style: const TextStyle(
                            fontSize: 12, color: AdminColors.textMuted),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: AdminColors.warning),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Aplikasi keluarga saat ini belum memiliki layar notifikasi, '
                            'jadi pesan ini tersimpan tetapi belum terlihat oleh keluarga.',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: AdminColors.danger)),
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
          onPressed: _saving ? null : _send,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(_saving ? 'Mengirim…' : 'Kirim'),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ReminderType type;
  final bool selected;
  final VoidCallback? onTap;

  const _TypeChip({required this.type, required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? type.color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? type.color : AdminColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 18, color: type.color),
            const SizedBox(width: 8),
            Text(type.label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? type.color : AdminColors.text)),
          ],
        ),
      ),
    );
  }
}
