import 'package:flutter_test/flutter_test.dart';
import 'package:promedia_v2/logic/activity_logic.dart';
import 'package:promedia_v2/tkpi_data.dart';

// Nilai yang diharapkan diambil dari catatan nyata yang dibuat lewat
// aplikasi mobile (koleksi food_logs, latihan_fisik_logs, foot_care_logs,
// stress_management_logs), sehingga tes ini memastikan Admin Panel
// menghasilkan data yang sama dengan aplikasi.
void main() {
  test('makan: Susu Sapi Segar ¼ piring sama dengan catatan aplikasi', () {
    final food = TKPIData.foods.firstWhere((f) => f.name == 'Susu Sapi Segar');
    final grams = FoodLogic.porsiToGrams('¼ piring');
    expect(grams, 50);
    expect(food.calculateCalories(grams), closeTo(30.5, 1e-9));
    expect(food.calculateCarbs(grams), closeTo(2.15, 1e-9));
    expect(food.calculateProtein(grams), closeTo(1.6, 1e-9));
    expect(food.calculateFat(grams), closeTo(1.75, 1e-9));
  });

  test('makan: waktu otomatis dari jam', () {
    expect(FoodLogic.waktuMakan(7), 'Pagi');
    expect(FoodLogic.waktuMakan(12), 'Siang');
    expect(FoodLogic.waktuMakan(19), 'Malam');
  });

  test('latihan fisik: Jalan Kaki 30 menit sama dengan catatan aplikasi', () {
    expect(ExerciseLogic.hitungKalori('Jalan Kaki', 30), 105);
    expect(ExerciseLogic.kategoriIntensitas(30), 'SEDANG - Olahraga Teratur');
    expect(ExerciseLogic.manfaat('Jalan Kaki', 30).first,
        '✓ Meningkatkan kesehatan jantung dan sirkulasi darah');
    expect(ExerciseLogic.rekomendasi(30).first,
        '✅ Durasi sudah bagus! Pertahankan konsistensi');
  });

  test('perawatan kaki: tanpa masalah, pelembab Tidak → skor 2, BAIK', () {
    const logic = FootCareLogic(
      kondisiKaki: {'Tidak ada masalah'},
      memeriksaSepatu: 'Ya',
      mengeringkanKaki: 'Ya',
      menggunakanAlasKaki: 'Ya',
      menggunakanPelembab: 'Tidak',
    );
    expect(logic.hitungSkorRisiko(), 2);
    expect(logic.getStatusKondisi(), 'BAIK - Pertahankan Perawatan');
    expect(
        logic.getDeskripsiObservasi(),
        startsWith(
            'Kondisi kaki tidak ada masalah, selalu cek bagian dalam sepatu'));
    expect(logic.getRekomendasi().first,
        startsWith('Gunakan pelembab atau lotion setiap hari'));
  });

  test('perawatan kaki: luka → skor tinggi', () {
    const logic = FootCareLogic(
      kondisiKaki: {'Lepuh, luka gores, atau sayatan'},
      memeriksaSepatu: 'Ya',
      mengeringkanKaki: 'Ya',
      menggunakanAlasKaki: 'Ya',
      menggunakanPelembab: 'Ya',
    );
    expect(logic.hitungSkorRisiko(), 10);
    expect(logic.getStatusKondisi(), 'TINGGI - Perlu Perhatian Medis Segera');
  });

  test('stress: senang, tekanan darah kosong sama dengan catatan aplikasi', () {
    const logic =
        StressLogic(tekananDarah: '', selectedPerasaan: 'Perasaan Senang');
    expect(logic.hitungSkorStress(), 0);
    expect(logic.getStatusStress(), 'BAIK - Pertahankan');
    expect(logic.getAnalisaTekananDarah(), 'Tekanan darah tidak diisi');
    expect(logic.getAnalisisPerasaan(),
        startsWith('✅ Kondisi emosional positif'));
    expect(logic.getDeskripsiObservasi(),
        startsWith('Tekanan darah tidak diisi dengan kondisi emosional perasaan senang.'));
    expect(logic.getRekomendasi().first,
        startsWith('Stress dapat meningkatkan kadar gula darah'));
  });

  test('stress: cemas + 145/95 → skor 15, TINGGI', () {
    const logic =
        StressLogic(tekananDarah: '145/95', selectedPerasaan: 'Perasaan Cemas');
    expect(logic.hitungSkorStress(), 15);
    expect(logic.getStatusStress(), 'TINGGI - Perlu Konseling Profesional');
  });

  test('obat: satuan bawaan sama dengan aplikasi', () {
    expect(MedicationLogic.defaultSatuan('Insulin'), 'Unit');
    expect(MedicationLogic.defaultSatuan('Metformin'), 'Tablet');
    expect(MedicationLogic.jenisObatList, contains('Metformin'));
  });
}
