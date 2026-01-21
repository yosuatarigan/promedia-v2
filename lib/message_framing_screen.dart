import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:promedia_v2/message_framing_service.dart';
import 'package:promedia_v2/message_framing_template.dart';

class MessageFramingScreen extends StatefulWidget {
  const MessageFramingScreen({super.key});

  @override
  State<MessageFramingScreen> createState() => _MessageFramingScreenState();
}

class _MessageFramingScreenState extends State<MessageFramingScreen> {
  final MessageFramingService _service = MessageFramingService();
  final _firestore = FirebaseFirestore.instance;
  String _selectedMateri = 'Semua';
  bool _isImporting = false;

  final List<String> _materiList = [
    'Semua',
    'Konsep DM',
    'Diet',
    'Merokok',
    'Aktivitas Fisik',
    'Manajemen Hipo dan Hiperglikemia',
    'SMBG',
    'Perawatan Kaki',
    'Pengobatan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(child: _buildMessageList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFB83B7E),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesan'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Message Framing',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // StreamBuilder<QuerySnapshot>(
          //   stream: _service.getAllMessageFraming(),
          //   builder: (context, snapshot) {
          //     final isEmpty = !snapshot.hasData || snapshot.data!.docs.isEmpty;
              
          //     if (isEmpty) {
          //       return ElevatedButton.icon(
          //         onPressed: _isImporting ? null : _importTemplate,
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: const Color(0xFFB83B7E),
          //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //         ),
          //         icon: _isImporting 
          //             ? const SizedBox(
          //                 width: 16,
          //                 height: 16,
          //                 child: CircularProgressIndicator(
          //                   strokeWidth: 2,
          //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //                 ),
          //               )
          //             : const Icon(Icons.download),
          //         label: Text(_isImporting ? 'Importing...' : 'Import Template'),
          //       );
          //     }
              
          //     return Row(
          //       children: [
          //         OutlinedButton.icon(
          //           onPressed: _isImporting ? null : _importTemplate,
          //           style: OutlinedButton.styleFrom(
          //             foregroundColor: const Color(0xFFB83B7E),
          //             side: const BorderSide(color: Color(0xFFB83B7E)),
          //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //           ),
          //           icon: _isImporting 
          //               ? const SizedBox(
          //                   width: 16,
          //                   height: 16,
          //                   child: CircularProgressIndicator(
          //                     strokeWidth: 2,
          //                     valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          //                   ),
          //                 )
          //               : const Icon(Icons.refresh, size: 18),
          //           label: Text(_isImporting ? 'Importing...' : 'Reset Template'),
          //         ),
          //         const SizedBox(width: 12),
          //         ElevatedButton.icon(
          //           onPressed: () => _showSendToAllDialog(),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.green,
          //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //           ),
          //           icon: const Icon(Icons.send),
          //           label: const Text('Kirim ke Semua Pasien'),
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Text('Filter Materi: ', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _selectedMateri,
            items: _materiList.map((materi) {
              return DropdownMenuItem(value: materi, child: Text(materi));
            }).toList(),
            onChanged: (value) => setState(() => _selectedMateri = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _service.getAllMessageFraming(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Belum ada message framing', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        var messages = snapshot.data!.docs;

        // Filter berdasarkan materi
        if (_selectedMateri != 'Semua') {
          messages = messages.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['materi'] == _selectedMateri;
          }).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildMessageCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildMessageCard(String id, Map<String, dynamic> data) {
    final materi = data['materi'] ?? '-';
    final subMateri = data['subMateri'] ?? '-';
    final message = data['message'] ?? '-';
    final hari = data['hari'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB83B7E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hari $hari',
                  style: const TextStyle(
                    color: Color(0xFFB83B7E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  materi,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'send', child: Text('Kirim ke Pasien')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
                onSelected: (value) {
                  if (value == 'send') _showSendToPasienDialog(id);
                  if (value == 'edit') _showAddEditDialog(id: id, data: data);
                  if (value == 'delete') _confirmDelete(id);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subMateri,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({String? id, Map<String, dynamic>? data}) {
    final isEdit = id != null;
    final materiController = TextEditingController(text: data?['materi'] ?? '');
    final subMateriController = TextEditingController(text: data?['subMateri'] ?? '');
    final messageController = TextEditingController(text: data?['message'] ?? '');
    final hariController = TextEditingController(text: data?['hari']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Pesan' : 'Tambah Pesan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: materiController.text.isEmpty ? null : materiController.text,
                decoration: const InputDecoration(labelText: 'Materi'),
                items: _materiList.skip(1).map((m) {
                  return DropdownMenuItem(value: m, child: Text(m));
                }).toList(),
                onChanged: (value) => materiController.text = value ?? '',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subMateriController,
                decoration: const InputDecoration(labelText: 'Sub Materi'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Pesan Edukasi'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hariController,
                decoration: const InputDecoration(labelText: 'Hari ke-'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (isEdit) {
                  await _service.updateMessageFraming(
                    id: id,
                    materi: materiController.text,
                    subMateri: subMateriController.text,
                    message: messageController.text,
                    hari: int.parse(hariController.text),
                  );
                } else {
                  await _service.addMessageFraming(
                    materi: materiController.text,
                    subMateri: subMateriController.text,
                    message: messageController.text,
                    hari: int.parse(hariController.text),
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Pesan berhasil diupdate' : 'Pesan berhasil ditambahkan')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB83B7E)),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _service.deleteMessageFraming(id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesan berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showSendToPasienDialog(String messageId) async {
    // Get message data
    final messageDoc = await _firestore
        .collection('message_framing')
        .doc(messageId)
        .get();

    if (!messageDoc.exists) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesan tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final messageData = messageDoc.data()!;
    
    // Show custom message dialog
    if (mounted) {
      _showCustomMessageDialog(messageData, messageId);
    }
  }

  void _showSendToAllDialog() async {
    // Get semua pesan
    final messagesSnapshot = await _firestore
        .collection('message_framing')
        .orderBy('hari')
        .orderBy('materi')
        .get();

    if (messagesSnapshot.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada pesan. Silakan import template terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!mounted) return;

    // Show dialog untuk pilih pesan
    showDialog(
      context: context,
      builder: (context) => _SelectMessageDialog(
        messages: messagesSnapshot.docs,
        onMessageSelected: (messageData, messageId) {
          Navigator.pop(context);
          _showCustomMessageDialog(messageData, messageId);
        },
      ),
    );
  }

  void _showCustomMessageDialog(Map<String, dynamic> originalData, String messageId) {
    final messageController = TextEditingController(text: originalData['message']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Custom Pesan Edukasi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                originalData['materi'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              originalData['subMateri'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit pesan sesuai kebutuhan:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan edukasi...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showSelectPasienDialog(
                messageController.text,
                originalData['materi'],
                originalData['subMateri'],
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB83B7E),
              side: const BorderSide(color: Color(0xFFB83B7E)),
            ),
            icon: const Icon(Icons.person, size: 18),
            label: const Text('Pilih Pasien'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _sendToAllPasien(
                messageController.text,
                originalData['materi'],
                originalData['subMateri'],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Kirim ke Semua'),
          ),
        ],
      ),
    );
  }

  void _showSelectPasienDialog(String message, String materi, String subMateri) async {
    final pasienSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'pasien')
        .get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _SelectPasienDialog(
        pasienDocs: pasienSnapshot.docs,
        onPasienSelected: (selectedPasienIds) async {
          if (selectedPasienIds.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih minimal 1 pasien'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          Navigator.pop(context);
          await _sendToSelectedPasien(
            message,
            materi,
            subMateri,
            selectedPasienIds,
          );
        },
      ),
    );
  }

  Future<void> _sendToAllPasien(String message, String materi, String subMateri) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      // Get all pasien
      final pasienSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pasien')
          .get();

      // Send to each pasien
      final batch = _firestore.batch();
      for (var pasien in pasienSnapshot.docs) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasien.id,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengirim ke ${pasienSnapshot.docs.length} pasien'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendToSelectedPasien(
    String message,
    String materi,
    String subMateri,
    List<String> pasienIds,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      // Send to selected pasien
      final batch = _firestore.batch();
      for (var pasienId in pasienIds) {
        final reminderRef = _firestore.collection('reminders').doc();
        batch.set(reminderRef, {
          'toUserId': pasienId,
          'type': 'edukasi',
          'materi': materi,
          'subMateri': subMateri,
          'message': message,
          'fromAdmin': true,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengirim ke ${pasienIds.length} pasien'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importTemplate() async {
    // Konfirmasi dulu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Template'),
        content: const Text(
          'Ini akan menghapus semua pesan yang ada dan mengimport 27 pesan template dari panduan. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB83B7E),
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);

    try {
      // Hapus semua data lama
      final oldData = await _firestore.collection('message_framing').get();
      final batch = _firestore.batch();
      
      for (var doc in oldData.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();

      // Import data baru
      final templateData = MessageFramingTemplate.getAllMessages();
      
      for (var message in templateData) {
        await _service.addMessageFraming(
          materi: message['materi'],
          subMateri: message['subMateri'],
          message: message['message'],
          hari: message['hari'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil import ${templateData.length} pesan template'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}

// Dialog untuk memilih pesan
class _SelectMessageDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> messages;
  final Function(Map<String, dynamic>, String) onMessageSelected;

  const _SelectMessageDialog({
    required this.messages,
    required this.onMessageSelected,
  });

  @override
  State<_SelectMessageDialog> createState() => _SelectMessageDialogState();
}

class _SelectMessageDialogState extends State<_SelectMessageDialog> {
  String _searchQuery = '';
  String _selectedMateri = 'Semua';

  @override
  Widget build(BuildContext context) {
    var filteredMessages = widget.messages;

    // Filter by materi
    if (_selectedMateri != 'Semua') {
      filteredMessages = filteredMessages.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['materi'] == _selectedMateri;
      }).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filteredMessages = filteredMessages.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final materi = data['materi']?.toLowerCase() ?? '';
        final subMateri = data['subMateri']?.toLowerCase() ?? '';
        final message = data['message']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return materi.contains(query) ||
            subMateri.contains(query) ||
            message.contains(query);
      }).toList();
    }

    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Pesan Edukasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari pesan...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            // Filter materi
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Konsep DM'),
                  _buildFilterChip('Diet'),
                  _buildFilterChip('Merokok'),
                  _buildFilterChip('Aktivitas Fisik'),
                  _buildFilterChip('Manajemen Hipo dan Hiperglikemia'),
                  _buildFilterChip('SMBG'),
                  _buildFilterChip('Perawatan Kaki'),
                  _buildFilterChip('Pengobatan'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List pesan
            Expanded(
              child: filteredMessages.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada pesan ditemukan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredMessages.length,
                      itemBuilder: (context, index) {
                        final doc = filteredMessages[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildMessageCard(data, doc.id);
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedMateri == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedMateri = label);
        },
        selectedColor: const Color(0xFFB83B7E).withOpacity(0.2),
        checkmarkColor: const Color(0xFFB83B7E),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFB83B7E) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> data, String id) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onMessageSelected(data, id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB83B7E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Hari ${data['hari']}',
                      style: const TextStyle(
                        color: Color(0xFFB83B7E),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data['materi'],
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data['subMateri'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data['message'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog untuk memilih pasien
class _SelectPasienDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> pasienDocs;
  final Function(List<String>) onPasienSelected;

  const _SelectPasienDialog({
    required this.pasienDocs,
    required this.onPasienSelected,
  });

  @override
  State<_SelectPasienDialog> createState() => _SelectPasienDialogState();
}

class _SelectPasienDialogState extends State<_SelectPasienDialog> {
  final Set<String> _selectedPasienIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var filteredPasien = widget.pasienDocs;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filteredPasien = filteredPasien.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final nama = data['namaLengkap']?.toLowerCase() ?? '';
        final noKode = data['noKode']?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return nama.contains(query) || noKode.contains(query);
      }).toList();
    }

    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih Pasien',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_selectedPasienIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB83B7E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedPasienIds.length} dipilih',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Search bar
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. kode...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Select all / deselect all
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedPasienIds.length == filteredPasien.length) {
                        _selectedPasienIds.clear();
                      } else {
                        _selectedPasienIds.clear();
                        for (var doc in filteredPasien) {
                          _selectedPasienIds.add(doc.id);
                        }
                      }
                    });
                  },
                  icon: Icon(
                    _selectedPasienIds.length == filteredPasien.length
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                  ),
                  label: Text(
                    _selectedPasienIds.length == filteredPasien.length
                        ? 'Batalkan Semua'
                        : 'Pilih Semua',
                  ),
                ),
              ],
            ),
            const Divider(),
            // List pasien
            Expanded(
              child: filteredPasien.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada pasien ditemukan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPasien.length,
                      itemBuilder: (context, index) {
                        final doc = filteredPasien[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final isSelected = _selectedPasienIds.contains(doc.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 3 : 1,
                          color: isSelected
                              ? const Color(0xFFFFF5F8)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFB83B7E)
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedPasienIds.add(doc.id);
                                } else {
                                  _selectedPasienIds.remove(doc.id);
                                }
                              });
                            },
                            activeColor: const Color(0xFFB83B7E),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFB83B7E).withOpacity(0.1),
                                  child: Text(
                                    data['namaLengkap']?.substring(0, 1).toUpperCase() ?? 'P',
                                    style: const TextStyle(
                                      color: Color(0xFFB83B7E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['namaLengkap'] ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'No. Kode: ${data['noKode'] ?? '-'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _selectedPasienIds.isEmpty
                      ? null
                      : () => widget.onPasienSelected(_selectedPasienIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB83B7E),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                    'Kirim (${_selectedPasienIds.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}