import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/pasien/activity_config.dart';
import 'package:promedia_v2/food_item.dart';
import 'package:promedia_v2/tkpi_data.dart';

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
  final Map<String, Set<String>> _multi = {};
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
        case FieldKind.multiChoice:
          _multi[f.key] = {if (v is List) ...v.map((e) => e.toString())};
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
          final text = v?.toString() ?? '';
          _ctrl[f.key] = TextEditingController(
              text: f.emptyValue != null && text == f.emptyValue ? '' : text);
      }
    }
    if (!_isEdit && c.newDefaults != null) {
      final when = DateTime(
          _date.year, _date.month, _date.day, _time.hour, _time.minute);
      c.newDefaults!(when).forEach((k, v) {
        if (_choice.containsKey(k)) {
          _choice[k] = v?.toString();
        } else {
          _ctrl[k]?.text = v?.toString() ?? '';
        }
      });
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
        case FieldKind.multiChoice:
          // Urutan mengikuti daftar pilihan; nilai lama di luar daftar tetap ikut.
          final sel = _multi[f.key] ?? {};
          out[f.key] = [
            ...f.options.where(sel.contains),
            ...sel.where((v) => !f.options.contains(v)),
          ];
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
        f.required &&
        ((f.kind == FieldKind.time || f.kind == FieldKind.food) &&
                _ctrl[f.key]!.text.isEmpty ||
            f.kind == FieldKind.multiChoice && (_multi[f.key]?.isEmpty ?? true)));
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
    final inputs =
        c.fields.where((f) => !f.derived && !f.readOnly).toList();
    final derived = c.fields.where((f) => f.derived && !f.readOnly).toList();
    final results = c.fields.where((f) => f.readOnly).toList();

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
                if (results.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildResults(results),
                ],
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

  static FoodItem? _findFood(String name) =>
      TKPIData.foods.where((f) => f.name == name).firstOrNull;

  /// Panel hasil perhitungan otomatis (seperti dialog hasil di aplikasi).
  Widget _buildResults(List<ActivityField> fields) {
    final computed = _computed;
    // Catatan lama yang belum bisa dihitung ulang (mis. makanan di luar
    // daftar TKPI) tetap menampilkan nilai tersimpan.
    dynamic valueOf(ActivityField f) =>
        computed.containsKey(f.key) ? computed[f.key] : _orig[f.key];
    final ready = computed.isNotEmpty ||
        (_isEdit && fields.any((f) => _orig[f.key] != null));
    String fmt(ActivityField f, dynamic v) {
      if (v == null) return '-';
      if (f.key == 'durasiMenit' && v is num) {
        return '${v ~/ 60} jam ${v % 60} menit';
      }
      if (v is num) {
        final n = fmtNum(v, decimals: 1);
        return f.unit == null ? n : '$n ${f.unit}';
      }
      return v.toString();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: c.color),
              const SizedBox(width: 8),
              Text('Hasil perhitungan otomatis',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: c.color)),
            ],
          ),
          const SizedBox(height: 10),
          if (!ready)
            const Text('Lengkapi isian di atas untuk melihat hasilnya.',
                style: TextStyle(fontSize: 13, color: AdminColors.textMuted))
          else
            for (final f in fields)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(f.label,
                          style: const TextStyle(
                              fontSize: 13, color: AdminColors.textMuted)),
                    ),
                    Expanded(
                      child: valueOf(f) is List
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final item in valueOf(f) as List)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text('• $item',
                                        style: const TextStyle(
                                            fontSize: 13, height: 1.35)),
                                  ),
                              ],
                            )
                          : Text(fmt(f, valueOf(f)),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35)),
                    ),
                  ],
                ),
              ),
        ],
      ),
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

      case FieldKind.food:
        final ctl = _ctrl[f.key]!;
        final food = _findFood(ctl.text);
        return _PickerField(
          label: f.label,
          icon: Icons.search,
          value: ctl.text.isEmpty
              ? 'Pilih dari daftar makanan (TKPI)'
              : (food == null
                  ? '${ctl.text}  (tidak ada di daftar TKPI)'
                  : '${food.name}  ·  ${food.category}'),
          enabled: !_saving,
          errorText: _attempted && f.required && ctl.text.isEmpty
              ? 'Pilih jenis makanan'
              : null,
          onTap: () async {
            final picked = await showDialog<FoodItem>(
              context: context,
              builder: (_) => _FoodPickerDialog(initial: food),
            );
            if (picked != null) ctl.text = picked.name;
          },
        );

      case FieldKind.multiChoice:
        final sel = _multi[f.key] ??= {};
        return InputDecorator(
          decoration: InputDecoration(
            labelText: f.label,
            helperText: f.exclusiveOption == null
                ? 'Boleh pilih lebih dari satu'
                : 'Boleh pilih lebih dari satu, kecuali "${f.exclusiveOption}"',
            errorText: _attempted && f.required && sel.isEmpty
                ? 'Pilih minimal satu'
                : null,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in {...f.options, ...sel})
                FilterChip(
                  label: Text(o, style: const TextStyle(fontSize: 13)),
                  selected: sel.contains(o),
                  selectedColor: c.color.withOpacity(0.15),
                  checkmarkColor: c.color,
                  onSelected: _saving
                      ? null
                      : (on) => setState(() {
                            // Aturan sama dengan aplikasi: opsi eksklusif
                            // menghapus pilihan lain, dan sebaliknya.
                            if (on && o == f.exclusiveOption) {
                              sel
                                ..clear()
                                ..add(o);
                            } else if (on) {
                              sel
                                ..remove(f.exclusiveOption)
                                ..add(o);
                            } else {
                              sel.remove(o);
                            }
                          }),
                ),
            ],
          ),
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

/// Pemilih makanan dari database TKPI — pencarian + filter kategori,
/// sama dengan daftar makanan di aplikasi.
class _FoodPickerDialog extends StatefulWidget {
  final FoodItem? initial;
  const _FoodPickerDialog({this.initial});

  @override
  State<_FoodPickerDialog> createState() => _FoodPickerDialogState();
}

class _FoodPickerDialogState extends State<_FoodPickerDialog> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final categories = TKPIData.getCategories();
    var foods = TKPIData.foods;
    if (_category != null) {
      foods = foods.where((f) => f.category == _category).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      foods = foods.where((f) => f.name.toLowerCase().contains(q)).toList();
    }

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Pilih Jenis Makanan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AdminColors.textMuted),
                  ),
                ],
              ),
              const Text('Database TKPI — nilai gizi per 100 gram',
                  style: TextStyle(fontSize: 12, color: AdminColors.textMuted)),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Cari makanan…',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final cat in [null, ...categories])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat ?? 'Semua',
                              style: const TextStyle(fontSize: 12)),
                          selected: _category == cat,
                          onSelected: (_) => setState(() => _category = cat),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('${foods.length} makanan',
                  style: const TextStyle(
                      fontSize: 12, color: AdminColors.textSubtle)),
              const Divider(),
              Expanded(
                child: foods.isEmpty
                    ? const Center(
                        child: Text('Makanan tidak ditemukan',
                            style: TextStyle(color: AdminColors.textMuted)))
                    : ListView.separated(
                        itemCount: foods.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final f = foods[i];
                          final selected = widget.initial?.name == f.name;
                          return ListTile(
                            dense: true,
                            selected: selected,
                            title: Text(f.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${f.category}  ·  ${fmtNum(f.energyKcal)} kkal  ·  '
                                'KH ${fmtNum(f.carbohydrate, decimals: 1)} g  ·  '
                                'P ${fmtNum(f.protein, decimals: 1)} g  ·  '
                                'L ${fmtNum(f.fat, decimals: 1)} g'),
                            trailing: selected
                                ? const Icon(Icons.check_circle,
                                    color: AdminColors.primary)
                                : null,
                            onTap: () => Navigator.pop(context, f),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
