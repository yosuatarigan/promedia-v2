import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promedia_v2/food_item.dart';
import 'package:promedia_v2/food_widget.dart';

class PengelolaanMakananScreen extends StatefulWidget {
  const PengelolaanMakananScreen({super.key});

  @override
  State<PengelolaanMakananScreen> createState() => _PengelolaanMakananScreenState();
}

class _PengelolaanMakananScreenState extends State<PengelolaanMakananScreen> {
  // Kategori Makan
  String? selectedKategori;
  String? selectedWaktu;
  TimeOfDay? selectedJam;

  // Jenis Makanan dari TKPI
  FoodItem? selectedFood;
  final TextEditingController _gramController = TextEditingController();

  String get kategoriMakanText {
    if (selectedWaktu != null && selectedJam != null && selectedKategori != null) {
      final jam = '${selectedJam!.hour.toString().padLeft(2, '0')}.${selectedJam!.minute.toString().padLeft(2, '0')}';
      return '$selectedWaktu $jam  $selectedKategori';
    }
    return '';
  }

  void _showKategoriMakanSheet() {
    String? tempKategori = selectedKategori;
    String? tempWaktu = selectedWaktu;
    TimeOfDay? tempJam = selectedJam;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF5D2E46),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Kategori Makan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Snack', tempKategori == 'Snack', () {
                      setModalState(() => tempKategori = 'Snack');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Makan Utama', tempKategori == 'Makan Utama', () {
                      setModalState(() => tempKategori = 'Makan Utama');
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Waktu Makan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Hari ------', false, () {}),
                    const SizedBox(width: 12),
                    _buildChip(
                      tempJam != null
                          ? 'Jam ${tempJam!.hour.toString().padLeft(2, '0')}.${tempJam!.minute.toString().padLeft(2, '0')} WIB'
                          : 'Jam --.-- WIB',
                      false,
                      () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: tempJam ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setModalState(() => tempJam = time);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip('Pagi', tempWaktu == 'Pagi', () {
                      setModalState(() => tempWaktu = 'Pagi');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Siang', tempWaktu == 'Siang', () {
                      setModalState(() => tempWaktu = 'Siang');
                    }),
                    const SizedBox(width: 12),
                    _buildChip('Malam', tempWaktu == 'Malam', () {
                      setModalState(() => tempWaktu = 'Malam');
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedKategori = tempKategori;
                      selectedWaktu = tempWaktu;
                      selectedJam = tempJam;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFoodSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Pilih Makanan dari TKPI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the close button
                  ],
                ),
              ),
              Expanded(
                child: FoodListWithCategory(
                  onFoodSelected: (food) {
                    setState(() {
                      selectedFood = food as FoodItem?;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFB83B7E),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grams = double.tryParse(_gramController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengelolaan Makanan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pilih kategori, makanan dari database TKPI (120+ item), dan masukkan jumlah dalam gram',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kategori Makan
            const Text(
              'Kategori Makan :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showKategoriMakanSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB83B7E).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: Color(0xFFB83B7E), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        kategoriMakanText.isEmpty ? 'Pilih Kategori Makan' : kategoriMakanText,
                        style: TextStyle(
                          color: kategoriMakanText.isEmpty ? const Color(0xFFB83B7E) : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFB83B7E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Jenis Makanan
            const Text(
              'Jenis Makanan :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showFoodSearchSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFB83B7E).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu, color: Color(0xFFB83B7E), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFood?.name ?? 'Pilih Makanan dari TKPI',
                        style: TextStyle(
                          color: selectedFood == null ? const Color(0xFFB83B7E) : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.search, color: Color(0xFFB83B7E), size: 20),
                  ],
                ),
              ),
            ),

            if (selectedFood != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Data Gizi per 100g:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip('${selectedFood!.energyKcal.toStringAsFixed(0)} kkal', Colors.orange),
                        _buildInfoChip('${selectedFood!.carbohydrate.toStringAsFixed(1)}g karbo', Colors.blue),
                        _buildInfoChip('${selectedFood!.protein.toStringAsFixed(1)}g protein', Colors.red),
                        _buildInfoChip('${selectedFood!.fat.toStringAsFixed(1)}g lemak', Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Input Jumlah Gram
            const Text(
              'Jumlah (gram) :',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _gramController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Contoh: 150',
                prefixIcon: const Icon(Icons.scale, color: Color(0xFFB83B7E)),
                suffixText: 'gram',
                filled: true,
                fillColor: const Color(0xFFFCE4EC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: const Color(0xFFB83B7E).withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFB83B7E), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) => setState(() {}),
            ),

            if (selectedFood != null && grams > 0) ...[
              const SizedBox(height: 24),
              FoodNutritionDetail(
                food: selectedFood!,
                grams: grams,
              ),
            ],

            const SizedBox(height: 40),

            // Tombol Simpan
            Center(
              child: ElevatedButton.icon(
                onPressed: selectedFood != null && grams > 0
                    ? () {
                        final calories = selectedFood!.calculateCalories(grams);
                        final carbs = selectedFood!.calculateCarbs(grams);
                        
                        // TODO: Simpan data ke Firebase
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berhasil! ${selectedFood!.name} (${grams.toStringAsFixed(0)}g) = ${calories.toStringAsFixed(0)} kkal, ${carbs.toStringAsFixed(1)}g karbo',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Simpan Data Makanan',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB83B7E),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gramController.dispose();
    super.dispose();
  }
}