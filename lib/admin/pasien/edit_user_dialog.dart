import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';

const kAktivitasKaloriList = [
  'Istirahat: +10%',
  'Ringan: +20% (pegawai kantor, guru, ibu rumah tangga)',
  'Sedang: +30% (industri ringan, mahasiswa)',
  'Berat: +40% (petani, buruh, atlet latihan)',
  'Sangat berat: +50% (tukang becak, tukang gali)',
];
const kPendidikanList = [
  'Tidak Sekolah',
  'SD',
  'SMP',
  'SMA',
  'Diploma',
  'Sarjana',
  'Pascasarjana',
];
const kKeluargaPendampingList = ['Anak', 'Suami', 'Istri', 'Saudara'];

/// Rumus kebutuhan kalori — sama persis dengan kebutuhan_kalori.dart (PERKENI).
({double kalori, String statusBB}) hitungKebutuhanKalori({
  required int usia,
  required double tb,
  required double bb,
  required String jenisKelamin,
  required String aktivitas,
}) {
  final pria = jenisKelamin == 'Laki-laki';
  final bbi = ((pria && tb >= 160) || (!pria && tb >= 150))
      ? 0.9 * (tb - 100)
      : tb - 100;
  final statusBB =
      bb < bbi * 0.9 ? 'Kurus' : (bb > bbi * 1.1 ? 'Gemuk' : 'Normal');
  final basal = bbi * (pria ? 30 : 25);
  var faktorUsia = 1.0;
  if (usia >= 40 && usia < 60) {
    faktorUsia = 0.95;
  } else if (usia >= 60 && usia < 70) {
    faktorUsia = 0.90;
  } else if (usia >= 70) {
    faktorUsia = 0.80;
  }
  var faktorAktivitas = 1.1;
  if (aktivitas.contains('Ringan')) {
    faktorAktivitas = 1.2;
  } else if (aktivitas.contains('Sedang')) {
    faktorAktivitas = 1.3;
  } else if (aktivitas.contains('Berat') && !aktivitas.contains('Sangat')) {
    faktorAktivitas = 1.4;
  } else if (aktivitas.contains('Sangat berat')) {
    faktorAktivitas = 1.5;
  }
  var kalori = basal * faktorUsia * faktorAktivitas;
  final minimal = pria ? 1200.0 : 1000.0;
  if (kalori < minimal) kalori = minimal;
  return (kalori: kalori, statusBB: statusBB);
}

/// Form edit data pengguna. Pasien mendapat bagian data kesehatan & kalori.
/// Mengembalikan true bila tersimpan.
Future<bool?> showEditUserDialog(
  BuildContext context, {
  required DocumentSnapshot doc,
  required AdminProfile admin,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _EditUserDialog(doc: doc, admin: admin),
  );
}

class _EditUserDialog extends StatefulWidget {
  final DocumentSnapshot doc;
  final AdminProfile admin;
  const _EditUserDialog({required this.doc, required this.admin});

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, dynamic> _data;
  late final bool _isPasien;

  late final TextEditingController _nama;
  late final TextEditingController _nik;
  late final TextEditingController _noHp;
  late final TextEditingController _alamat;
  late final TextEditingController _lamaDM;
  late final TextEditingController _usia;
  late final TextEditingController _tb;
  late final TextEditingController _bb;

  String? _jenisKelamin;
  String? _pendidikan;
  String? _keluargaPendamping;
  String? _jkKalori;
  String? _aktivitas;

  bool _saving = false;
  bool _attempted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _data = widget.doc.data() as Map<String, dynamic>;
    _isPasien = _data['role'] == 'pasien';

    String s(String k) => _data[k]?.toString() ?? '';
    String num0(String k) {
      final v = _data[k];
      if (v is num) return v == v.roundToDouble() ? v.round().toString() : '$v';
      return v?.toString() ?? '';
    }

    _nama = TextEditingController(text: s('namaLengkap'));
    _nik = TextEditingController(text: s('nik'));
    _noHp = TextEditingController(
        text: s('noHp').replaceFirst(RegExp(r'^\+?62'), ''));
    _alamat = TextEditingController(text: s('alamat'));
    _lamaDM = TextEditingController(text: num0('lamaMenderitaDM'));
    _usia = TextEditingController(text: num0('usiaKalori'));
    _tb = TextEditingController(text: num0('tbKalori'));
    _bb = TextEditingController(text: num0('bbKalori'));

    _jenisKelamin = _data['jenisKelamin'] as String?;
    _pendidikan = _data['pendidikan'] as String?;
    _keluargaPendamping = _data['keluargaPendamping'] as String?;
    _jkKalori = (_data['jenisKelaminKalori'] as String?) ??
        (_jenisKelamin == 'Perempuan' || _jenisKelamin == 'Wanita'
            ? 'Perempuan'
            : (_jenisKelamin == null ? null : 'Laki-laki'));
    _aktivitas =
        (_data['aktivitasKalori'] as String?) ?? kAktivitasKaloriList[1];

