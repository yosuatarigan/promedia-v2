// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'glucose_service.dart';

// class CatatanGulaDarahScreen extends StatefulWidget {
//   const CatatanGulaDarahScreen({super.key});

//   @override
//   State<CatatanGulaDarahScreen> createState() =>
//       _CatatanGulaDarahScreenState();
// }

// class _CatatanGulaDarahScreenState extends State<CatatanGulaDarahScreen> {
//   final GlucoseService _glucoseService = GlucoseService();
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _gulaDarahPuasaController =
//       TextEditingController();
//   final TextEditingController _gulaDarahSewaktuController =
//       TextEditingController();
//   final TextEditingController _gulaDarah2JamPPController =
//       TextEditingController();

//   DateTime selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//   bool isLoading = false;
//   Map<String, dynamic>? userData;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   @override
//   void dispose() {
//     _gulaDarahPuasaController.dispose();
//     _gulaDarahSewaktuController.dispose();
//     _gulaDarah2JamPPController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     final data = await _glucoseService.getCurrentUserData();
//     if (mounted) {
//       setState(() => userData = data);
//     }
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFB83B7E),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != selectedDate) {
//       setState(() => selectedDate = picked);
//     }
//   }

//   Future<void> _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFB83B7E),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != selectedTime) {
//       setState(() => selectedTime = picked);
//     }
//   }

//   Future<void> _simpanData() async {
//     // Validate at least one field filled
//     if (_gulaDarahPuasaController.text.isEmpty &&
//         _gulaDarahSewaktuController.text.isEmpty &&
//         _gulaDarah2JamPPController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Minimal satu jenis gula darah harus diisi'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final jam = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

//       await _glucoseService.addGlucoseLog(
//         noKode: userData!['noKode'],
//         tanggal: selectedDate,
//         jam: jam,
//         gulaDarahPuasa: _gulaDarahPuasaController.text.isNotEmpty
//             ? int.parse(_gulaDarahPuasaController.text)
//             : null,
//         gulaDarahSewaktu: _gulaDarahSewaktuController.text.isNotEmpty
//             ? int.parse(_gulaDarahSewaktuController.text)
//             : null,
//         gulaDarah2JamPP: _gulaDarah2JamPPController.text.isNotEmpty
//             ? int.parse(_gulaDarah2JamPPController.text)
//             : null,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Data berhasil disimpan'),
//             backgroundColor: Colors.green,
//           ),
//         );

//         // Clear form
//         _gulaDarahPuasaController.clear();
//         _gulaDarahSewaktuController.clear();
//         _gulaDarah2JamPPController.clear();
//         setState(() {
//           selectedDate = DateTime.now();
//           selectedTime = TimeOfDay.now();
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Catatan Gula Darah',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: userData == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Info Text
//                     const Text(
//                       'Silahkan isi form dibawah ini untuk mencatat gula darah.',
//                       style: TextStyle(fontSize: 14, height: 1.5),
//                     ),
//                     const SizedBox(height: 24),

//                     // Date Picker
//                     const Text(
//                       'Tanggal',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: _selectDate,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF5F5F5),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.calendar_today,
//                                 color: Color(0xFFB83B7E)),
//                             const SizedBox(width: 12),
//                             Text(
//                               DateFormat('dd MMMM yyyy').format(selectedDate),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),

//                     // Time Picker
//                     const Text(
//                       'Waktu',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: _selectTime,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF5F5F5),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.access_time,
//                                 color: Color(0xFFB83B7E)),
//                             const SizedBox(width: 12),
//                             Text(
//                               selectedTime.format(context),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),

//                     // Gula Darah Puasa
//                     const Text(
//                       'Gula Darah Puasa :',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFB83B7E),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Text(
//                             'mg/dL',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: _gulaDarahPuasaController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Masukan Gula Darah Puasa',
//                               filled: true,
//                               fillColor: const Color(0xFFF5F5F5),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Gula Darah Sewaktu
//                     const Text(
//                       'Gula Darah Sewaktu :',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFB83B7E),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Text(
//                             'mg/dL',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: _gulaDarahSewaktuController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Masukan Gula Darah',
//                               filled: true,
//                               fillColor: const Color(0xFFF5F5F5),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     // Gula Darah 2 Jam PP
//                     const Text(
//                       'Gula Darah 2 Jam PP :',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFB83B7E),
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           child: const Text(
//                             'mg/dL',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: TextFormField(
//                             controller: _gulaDarah2JamPPController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               hintText: 'Masukan Gula Darah 2 Jam',
//                               filled: true,
//                               fillColor: const Color(0xFFF5F5F5),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 32),

//                     // Info Box
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.blue.shade200),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(Icons.info_outline,
//                               color: Colors.blue.shade700, size: 20),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Minimal satu jenis gula darah harus diisi. Anda bisa mengisi semuanya atau hanya beberapa saja.',
//                               style: TextStyle(fontSize: 12, height: 1.5),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Simpan Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: isLoading ? null : _simpanData,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFB83B7E),
//                           disabledBackgroundColor: Colors.grey.shade300,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               )
//                             : const Text(
//                                 'Simpan',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }