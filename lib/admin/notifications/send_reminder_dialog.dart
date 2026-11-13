import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/notifications/notif_actions.dart';
import 'package:promedia_v2/admin/notifications/scheduled_reminders.dart';
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

/// Mengembalikan pesan hasil (untuk snackbar) bila terkirim / terjadwal.
/// [keluarga]: keluarga pasien yang bisa dipilih sebagai pengirim.
Future<String?> showSendReminderDialog(
  BuildContext context, {
  required NotifTarget target,
  required AdminProfile admin,
  List<NotifTarget> keluarga = const [],
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _SendReminderDialog(target: target, admin: admin, keluarga: keluarga),
  );
}

class _SendReminderDialog extends StatefulWidget {
  final NotifTarget target;
  final AdminProfile admin;
  final List<NotifTarget> keluarga;
  const _SendReminderDialog(
      {required this.target, required this.admin, required this.keluarga});

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

  /// null = dikirim sebagai Admin Promedia; selain itu uid keluarga.
  String? _asUid;

  /// null = sekarang; selain itu tanggal & jam pilihan
  /// (lampau → tercatat dengan tanggal itu, masa depan → dijadwalkan).
  DateTime? _at;

  bool get _isPasien => widget.target.role == 'pasien';
  NotifTarget? get _asKeluarga => _asUid == null
      ? null
      : widget.keluarga.where((k) => k.uid == _asUid).firstOrNull;
  bool get _onBehalf => _asKeluarga != null;
  bool get _canPopup => _isPasien && _type != 'umum' && !_onBehalf;
  bool get _scheduled =>
      _at != null && _at!.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  List<String> get _types =>
      _onBehalf ? _sendableTypes.where((t) => t != 'umum').toList() : _sendableTypes;

  Future<void> _pickAt() async {
    final v = await pickDateTime(context,
        initial: _at ?? DateTime.now().add(const Duration(hours: 1)));
    if (v != null) setState(() => _at = v);
  }

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
      final kel = _asKeluarga;
      final Map<String, dynamic> payload;
      if (kel != null) {
        // Tampil di aplikasi persis seperti pengingat dari keluarga
        // (pop-up aktif). Jejak admin hanya terlihat di Admin Panel.
        payload = {
          'toUserId': widget.target.uid,
          'noKode': widget.target.noKode,
          'type': _type,
          'message': _message.text.trim(),
          'fromAdmin': false,
          'fromUserId': kel.uid,
          'fromUserName': kel.nama,
          'sentOnBehalf': true,
          'actingAdminUid': widget.admin.uid,
          'actingAdminName': widget.admin.nama,
          'isRead': false,
          'createdVia': 'admin_web_on_behalf',
        };
      } else {
        final popup = _canPopup && _popup;
        payload = {
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
          'createdVia': 'admin_web',
        };
      }

      final String result;
      if (_scheduled) {
        await ScheduledReminders.schedule(
          payload: payload,
          sendAt: _at!,
          adminUid: widget.admin.uid,
          adminName: widget.admin.nama,
        );
        result = 'Pengingat dijadwalkan ${formatNotifDate(_at!)}';
      } else {
        await FirebaseFirestore.instance.collection('reminders').add({
          ...payload,
          'createdAt': _at == null
              ? FieldValue.serverTimestamp()
              : Timestamp.fromDate(_at!),
          if (_at != null) 'backdatedBy': widget.admin.uid,
        });
        result = 'Pengingat terkirim ke ${widget.target.nama}';
      }
      if (mounted) Navigator.pop(context, result);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e is FirebaseException && e.code == 'permission-denied'
            ? 'Akses ditolak server. Pastikan akun admin masih aktif, lalu coba lagi.'
            : 'Gagal ${_scheduled ? 'menjadwalkan' : 'mengirim'}: $e';
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
                if (_isPasien && widget.keluarga.isNotEmpty) ...[
                  _sectionLabel('DIKIRIM SEBAGAI'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _choice(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Admin Promedia',
                        selected: _asUid == null,
                        onTap: () => setState(() => _asUid = null),
                      ),
                      for (final k in widget.keluarga)
                        _choice(
                          icon: Icons.family_restroom,
                          label: k.nama,
                          selected: _asUid == k.uid,
                          onTap: () => setState(() {
                            _asUid = k.uid;
                            if (_type == 'umum') _setType('makan');
                          }),
                        ),
                    ],
                  ),
                  if (_onBehalf) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Pasien melihatnya sebagai pengingat dari ${_asKeluarga!.nama} (tampil sebagai pop-up). '
                      'Keterangan "dikirim admin atas nama" hanya terlihat di Admin Panel.',
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textMuted, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
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
                    for (final key in _types)
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
                _sectionLabel('WAKTU'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _choice(
                      icon: Icons.bolt_outlined,
                      label: 'Sekarang',
                      selected: _at == null,
                      onTap: () => setState(() => _at = null),
                    ),
                    _choice(
                      icon: Icons.event_outlined,
                      label: _at == null
                          ? 'Pilih tanggal & jam'
                          : formatNotifDate(_at!),
                      selected: _at != null,
                      onTap: _pickAt,
                    ),
                  ],
                ),
                if (_at != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _scheduled
                        ? 'Dijadwalkan: dikirim otomatis satu kali pada waktu tersebut.'
                        : 'Waktu lampau: notifikasi langsung masuk dan tercatat dengan tanggal ini.',
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: _scheduled ? AdminColors.info : AdminColors.textMuted),
                  ),
                ],
                const SizedBox(height: 16),
                if (_onBehalf)
                  const SizedBox.shrink()
                else if (_isPasien)
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
          label: Text(_saving
              ? 'Menyimpan…'
              : _scheduled
                  ? 'Jadwalkan'
                  : 'Kirim'),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AdminColors.textSubtle));

  Widget _choice({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      _TypeChip(
        type: ReminderType(label, icon, AdminColors.primary),
        selected: selected,
        onTap: _saving ? null : onTap,
      );
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
