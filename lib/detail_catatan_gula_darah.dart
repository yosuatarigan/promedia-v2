// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'glucose_service.dart';

// class DetailCatatanGulaDarahScreen extends StatefulWidget {
//   const DetailCatatanGulaDarahScreen({super.key});

//   @override
//   State<DetailCatatanGulaDarahScreen> createState() =>
//       _DetailCatatanGulaDarahScreenState();
// }

// class _DetailCatatanGulaDarahScreenState
//     extends State<DetailCatatanGulaDarahScreen> {
//   final GlucoseService _glucoseService = GlucoseService();

//   DateTime selectedDate = DateTime.now();
//   Map<String, dynamic>? userData;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final data = await _glucoseService.getCurrentUserData();
//     if (mounted) {
//       setState(() {
//         userData = data;
//         isLoading = false;
//       });
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

//   Color _getStatusColor(String? color) {
//     switch (color) {
//       case 'green':
//         return Colors.green;
//       case 'blue':
//         return Colors.blue;
//       case 'orange':
//         return Colors.orange;
//       case 'red':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   void _showDetailDialog(Map<String, dynamic> data) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Detail Gula Darah',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 const Divider(),
//                 const SizedBox(height: 16),

//                 // Info Umum
//                 _buildInfoRow('Tanggal',
//                     DateFormat('dd MMMM yyyy').format(selectedDate)),
//                 _buildInfoRow('Waktu', data['jam'] ?? '-'),
//                 _buildInfoRow('Dicatat oleh', data['userName'] ?? '-'),
//                 const SizedBox(height: 16),
//                 const Divider(),
//                 const SizedBox(height: 16),

//                 // Gula Darah Puasa
//                 if (data['gulaDarahPuasa'] != null) ...[
//                   _buildGlucoseSection(
//                     'Gula Darah Puasa',
//                     data['gulaDarahPuasa'],
//                     data['statusPuasa'],
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 // Gula Darah Sewaktu
//                 if (data['gulaDarahSewaktu'] != null) ...[
//                   _buildGlucoseSection(
//                     'Gula Darah Sewaktu',
//                     data['gulaDarahSewaktu'],
//                     data['statusSewaktu'],
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 // Gula Darah 2 Jam PP
//                 if (data['gulaDarah2JamPP'] != null) ...[
//                   _buildGlucoseSection(
//                     'Gula Darah 2 Jam PP',
//                     data['gulaDarah2JamPP'],
//                     data['status2JamPP'],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 13,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//           const Text(': '),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGlucoseSection(
//       String title, int value, Map<String, dynamic>? statusData) {
//     if (statusData == null) return const SizedBox.shrink();

//     final status = statusData['status'] ?? '';
//     final color = _getStatusColor(statusData['color']);
//     final description = statusData['description'] ?? '';
//     final recommendations =
//         statusData['recommendations'] as List<dynamic>? ?? [];

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Text(
//                 '$value mg/dL',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: color,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   status,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Colors.black87,
//               height: 1.5,
//             ),
//           ),
//           if (recommendations.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             const Text(
//               'Rekomendasi:',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             ...recommendations.map((rec) => Padding(
//                   padding: const EdgeInsets.only(bottom: 6),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('• ', style: TextStyle(fontSize: 13)),
//                       Expanded(
//                         child: Text(
//                           rec.toString(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             height: 1.4,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),
//           ],
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteLog(String logId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Hapus Data'),
//         content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text(
//               'Hapus',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await _glucoseService.deleteGlucoseLog(logId);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Data berhasil dihapus'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
//           ),
//         ),
//       );
//     }

//     if (userData == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text('Data user tidak ditemukan'),
//         ),
//       );
//     }

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
//           'Detail Gula Darah',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           // Date Selector
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: InkWell(
//               onTap: _selectDate,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF5F5F5),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.calendar_today, color: Color(0xFFB83B7E)),
//                     const SizedBox(width: 12),
//                     Text(
//                       DateFormat('EEEE, dd MMMM yyyy').format(selectedDate),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // List of Logs
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _glucoseService.getGlucoseLogsByDate(
//                 userData!['noKode'],
//                 selectedDate,
//               ),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       valueColor:
//                           AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
//                     ),
//                   );
//                 }

//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.article_outlined,
//                           size: 80,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Belum ada data',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Data gula darah akan muncul di sini',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 final logs = snapshot.data!.docs;

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: logs.length,
//                   itemBuilder: (context, index) {
//                     final doc = logs[index];
//                     final data = doc.data() as Map<String, dynamic>;
//                     final isOwner = data['userId'] == userData?['userId'];

//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.access_time,
//                                         size: 16, color: Color(0xFFB83B7E)),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       '${data['jam']} WIB',
//                                       style: const TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.info_outline,
//                                           color: Color(0xFFB83B7E)),
//                                       onPressed: () => _showDetailDialog(data),
//                                       padding: EdgeInsets.zero,
//                                       constraints: const BoxConstraints(),
//                                     ),
//                                     if (isOwner)
//                                       IconButton(
//                                         icon: const Icon(Icons.delete_outline,
//                                             color: Colors.red),
//                                         onPressed: () => _deleteLog(doc.id),
//                                         padding: EdgeInsets.zero,
//                                         constraints: const BoxConstraints(),
//                                       ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Row(
//                               children: [
//                                 if (data['gulaDarahPuasa'] != null)
//                                   Expanded(
//                                     child: _buildGlucoseItem(
//                                       'Puasa',
//                                       data['gulaDarahPuasa'],
//                                       data['statusPuasa'],
//                                     ),
//                                   ),
//                                 if (data['gulaDarahSewaktu'] != null)
//                                   Expanded(
//                                     child: _buildGlucoseItem(
//                                       'Sewaktu',
//                                       data['gulaDarahSewaktu'],
//                                       data['statusSewaktu'],
//                                     ),
//                                   ),
//                                 if (data['gulaDarah2JamPP'] != null)
//                                   Expanded(
//                                     child: _buildGlucoseItem(
//                                       '2 Jam PP',
//                                       data['gulaDarah2JamPP'],
//                                       data['status2JamPP'],
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Dicatat oleh: ${data['userName']}',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGlucoseItem(
//       String label, int value, Map<String, dynamic>? statusData) {
//     final color =
//         statusData != null ? _getStatusColor(statusData['color']) : Colors.grey;
//     final status = statusData?['status'] ?? '';

//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 11, color: Colors.black54),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '$value',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Text(
//             status,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }