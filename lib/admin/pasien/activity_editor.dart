import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/pasien/activity_config.dart';

/// Identitas pasien pemilik catatan.
class PasienRef {
  final String uid;
  final String nama;
  final String noKode;
  const PasienRef({required this.uid, required this.nama, required this.noKode});
}

DateTime? activityDate(ActivityConfig c, Map<String, dynamic> d) =>
    (d[c.dateKey] as Timestamp?)?.toDate();

String formatActivityDate(ActivityConfig c, Map<String, dynamic> d) {
  final t = activityDate(c, d);
  if (t == null) return '-';
  final date = DateFormat('d MMM yyyy', 'id_ID').format(t);
  if (!c.dateHasTime) return date;
  final jam = c.timeKey != null ? (d[c.timeKey] as String?) : null;
  return '$date, ${jam ?? DateFormat('HH:mm').format(t)}';
}

// ───────────────────────── Form tambah / edit ─────────────────────────

/// Mengembalikan true bila tersimpan.
Future<bool?> showActivityEditor(
  BuildContext context, {
  required ActivityConfig config,
  required PasienRef pasien,
  required AdminProfile admin,
  DocumentSnapshot? doc,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ActivityEditor(
        config: config, pasien: pasien, admin: admin, doc: doc),
  );
}

class _ActivityEditor extends StatefulWidget {
  final ActivityConfig config;
  final PasienRef pasien;
  final AdminProfile admin;
  final DocumentSnapshot? doc;

  const _ActivityEditor({
    required this.config,
    required this.pasien,
    required this.admin,
    this.doc,
  });

  @override
  State<_ActivityEditor> createState() => _ActivityEditorState();
}

class _ActivityEditorState extends State<_ActivityEditor> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, dynamic> _orig;
  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, String?> _choice = {};
  late DateTime _date;
  late TimeOfDay _time;
  bool _saving = false;
  bool _attempted = false;
  String? _error;

  ActivityConfig get c => widget.config;
  bool get _isEdit => widget.doc != null;

  @override
  void initState() {
    super.initState();
    _orig = (widget.doc?.data() as Map<String, dynamic>?) ?? {};
    final t = activityDate(c, _orig) ?? DateTime.now();
    _date = DateTime(t.year, t.month, t.day);
    final jam = c.timeKey != null ? _orig[c.timeKey] as String? : null;
    _time = _parseTime(jam) ?? TimeOfDay.fromDateTime(t);

    for (final f in c.fields) {
      final v = _orig[f.key];
      switch (f.kind) {
        case FieldKind.choice:
          _choice[f.key] = v?.toString();
          break;
        case FieldKind.stringList:
          _ctrl[f.key] = TextEditingController(
              text: v is List ? v.map((e) => e.toString()).join('\n') : '');
          break;
        case FieldKind.number:
        case FieldKind.integer:
          _ctrl[f.key] = TextEditingController(text: v == null ? '' : fmtNum(v, decimals: 2));
          break;
        default:
          _ctrl[f.key] = TextEditingController(text: v?.toString() ?? '');
      }
    }
    for (final ctl in _ctrl.values) {
      ctl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctl in _ctrl.values) {
      ctl.dispose();
    }
    super.dispose();
  }

  static TimeOfDay? _parseTime(String? s) {
    if (s == null) return null;
    final p = s.split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null || h > 23 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Nilai form saat ini (hanya field yang bisa diedit).
  Map<String, dynamic> _collect() {
    final out = <String, dynamic>{};
    for (final f in c.fields) {
      if (f.readOnly) continue;
      switch (f.kind) {
        case FieldKind.choice:
          out[f.key] = _choice[f.key];
          break;
        case FieldKind.number:
          out[f.key] = double.tryParse(_ctrl[f.key]!.text.trim().replaceAll(',', '.'));
          break;
        case FieldKind.integer:
          out[f.key] = int.tryParse(_ctrl[f.key]!.text.trim());
          break;
        case FieldKind.stringList:
          out[f.key] = _ctrl[f.key]!
              .text
              .split('\n')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          break;
        default:
          out[f.key] = _ctrl[f.key]!.text.trim();
      }
    }
    return out;
  }

  Map<String, dynamic> get _computed =>
      c.recompute == null ? const {} : c.recompute!(_collect());

  Future<void> _save() async {
    setState(() {
      _error = null;
      _attempted = true;
    });
    final formOk = _formKey.currentState!.validate();
    final missingTime = c.fields.any((f) =>
        f.kind == FieldKind.time && f.required && _ctrl[f.key]!.text.isEmpty);
    if (!formOk || missingTime) return;

    final values = _collect();
    final when = c.dateHasTime
        ? DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute)
        : _date;

    final data = <String, dynamic>{c.dateKey: Timestamp.fromDate(when)};
    if (c.timeKey != null) data[c.timeKey!] = _fmtTime(_time);

    values.forEach((k, v) {
      final empty = v == null || (v is String && v.isEmpty);
      if (empty) {
        if (_isEdit && _orig.containsKey(k)) data[k] = FieldValue.delete();
      } else {
        data[k] = v;
      }
    });
    data.addAll(c.recompute?.call(values) ?? const {});

    setState(() => _saving = true);
    try {
      final col = FirebaseFirestore.instance.collection(c.collection);
      if (_isEdit) {
        data['updatedAt'] = FieldValue.serverTimestamp();
        data['updatedBy'] = widget.admin.uid;
        await widget.doc!.reference.update(data);
      } else {
        data.addAll({
          ...c.defaults,
          'noKode': widget.pasien.noKode,
          'userId': widget.pasien.uid,
          'userName': widget.pasien.nama,
          'userRole': 'pasien',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': widget.admin.uid,
          'createdVia': 'admin_web',
        });
        data.removeWhere((k, v) => v is FieldValue && k != 'createdAt');
        // Daftar turunan yang belum diisi tetap ada sebagai list kosong,
        // agar layar aplikasi yang membacanya tidak error.
        for (final f in c.fields) {
          if (f.kind == FieldKind.stringList) data.putIfAbsent(f.key, () => <String>[]);
        }
        await col.add(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Gagal menyimpan: $e';
      });
    }
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final inputs = c.fields.where((f) => !f.derived).toList();
    final derived = c.fields.where((f) => f.derived).toList();

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
              color: c.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c.icon, color: c.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_isEdit ? 'Edit' : 'Tambah'} ${c.singular}'),
                const SizedBox(height: 2),
                Text(widget.pasien.nama,
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
        width: 560,
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
                _buildDateRow(),
                const SizedBox(height: 16),
                ..._spaced(inputs.map(_buildField)),
                if (derived.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      title: const Text('Hasil analisis aplikasi',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.text)),
                      subtitle: const Text(
                          'Skor, status, dan rekomendasi. Ubah hanya bila perlu koreksi.',
                          style: TextStyle(
                              fontSize: 12, color: AdminColors.textMuted)),
                      children: _spaced(derived.map(_buildField)),
                    ),
                  ),
                ],
                if (c.note != null) ...[
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
                          child: Text(c.note!,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
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
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check, size: 18),
          label: Text(_saving ? 'Menyimpan…' : 'Simpan'),
        ),
      ],
    );
  }

  List<Widget> _spaced(Iterable<Widget> items) {
    final out = <Widget>[];
    for (final w in items) {
      if (out.isNotEmpty) out.add(const SizedBox(height: 14));
      out.add(w);
    }
    return out;
  }

  Widget _buildDateRow() {
    final dateField = _PickerField(
      label: 'Tanggal',
      icon: Icons.calendar_today_outlined,
      value: DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_date),
      enabled: !_saving,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) setState(() => _date = picked);
      },
    );
    if (!c.dateHasTime) return dateField;
    final timeField = _PickerField(
      label: 'Jam',
      icon: Icons.schedule_outlined,
      value: _fmtTime(_time),
      enabled: !_saving,
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _time,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _time = picked);
      },
    );
    return Row(
      children: [
        Expanded(flex: 3, child: dateField),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: timeField),
      ],
    );
  }

  Widget _buildField(ActivityField f) {
    final label = f.unit == null ? f.label : '${f.label} (${f.unit})';

    if (f.readOnly) {
      final computed = _computed[f.key];
      final v = computed ?? _orig[f.key];
      final text = f.key == 'durasiMenit' && v is num
          ? '${v ~/ 60} jam ${v % 60} menit'
          : (v?.toString() ?? '-');
      return InputDecorator(
        decoration: InputDecoration(
          labelText: f.label,
          enabled: false,
          helperText: 'Dihitung otomatis',
          suffixIcon: const Icon(Icons.auto_awesome_outlined, size: 16),
        ),
        child: Text(text, style: const TextStyle(color: AdminColors.textMuted)),
      );
    }

    String? requiredCheck(String? v) =>
        f.required && (v == null || v.trim().isEmpty) ? '${f.label} wajib diisi' : null;

    switch (f.kind) {
      case FieldKind.choice:
        final value = _choice[f.key];
        final items = [
          ...f.options,
          if (value != null && !f.options.contains(value)) value,
        ];
        return DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(labelText: label, helperText: f.helper),
          items: items
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged:
              _saving ? null : (v) => setState(() => _choice[f.key] = v),
          validator: f.required
              ? (v) => v == null ? 'Pilih ${f.label.toLowerCase()}' : null
              : null,
        );

      case FieldKind.suggest:
        final ctl = _ctrl[f.key]!;
        return TextFormField(
          controller: ctl,
          enabled: !_saving,
          decoration: InputDecoration(
            labelText: label,
            helperText: f.helper,
            suffixIcon: PopupMenuButton<String>(
              tooltip: 'Pilih dari daftar',
              icon: const Icon(Icons.arrow_drop_down),
              itemBuilder: (_) => f.options
                  .map((o) => PopupMenuItem(value: o, child: Text(o)))
                  .toList(),
              onSelected: (v) => ctl.text = v,
            ),
          ),
          validator: requiredCheck,
        );

      case FieldKind.time:
        final ctl = _ctrl[f.key]!;
        return _PickerField(
          label: label,
          icon: Icons.schedule_outlined,
          value: ctl.text.isEmpty ? 'Pilih jam' : ctl.text,
          enabled: !_saving,
          errorText: _attempted && f.required && ctl.text.isEmpty
              ? '${f.label} wajib diisi'
              : null,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _parseTime(ctl.text) ?? const TimeOfDay(hour: 22, minute: 0),
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
            );
            if (picked != null) ctl.text = _fmtTime(picked);
          },
        );

      case FieldKind.number:
      case FieldKind.integer:
        final isInt = f.kind == FieldKind.integer;
        return TextFormField(
          controller: _ctrl[f.key],
          enabled: !_saving,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          decoration: InputDecoration(labelText: label, helperText: f.helper),
          validator: (v) {
            final req = requiredCheck(v);
            if (req != null) return req;
            final s = v?.trim() ?? '';
            if (s.isEmpty) return null;
            final ok = isInt
                ? int.tryParse(s) != null
                : double.tryParse(s.replaceAll(',', '.')) != null;
            return ok ? null : (isInt ? 'Masukkan bilangan bulat' : 'Masukkan angka');
          },
        );

      case FieldKind.stringList:
        return TextFormField(
          controller: _ctrl[f.key],
          enabled: !_saving,
          minLines: 2,
          maxLines: 6,
          decoration: InputDecoration(
            labelText: f.label,
            helperText: f.helper ?? 'Satu item per baris',
            alignLabelWithHint: true,
          ),
        );

      case FieldKind.multiline:
        return TextFormField(
          controller: _ctrl[f.key],
          enabled: !_saving,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(
              labelText: label, helperText: f.helper, alignLabelWithHint: true),
          validator: requiredCheck,
        );

      case FieldKind.text:
        return TextFormField(
          controller: _ctrl[f.key],
          enabled: !_saving,
          decoration: InputDecoration(labelText: label, helperText: f.helper),
          validator: requiredCheck,
        );
    }
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool enabled;
  final String? errorText;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: Icon(icon, size: 18),
        ),
        child: Text(value, style: const TextStyle(color: AdminColors.text)),
      ),
    );
  }
}

// ───────────────────────── Detail ─────────────────────────

Future<void> showActivityDetail(
  BuildContext context, {
  required ActivityConfig config,
  required DocumentSnapshot doc,
  VoidCallback? onEdit,
}) {
  final d = doc.data() as Map<String, dynamic>;
  final created = (d['createdAt'] as Timestamp?)?.toDate();
  final updated = (d['updatedAt'] as Timestamp?)?.toDate();
  final fmt = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  Widget row(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 170,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: AdminColors.textMuted)),
            ),
            Expanded(child: value),
          ],
        ),
      );

  Widget valueOf(ActivityField f) {
    final v = d[f.key];
    if (v is List) {
      if (v.isEmpty) return const Text('-');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: v
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $e', style: const TextStyle(height: 1.4)),
                ))
            .toList(),
      );
    }
    var text = f.kind == FieldKind.number || f.kind == FieldKind.integer
        ? fmtNum(v, decimals: 2)
        : str(v);
    if (f.key == 'durasiMenit' && v is num) {
      text = '${v ~/ 60} jam ${v % 60} menit';
    } else if (f.unit != null && text != '-') {
      text = '$text ${f.unit}';
    }
    return Text(text, style: const TextStyle(height: 1.4));
  }

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: config.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail ${config.singular}'),
                Text(formatActivityDate(config, d),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AdminColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.close, color: AdminColors.textMuted),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              for (final f in config.fields) row(f.label, valueOf(f)),
              const Divider(),
              row('Diinput oleh',
                  Text('${str(d['userName'])}${d['createdVia'] == 'admin_web' ? ' (via Admin Panel)' : ''}')),
              if (created != null) row('Dibuat', Text(fmt.format(created))),
              if (updated != null)
                row('Terakhir diubah admin', Text(fmt.format(updated))),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        if (onEdit != null)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onEdit();
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
      ],
    ),
  );
}
