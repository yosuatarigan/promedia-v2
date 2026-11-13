import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';

/// Aksi admin pada dokumen `reminders`. Semua perubahan menyimpan jejak
/// (siapa & kapan) agar bisa ditelusuri.
class NotifActions {
  static final _db = FirebaseFirestore.instance;

  /// Ubah status dibaca untuk satu atau banyak notifikasi sekaligus.
  /// Memakai batch write (maks. 500 per batch) — tanpa pembacaan tambahan.
  static Future<void> setRead(
    Iterable<DocumentReference> refs,
    bool read,
    AdminProfile admin,
  ) async {
    final list = refs.toList();
    for (var i = 0; i < list.length; i += 450) {
      final batch = _db.batch();
      for (final ref in list.skip(i).take(450)) {
        batch.update(ref, {
          'isRead': read,
          'readAt': read ? FieldValue.serverTimestamp() : null,
          'readStatusChangedBy': admin.uid,
          'readStatusChangedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  /// Ubah tanggal & jam notifikasi. Waktu asli disimpan sekali di
  /// `originalCreatedAt`; status dibaca tidak berubah.
  static Future<void> editDate(
    DocumentSnapshot<Map<String, dynamic>> doc,
    DateTime newAt,
    AdminProfile admin,
  ) {
    final d = doc.data() ?? const {};
    return doc.reference.update({
      'createdAt': Timestamp.fromDate(newAt),
      if (d['originalCreatedAt'] == null && d['createdAt'] != null)
        'originalCreatedAt': d['createdAt'],
      'dateEditedBy': admin.uid,
      'dateEditedAt': FieldValue.serverTimestamp(),
    });
  }
}

final _fmt = DateFormat('EEEE, d MMM yyyy · HH:mm', 'id_ID');
String formatNotifDate(DateTime t) => _fmt.format(t);

/// Pilih tanggal lalu jam. Mengembalikan null bila dibatalkan.
Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
  DateTime? first,
  DateTime? last,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: first ?? DateTime(2024),
    lastDate: last ?? DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Dialog ubah tanggal & jam satu notifikasi. Mengembalikan true bila disimpan.
Future<bool?> showEditNotifDateDialog(
  BuildContext context, {
  required DocumentSnapshot<Map<String, dynamic>> doc,
  required AdminProfile admin,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _EditDateDialog(doc: doc, admin: admin),
  );
}

class _EditDateDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final AdminProfile admin;
  const _EditDateDialog({required this.doc, required this.admin});

  @override
  State<_EditDateDialog> createState() => _EditDateDialogState();
}

class _EditDateDialogState extends State<_EditDateDialog> {
  late DateTime _value;
  DateTime? _current;
  DateTime? _original;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final d = widget.doc.data() ?? const {};
    _current = (d['createdAt'] as Timestamp?)?.toDate();
    _original = (d['originalCreatedAt'] as Timestamp?)?.toDate();
    _value = _current ?? DateTime.now();
  }

  Future<void> _pick() async {
    final v = await pickDateTime(context,
        initial: _value, last: DateTime.now().add(const Duration(minutes: 1)));
    if (v != null) setState(() => _value = v);
  }

  Future<void> _save() async {
    if (_value.isAfter(DateTime.now())) {
      setState(() => _error =
          'Tanggal tidak boleh di masa depan. Gunakan "Jadwalkan" saat mengirim pengingat baru.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NotifActions.editDate(widget.doc, _value, widget.admin);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan: $e';
      });
    }
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.textMuted))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.text))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ubah tanggal & jam'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_current != null) _row('Saat ini', formatNotifDate(_current!)),
            if (_original != null)
              _row('Waktu asli', formatNotifDate(_original!)),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _saving ? null : _pick,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(formatNotifDate(_value)),
            ),
            const SizedBox(height: 12),
            Text(
              _original == null
                  ? 'Waktu asli tetap disimpan sebagai catatan. Status dibaca tidak berubah.'
                  : 'Status dibaca tidak berubah.',
              style: const TextStyle(fontSize: 12, color: AdminColors.textMuted),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AdminColors.danger)),
            ],
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Menyimpan…' : 'Simpan'),
        ),
      ],
    );
  }
}