    for (final c in [_usia, _tb, _bb]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_nama, _nik, _noHp, _alamat, _lamaDM, _usia, _tb, _bb]) {
      c.dispose();
    }
    super.dispose();
  }

  ({double kalori, String statusBB})? get _kaloriPreview {
    final usia = int.tryParse(_usia.text);
    final tb = double.tryParse(_tb.text.replaceAll(',', '.'));
    final bb = double.tryParse(_bb.text.replaceAll(',', '.'));
    if (usia == null || tb == null || bb == null || _jkKalori == null) {
      return null;
    }
    return hitungKebutuhanKalori(
      usia: usia,
      tb: tb,
      bb: bb,
      jenisKelamin: _jkKalori!,
      aktivitas: _aktivitas ?? kAktivitasKaloriList[1],
    );
  }

  bool get _kaloriTouched =>
      _usia.text.isNotEmpty || _tb.text.isNotEmpty || _bb.text.isNotEmpty;

  Future<void> _save() async {
    setState(() {
      _error = null;
      _attempted = true;
    });
    if (!_formKey.currentState!.validate()) return;

    final nik = _nik.text.trim();
    setState(() => _saving = true);
    try {
      final users = FirebaseFirestore.instance.collection('users');
      if (nik != (_data['nik'] ?? '').toString()) {
        final taken = await users.where('nik', isEqualTo: nik).limit(2).get();
        final other = taken.docs.where((d) => d.id != widget.doc.id);
        if (other.isNotEmpty) {
          throw 'NIK $nik sudah dipakai ${other.first.data()['namaLengkap'] ?? 'pengguna lain'}';
        }
      }

      var phone = _noHp.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (phone.startsWith('62')) phone = phone.substring(2);
      if (phone.startsWith('0')) phone = phone.substring(1);

      final update = <String, dynamic>{
        'namaLengkap': _nama.text.trim(),
        'nik': nik,
        'noHp': '+62$phone',
        'alamat': _alamat.text.trim(),
        'jenisKelamin': _jenisKelamin,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': widget.admin.uid,
      };

      if (_isPasien) {
        final lama = int.tryParse(_lamaDM.text.trim());
        update['lamaMenderitaDM'] = lama ?? FieldValue.delete();
        update['pendidikan'] = _pendidikan ?? FieldValue.delete();
        update['keluargaPendamping'] =
            _keluargaPendamping ?? FieldValue.delete();

        final k = _kaloriPreview;
        if (k != null) {
          update.addAll({
            'usiaKalori': int.parse(_usia.text),
            'tbKalori': double.parse(_tb.text.replaceAll(',', '.')),
            'bbKalori': double.parse(_bb.text.replaceAll(',', '.')),
            'jenisKelaminKalori': _jkKalori,
            'aktivitasKalori': _aktivitas ?? kAktivitasKaloriList[1],
            'kebutuhanKalori': k.kalori,
          });
        }
      }

      await widget.doc.reference.update(update);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final twoCol = MediaQuery.of(context).size.width >= 720;
    Widget pair(Widget a, Widget b) => twoCol
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: a),
            const SizedBox(width: 16),
            Expanded(child: b),
          ])
        : Column(children: [a, const SizedBox(height: 16), b]);

    final nama = (_data['namaLengkap'] ?? '-').toString();
    final role = (_data['role'] ?? '-').toString();

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(
        children: [
          AdminAvatar(nama,
              size: 44,
              color: role == 'keluarga'
                  ? AdminColors.keluarga
                  : AdminColors.pasien),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit ${role == 'pasien' ? 'Pasien' : 'Keluarga'}'),
                const SizedBox(height: 2),
                Text(nama,
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
        width: 640,
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
                const _Section('Data diri'),
                _text(_nama, 'Nama lengkap', required: true),
                const SizedBox(height: 16),
                pair(
                  _text(_nik, 'NIK',
                      required: true,
                      keyboard: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly]),
                  _dropdown(
                    label: 'Jenis kelamin',
                    value: _jenisKelamin,
                    options: const ['Laki-laki', 'Perempuan'],
                    onChanged: (v) => setState(() => _jenisKelamin = v),
                    required: true,
                  ),
                ),
                const SizedBox(height: 16),
                _text(_noHp, 'No HP',
                    required: true,
                    prefix: '+62 ',
                    keyboard: TextInputType.phone,
                    formatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 16),
                _text(_alamat, 'Alamat', required: true, maxLines: 2),
                if (_isPasien) ...[
                  const SizedBox(height: 24),
                  const _Section('Data kesehatan'),
                  pair(
                    _dropdown(
                      label: 'Pendidikan terakhir',
                      value: _pendidikan,
                      options: kPendidikanList,
                      onChanged: (v) => setState(() => _pendidikan = v),
                    ),
                    _text(_lamaDM, 'Lama menderita DM',
                        suffix: 'tahun',
                        keyboard: TextInputType.number,
                        formatters: [FilteringTextInputFormatter.digitsOnly]),
                  ),
                  const SizedBox(height: 16),
                  _dropdown(
                    label: 'Keluarga pendamping',
                    value: _keluargaPendamping,
                    options: kKeluargaPendampingList,
                    onChanged: (v) => setState(() => _keluargaPendamping = v),
                  ),
                  const SizedBox(height: 24),
                  const _Section('Kebutuhan kalori'),
                  pair(
                    pair(
                      _text(_usia, 'Usia',
                          suffix: 'th',
                          keyboard: TextInputType.number,
                          formatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: _kaloriValidator(int.tryParse)),
                      _dropdown(
                        label: 'Jenis kelamin',
                        value: _jkKalori,
                        options: const ['Laki-laki', 'Perempuan'],
                        onChanged: (v) => setState(() => _jkKalori = v),
                      ),
                    ),
                    pair(
                      _text(_tb, 'Tinggi',
                          suffix: 'cm',
                          keyboard: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _kaloriValidator(
                              (s) => double.tryParse(s.replaceAll(',', '.')))),
                      _text(_bb, 'Berat',
                          suffix: 'kg',
                          keyboard: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _kaloriValidator(
                              (s) => double.tryParse(s.replaceAll(',', '.')))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dropdown(
                    label: 'Aktivitas fisik harian',
                    value: _aktivitas,
                    options: kAktivitasKaloriList,
                    onChanged: (v) => setState(() => _aktivitas = v),
                  ),
                  const SizedBox(height: 12),
                  _buildKaloriPreview(),
                ],
                const SizedBox(height: 24),
                const _Section('Akun login'),
                pair(
                  _readOnly('Email', _data['email']),
                  _readOnly('No kode', _data['noKode']),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Email dan no kode tidak diubah dari web: no kode menghubungkan '
                  'semua catatan aktivitas dan akun keluarga.',
                  style: TextStyle(fontSize: 12, color: AdminColors.textMuted),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_error!,
                        style: const TextStyle(
                            color: AdminColors.danger, fontSize: 13)),
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
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check, size: 18),
          label: Text(_saving ? 'Menyimpan…' : 'Simpan perubahan'),
        ),
      ],
    );
  }

  FormFieldValidator<String> _kaloriValidator(
          Object? Function(String) parse) =>
      (v) {
        final s = v?.trim() ?? '';
        if (s.isEmpty) {
          return _kaloriTouched ? 'Wajib bila menghitung kalori' : null;
        }
        return parse(s) == null ? 'Angka tidak valid' : null;
      };

  Widget _buildKaloriPreview() {
    final k = _kaloriPreview;
    final saved = (_data['kebutuhanKalori'] as num?)?.toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.warning.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_outlined,
              color: AdminColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: k == null
                ? Text(
                    saved == null
                        ? 'Isi usia, tinggi, berat, dan jenis kelamin untuk menghitung kebutuhan kalori.'
                        : 'Tersimpan: ${saved.round()} kkal/hari. Lengkapi data untuk menghitung ulang.',
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.text),
                  )
                : RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: AdminColors.text, height: 1.4),
                      children: [
                        const TextSpan(text: 'Kebutuhan kalori: '),
                        TextSpan(
                          text: '${k.kalori.round()} kkal/hari',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: '  ·  Status berat badan: ${k.statusBB}'),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _text(
    TextEditingController c,
    String label, {
    bool required = false,
    String? prefix,
    String? suffix,
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
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
      ),
      validator: validator ??
          (required
              ? (v) =>
                  (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
              : null),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool required = false,
  }) {
    // Pertahankan nilai lama yang tidak ada di daftar pilihan.
    final items = [
      ...options,
      if (value != null && !options.contains(value)) value,
    ];
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((o) => DropdownMenuItem(
              value: o, child: Text(o, overflow: TextOverflow.ellipsis)))
          .toList(),
      onChanged: _saving ? null : onChanged,
      validator: required ? (v) => v == null ? 'Pilih $label' : null : null,
    );
  }

  Widget _readOnly(String label, dynamic value) {
    return TextFormField(
      initialValue: value?.toString() ?? '-',
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.lock_outline, size: 16),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String text;
  const _Section(this.text);

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
