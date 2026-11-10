import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_ui.dart';

/// Jenis input untuk satu field catatan aktivitas.
enum FieldKind {
  text,
  multiline,
  number,
  integer,

  /// Dropdown ketat (mis. Ya / Tidak).
  choice,

  /// Teks bebas dengan saran pilihan (mis. jenis obat).
  suggest,

  /// Daftar string; diedit sebagai satu item per baris.
  stringList,

  /// Jam "HH:mm" yang disimpan sebagai string.
  time,
}

class ActivityField {
  final String key;
  final String label;
  final FieldKind kind;
  final List<String> options;
  final String? unit;
  final bool required;

  /// Field hasil perhitungan aplikasi (skor, status, rekomendasi…).
  /// Tetap bisa diedit admin, tetapi diberi penanda.
  final bool derived;

  /// Hanya ditampilkan (tidak bisa diedit).
  final bool readOnly;
  final String? helper;

  const ActivityField(
    this.key,
    this.label,
    this.kind, {
    this.options = const [],
    this.unit,
    this.required = false,
    this.derived = false,
    this.readOnly = false,
    this.helper,
  });
}

class TableColumn {
  final String label;
  final String Function(Map<String, dynamic> d) value;
  final bool numeric;
  const TableColumn(this.label, this.value, {this.numeric = false});
}

/// Definisi satu koleksi aktivitas pasien di Firestore.
class ActivityConfig {
  final String id;
  final String collection;
  final String title;
  final String singular;
  final IconData icon;
  final Color color;

  /// Field tanggal (Timestamp).
  final String dateKey;

  /// Field jam terpisah ("HH:mm"), bila ada. Jam juga ikut disimpan ke [dateKey].
  final String? timeKey;

  /// true → tanggal menyimpan jam juga (dari [timeKey] atau input jam).
  final bool dateHasTime;

  final List<ActivityField> fields;
  final List<TableColumn> columns;

  /// Nilai tetap saat membuat catatan baru (mis. satuan).
  final Map<String, dynamic> defaults;

  /// Menghitung ulang field turunan yang rumusnya sederhana dan pasti.
  final Map<String, dynamic> Function(Map<String, dynamic> data)? recompute;

  /// Penjelasan singkat yang tampil di form.
  final String? note;

  const ActivityConfig({
    required this.id,
    required this.collection,
    required this.title,
    required this.singular,
    required this.icon,
    required this.color,
    required this.fields,
    required this.columns,
    this.dateKey = 'tanggal',
    this.timeKey,
    this.dateHasTime = true,
    this.defaults = const {},
    this.recompute,
    this.note,
  });
}

// ───────────────────────── helpers ─────────────────────────

String fmtNum(dynamic v, {int decimals = 0}) {
  if (v == null) return '-';
  final n = v is num ? v : num.tryParse(v.toString());
  if (n == null) return v.toString();
  if (decimals == 0 || n == n.roundToDouble()) return n.round().toString();
  return n.toStringAsFixed(decimals);
}

String str(dynamic v) {
  final s = v?.toString().trim() ?? '';
  return s.isEmpty ? '-' : s;
}

/// Menit antara jam tidur dan jam bangun (melewati tengah malam).
int? sleepMinutes(String? tidur, String? bangun) {
  int? toMin(String? s) {
    if (s == null) return null;
    final p = s.split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  final a = toMin(tidur);
  final b = toMin(bangun);
  if (a == null || b == null) return null;
  var d = b - a;
  if (d <= 0) d += 24 * 60;
  return d;
}

String hba1cStatus(double nilai) {
  // Sama dengan catatan_hba1c.dart
  if (nilai < 5.7) return 'Normal';
  if (nilai < 6.5) return 'Prediabetes';
  return 'Diabetes';
}

const _yaTidak = ['Ya', 'Tidak'];
const _waktu = ['Pagi', 'Siang', 'Malam'];

// ───────────────────────── configs ─────────────────────────

final List<ActivityConfig> kActivityConfigs = [
  ActivityConfig(
    id: 'gula',
    collection: 'blood_sugar_logs',
    title: 'Gula Darah',
    singular: 'catatan gula darah',
    icon: Icons.bloodtype_outlined,
    color: AdminColors.danger,
    defaults: const {'satuan': 'mg/dL'},
    fields: const [
      ActivityField('gulaDarahPuasa', 'Gula darah puasa', FieldKind.number,
          unit: 'mg/dL'),
      ActivityField('gulaDarahSewaktu', 'Gula darah sewaktu', FieldKind.number,
          unit: 'mg/dL'),
      ActivityField('gulaDarah2JamPP', 'Gula darah 2 jam PP', FieldKind.number,
          unit: 'mg/dL'),
    ],
    columns: [
      TableColumn('PUASA', (d) => fmtNum(d['gulaDarahPuasa']), numeric: true),
      TableColumn('SEWAKTU', (d) => fmtNum(d['gulaDarahSewaktu']),
          numeric: true),
      TableColumn('2 JAM PP', (d) => fmtNum(d['gulaDarah2JamPP']),
          numeric: true),
    ],
  ),
  ActivityConfig(
    id: 'hba1c',
    collection: 'hba1c_logs',
    title: 'HbA1c',
    singular: 'catatan HbA1c',
    icon: Icons.science_outlined,
    color: Color(0xFF7B5CD6),
    dateHasTime: false,
    defaults: const {'satuan': '%'},
    note: 'Status (Normal / Prediabetes / Diabetes) dihitung otomatis dari nilai HbA1c.',
    recompute: (d) {
      final v = (d['nilaiHbA1c'] as num?)?.toDouble();
      return {if (v != null) 'status': hba1cStatus(v)};
    },
    fields: const [
      ActivityField('nilaiHbA1c', 'Nilai HbA1c', FieldKind.number,
          unit: '%', required: true),
      ActivityField('tempatPemeriksaan', 'Tempat pemeriksaan', FieldKind.text),
      ActivityField('catatan', 'Catatan', FieldKind.multiline),
      ActivityField('status', 'Status', FieldKind.text, readOnly: true),
    ],
    columns: [
      TableColumn('NILAI', (d) => '${fmtNum(d['nilaiHbA1c'], decimals: 1)} %',
          numeric: true),
      TableColumn('STATUS', (d) => str(d['status'])),
      TableColumn('TEMPAT', (d) => str(d['tempatPemeriksaan'])),
    ],
  ),
  ActivityConfig(
    id: 'makan',
    collection: 'food_logs',
    title: 'Makan',
    singular: 'catatan makan',
    icon: Icons.restaurant_outlined,
    color: AdminColors.warning,
    timeKey: 'jam',
    note: 'Nilai gizi tidak dihitung ulang otomatis bila nama makanan atau gram diubah.',
    fields: const [
      ActivityField('waktu', 'Waktu makan', FieldKind.choice,
          options: _waktu, required: true),
      ActivityField('kategori', 'Kategori', FieldKind.choice,
          options: ['Makan Utama', 'Snack'], required: true),
      ActivityField('foodName', 'Nama makanan', FieldKind.text, required: true),
      ActivityField('porsi', 'Porsi', FieldKind.suggest,
          options: ['¼ piring', '1/3 piring', '½ piring', '1 piring']),
      ActivityField('grams', 'Berat', FieldKind.number, unit: 'gram'),
      ActivityField('calories', 'Kalori', FieldKind.number, unit: 'kkal'),
      ActivityField('carbohydrate', 'Karbohidrat', FieldKind.number, unit: 'g'),
      ActivityField('protein', 'Protein', FieldKind.number, unit: 'g'),
      ActivityField('fat', 'Lemak', FieldKind.number, unit: 'g'),
    ],
    columns: [
      TableColumn('WAKTU', (d) => str(d['waktu'])),
      TableColumn('MAKANAN', (d) => str(d['foodName'])),
      TableColumn('PORSI', (d) => str(d['porsi'])),
      TableColumn('GRAM', (d) => fmtNum(d['grams']), numeric: true),
      TableColumn('KALORI', (d) => fmtNum(d['calories'], decimals: 1),
          numeric: true),
    ],
  ),
  ActivityConfig(
    id: 'obat',
    collection: 'medication_logs',
    title: 'Obat',
    singular: 'catatan minum obat',
    icon: Icons.medication_outlined,
    color: AdminColors.info,
    timeKey: 'jam',
    fields: const [
      ActivityField('waktu', 'Waktu minum', FieldKind.choice,
          options: _waktu, required: true),
      ActivityField('jenisObat', 'Jenis obat', FieldKind.suggest,
          required: true,
          options: [
            'Metformin',
            'Insulin',
            'Glimepiride',
            'Glibenclamide',
            'Glipizide',
            'Acarbose',
          ]),
      ActivityField('dosis', 'Dosis', FieldKind.number, required: true),
      ActivityField('satuan', 'Satuan', FieldKind.choice,
          options: ['Tablet', 'Unit'], required: true),
    ],
    columns: [
      TableColumn('WAKTU', (d) => str(d['waktu'])),
      TableColumn('OBAT', (d) => str(d['jenisObat'])),
      TableColumn('DOSIS', (d) => '${fmtNum(d['dosis'], decimals: 1)} ${str(d['satuan'])}'),
    ],
  ),
  ActivityConfig(
    id: 'fisik',
    collection: 'latihan_fisik_logs',
    title: 'Latihan Fisik',
    singular: 'catatan latihan fisik',
    icon: Icons.directions_run_outlined,
    color: AdminColors.keluarga,
    timeKey: 'jam',
    note: 'Kalori terbakar, intensitas, manfaat, dan rekomendasi dihitung aplikasi saat input dan tidak berubah otomatis.',
    fields: const [
      ActivityField('jenisOlahraga', 'Jenis olahraga', FieldKind.suggest,
          required: true,
          options: [
            'Jalan Kaki',
            'Rumah Tangga',
            'Senam',
            'Jogging',
            'Bersepeda',
            'Lari',
            'Badminton',
            'Yoga',
          ]),
      ActivityField('durasi', 'Durasi', FieldKind.integer, required: true),
      ActivityField('satuanDurasi', 'Satuan durasi', FieldKind.choice,
          options: ['Menit', 'Total Durasi']),
      ActivityField('kaloriTerbakar', 'Kalori terbakar', FieldKind.integer,
          unit: 'kkal', derived: true),
      ActivityField('kategoriIntensitas', 'Kategori intensitas',
          FieldKind.suggest,
          derived: true,
          options: [
            'SANGAT RINGAN',
            'RINGAN - Aktivitas Fisik',
            'SEDANG - Olahraga Teratur',
            'TINGGI - Olahraga Intensif',
          ]),
      ActivityField('manfaat', 'Manfaat', FieldKind.stringList, derived: true),
      ActivityField('rekomendasi', 'Rekomendasi', FieldKind.stringList,
          derived: true),
    ],
    columns: [
      TableColumn('OLAHRAGA', (d) => str(d['jenisOlahraga'])),
      TableColumn('DURASI', (d) => '${fmtNum(d['durasi'])} ${d['satuanDurasi'] == 'Menit' ? 'menit' : str(d['satuanDurasi'])}'),
      TableColumn('KALORI', (d) => fmtNum(d['kaloriTerbakar']), numeric: true),
      TableColumn('INTENSITAS', (d) => str(d['kategoriIntensitas'])),
    ],
  ),
  ActivityConfig(
    id: 'kaki',
    collection: 'foot_care_logs',
    title: 'Perawatan Kaki',
    singular: 'catatan perawatan kaki',
    icon: Icons.accessibility_new_outlined,
    color: Color(0xFF2B9BA8),
    timeKey: 'jam',
    note: 'Skor risiko, status, dan rekomendasi dihitung aplikasi saat input dan tidak berubah otomatis.',
    fields: const [
      ActivityField('mengeringkanKaki', 'Mengeringkan kaki', FieldKind.choice,
          options: _yaTidak),
      ActivityField('memeriksaSepatu', 'Memeriksa sepatu', FieldKind.choice,
          options: _yaTidak),
      ActivityField('menggunakanPelembab', 'Menggunakan pelembab',
          FieldKind.choice,
          options: _yaTidak),
      ActivityField('menggunakanAlasKaki', 'Menggunakan alas kaki',
          FieldKind.choice,
          options: _yaTidak),
      ActivityField('kondisiKaki', 'Kondisi kaki', FieldKind.stringList,
          helper: 'Satu kondisi per baris, mis. "Tidak ada masalah"'),
      ActivityField('skorRisiko', 'Skor risiko', FieldKind.integer,
          derived: true),
      ActivityField('statusKondisi', 'Status kondisi', FieldKind.suggest,
          derived: true,
          options: [
            'BAIK - Pertahankan Perawatan',
            'RENDAH - Perlu Perbaikan Kebiasaan',
            'SEDANG - Perlu Perawatan Khusus',
            'TINGGI - Perlu Perhatian Medis Segera',
          ]),
      ActivityField('deskripsiObservasi', 'Deskripsi observasi',
          FieldKind.multiline,
          derived: true),
      ActivityField('rekomendasi', 'Rekomendasi', FieldKind.stringList,
          derived: true),
    ],
    columns: [
      TableColumn('KONDISI', (d) {
        final k = d['kondisiKaki'];
        return k is List && k.isNotEmpty ? k.join(', ') : '-';
      }),
      TableColumn('SKOR', (d) => fmtNum(d['skorRisiko']), numeric: true),
      TableColumn('STATUS', (d) => str(d['statusKondisi'])),
    ],
  ),
  ActivityConfig(
    id: 'stress',
    collection: 'stress_management_logs',
    title: 'Manajemen Stress',
    singular: 'catatan manajemen stress',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF9C4DCC),
    timeKey: 'jam',
    note: 'Skor, status, analisis, dan rekomendasi dihitung aplikasi saat input dan tidak berubah otomatis.',
    fields: const [
      ActivityField('perasaan', 'Perasaan', FieldKind.suggest,
          required: true,
          options: [
            'Perasaan Senang',
            'Perasaan Cemas',
            'Perasaan Sedih',
            'Perasaan Marah',
            'Perasaan Stres',
            'Perasaan Takut',
          ]),
      ActivityField('tekananDarah', 'Tekanan darah', FieldKind.text,
          helper: 'Format sistolik/diastolik, mis. 120/80. Isi "-" bila tidak diukur.'),
      ActivityField('skorStress', 'Skor stress', FieldKind.integer,
          derived: true),
      ActivityField('statusStress', 'Status stress', FieldKind.suggest,
          derived: true,
          options: [
            'BAIK - Pertahankan',
            'RINGAN - Perlu Pemantauan',
            'SEDANG - Perlu Teknik Relaksasi',
            'SEDANG-TINGGI - Perlu Intervensi',
            'TINGGI - Perlu Konseling Profesional',
          ]),
      ActivityField('analisisPerasaan', 'Analisis perasaan',
          FieldKind.multiline,
          derived: true),
      ActivityField('analisaTekananDarah', 'Analisis tekanan darah',
          FieldKind.multiline,
          derived: true),
      ActivityField('deskripsiObservasi', 'Deskripsi observasi',
          FieldKind.multiline,
          derived: true),
      ActivityField('rekomendasi', 'Rekomendasi', FieldKind.stringList,
          derived: true),
    ],
    columns: [
      TableColumn('PERASAAN', (d) => str(d['perasaan'])),
      TableColumn('TEKANAN DARAH', (d) => str(d['tekananDarah'])),
      TableColumn('SKOR', (d) => fmtNum(d['skorStress']), numeric: true),
      TableColumn('STATUS', (d) => str(d['statusStress'])),
    ],
  ),
  ActivityConfig(
    id: 'tidur',
    collection: 'aktivitas_tidur_logs',
    title: 'Tidur',
    singular: 'catatan tidur',
    icon: Icons.bedtime_outlined,
    color: Color(0xFF3F51B5),
    dateHasTime: false,
    note: 'Durasi tidur dihitung otomatis dari jam tidur dan jam bangun.',
    recompute: (d) {
      final m = sleepMinutes(d['jamTidur'] as String?, d['jamBangun'] as String?);
      return {if (m != null) 'durasiMenit': m};
    },
    fields: const [
      ActivityField('jamTidur', 'Jam tidur', FieldKind.time, required: true),
      ActivityField('jamBangun', 'Jam bangun', FieldKind.time, required: true),
      ActivityField('kualitas', 'Kualitas tidur', FieldKind.choice,
          options: ['Baik', 'Cukup', 'Kurang'], required: true),
      ActivityField('catatan', 'Catatan', FieldKind.multiline),
      ActivityField('durasiMenit', 'Durasi', FieldKind.integer,
          unit: 'menit', readOnly: true),
    ],
    columns: [
      TableColumn('TIDUR', (d) => str(d['jamTidur'])),
      TableColumn('BANGUN', (d) => str(d['jamBangun'])),
      TableColumn('DURASI', (d) {
        final m = (d['durasiMenit'] as num?)?.toInt();
        if (m == null) return '-';
        return '${m ~/ 60} j ${m % 60} m';
      }),
      TableColumn('KUALITAS', (d) => str(d['kualitas'])),
    ],
  ),
];
