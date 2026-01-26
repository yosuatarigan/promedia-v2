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
      child: const Row(
        children: [
          Text(
            'Message Framing',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
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
                  const PopupMenuItem(value: 'send', child: Text('Kirim Pesan')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
                onSelected: (value) {
                  if (value == 'send') _showSendTargetDialog(data);
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

  // ========== DIALOG UNTUK PILIH TARGET PENGIRIMAN ==========
  void _showSendTargetDialog(Map<String, dynamic> messageData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Kirim Pesan Edukasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih target penerima pesan:',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _buildTargetButton(
              icon: Icons.person,
              label: 'Pilih Pasien',
              color: const Color(0xFFB83B7E),
              onTap: () {
                Navigator.pop(context);
                _showCustomMessageDialog(messageData, targetType: 'pasien');
              },
            ),
            const SizedBox(height: 12),
            _buildTargetButton(
              icon: Icons.people,
              label: 'Pilih Keluarga',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _showCustomMessageDialog(messageData, targetType: 'keluarga');
              },
            ),
            const SizedBox(height: 12),
            _buildTargetButton(
              icon: Icons.groups,
              label: 'Semua Pasien',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _showCustomMessageDialog(messageData, targetType: 'semua_pasien');
              },
            ),
            const SizedBox(height: 12),
            _buildTargetButton(
              icon: Icons.family_restroom,
              label: 'Semua Keluarga',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _showCustomMessageDialog(messageData, targetType: 'semua_keluarga');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  // ========== DIALOG CUSTOM MESSAGE ==========
  void _showCustomMessageDialog(
    Map<String, dynamic> originalData, {
    required String targetType,
  }) {
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _handleSendByTargetType(
                messageController.text,
                originalData['materi'],
                originalData['subMateri'],
                targetType,
              );
            },
            style: ElevatedButton.styleFrom(
              // backgroundColor: const Color(0xFFB83B7E),
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  // ========== HANDLE PENGIRIMAN BERDASARKAN TARGET TYPE ==========
  void _handleSendByTargetType(
    String message,
    String materi,
    String subMateri,
    String targetType,
  ) {
    switch (targetType) {
      case 'pasien':
        _showSelectPasienDialog(message, materi, subMateri);
        break;
      case 'keluarga':
        _showSelectKeluargaDialog(message, materi, subMateri);
        break;
      case 'semua_pasien':
        _showConfirmSendToAllPasien(message, materi, subMateri);
        break;
      case 'semua_keluarga':
        _sendToAllKeluarga(message, materi, subMateri);
        break;
    }
  }

  // ========== DIALOG PILIH PASIEN (DENGAN CHECKBOX KIRIM KE KELUARGA) ==========
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
        onPasienSelected: (selectedPasienIds, sendToFamily) async {
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
          
          if (sendToFamily) {
            await _sendToPasienAndFamily(message, materi, subMateri, selectedPasienIds);
          } else {
            await _sendToPasienOnly(message, materi, subMateri, selectedPasienIds);
          }
        },
      ),
    );
  }

  // ========== DIALOG PILIH KELUARGA ==========
  void _showSelectKeluargaDialog(String message, String materi, String subMateri) async {
    final keluargaSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'keluarga')
        .get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => _SelectKeluargaDialog(
        keluargaDocs: keluargaSnapshot.docs,
        onKeluargaSelected: (selectedKeluargaIds) async {
          if (selectedKeluargaIds.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pilih minimal 1 keluarga'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          Navigator.pop(context);
          await _sendToKeluarga(message, materi, subMateri, selectedKeluargaIds);
        },
      ),
    );
  }

  // ========== KONFIRMASI KIRIM KE SEMUA PASIEN (DENGAN CHECKBOX) ==========
  void _showConfirmSendToAllPasien(String message, String materi, String subMateri) async {
    bool sendToFamily = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Kirim ke Semua Pasien'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pesan akan dikirim ke semua pasien terdaftar.'),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: sendToFamily,
                onChanged: (value) {
                  setState(() {
                    sendToFamily = value ?? false;
                  });
                },
                title: const Text(
                  'Kirim ke semua keluarga juga?',
                  style: TextStyle(fontSize: 14),
                ),
                activeColor: const Color(0xFFB83B7E),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      if (sendToFamily) {
        await _sendToAllPasienAndFamily(message, materi, subMateri);
      } else {
        await _sendToAllPasienOnly(message, materi, subMateri);
      }
    }
  }

  // ========== METHOD PENGIRIMAN ==========
  
  // Kirim ke pasien saja
  Future<void> _sendToPasienOnly(
    String message,
    String materi,
    String subMateri,
    List<String> pasienIds,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToPasien(
        message: message,
        materi: materi,
        subMateri: subMateri,
        pasienIds: pasienIds,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengirim ke ${pasienIds.length} pasien'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Kirim ke pasien + keluarga dengan noKode sama
  Future<void> _sendToPasienAndFamily(
    String message,
    String materi,
    String subMateri,
    List<String> pasienIds,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToPasienAndFamily(
        message: message,
        materi: materi,
        subMateri: subMateri,
        pasienIds: pasienIds,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengirim ke pasien dan keluarga terkait'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Kirim ke semua pasien saja
  Future<void> _sendToAllPasienOnly(
    String message,
    String materi,
    String subMateri,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToAllPasien(
        message: message,
        materi: materi,
        subMateri: subMateri,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengirim ke semua pasien'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Kirim ke semua pasien + semua keluarga
  Future<void> _sendToAllPasienAndFamily(
    String message,
    String materi,
    String subMateri,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToAllPasienAndFamily(
        message: message,
        materi: materi,
        subMateri: subMateri,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengirim ke semua pasien dan keluarga'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Kirim ke keluarga terpilih
  Future<void> _sendToKeluarga(
    String message,
    String materi,
    String subMateri,
    List<String> keluargaIds,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToKeluarga(
        message: message,
        materi: materi,
        subMateri: subMateri,
        keluargaIds: keluargaIds,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil mengirim ke ${keluargaIds.length} keluarga'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Kirim ke semua keluarga
  Future<void> _sendToAllKeluarga(
    String message,
    String materi,
    String subMateri,
  ) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB83B7E)),
          ),
        ),
      );

      await _service.sendMessageToAllKeluarga(
        message: message,
        materi: materi,
        subMateri: subMateri,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil mengirim ke semua keluarga'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========== DIALOG & METHOD LAINNYA (TIDAK BERUBAH) ==========

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
}

// ========== DIALOG PILIH PASIEN (DENGAN CHECKBOX) ==========
class _SelectPasienDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> pasienDocs;
  final Function(List<String>, bool) onPasienSelected;

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
  bool _sendToFamily = false;

  @override
  Widget build(BuildContext context) {
    var filteredPasien = widget.pasienDocs;

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
        height: 650,
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
            const Divider(),
            // CHECKBOX KIRIM KE KELUARGA
            CheckboxListTile(
              value: _sendToFamily,
              onChanged: (value) {
                setState(() {
                  _sendToFamily = value ?? false;
                });
              },
              title: const Text(
                'Kirim ke keluarga juga?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Pesan akan dikirim ke keluarga dengan no. kode yang sama',
                style: TextStyle(fontSize: 12),
              ),
              activeColor: const Color(0xFFB83B7E),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
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
                      : () => widget.onPasienSelected(
                            _selectedPasienIds.toList(),
                            _sendToFamily,
                          ),
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

// ========== DIALOG PILIH KELUARGA ==========
class _SelectKeluargaDialog extends StatefulWidget {
  final List<QueryDocumentSnapshot> keluargaDocs;
  final Function(List<String>) onKeluargaSelected;

  const _SelectKeluargaDialog({
    required this.keluargaDocs,
    required this.onKeluargaSelected,
  });

  @override
  State<_SelectKeluargaDialog> createState() => _SelectKeluargaDialogState();
}

class _SelectKeluargaDialogState extends State<_SelectKeluargaDialog> {
  final Set<String> _selectedKeluargaIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var filteredKeluarga = widget.keluargaDocs;

    if (_searchQuery.isNotEmpty) {
      filteredKeluarga = filteredKeluarga.where((doc) {
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
                    'Pilih Keluarga',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_selectedKeluargaIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedKeluargaIds.length} dipilih',
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
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedKeluargaIds.length == filteredKeluarga.length) {
                        _selectedKeluargaIds.clear();
                      } else {
                        _selectedKeluargaIds.clear();
                        for (var doc in filteredKeluarga) {
                          _selectedKeluargaIds.add(doc.id);
                        }
                      }
                    });
                  },
                  icon: Icon(
                    _selectedKeluargaIds.length == filteredKeluarga.length
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 20,
                  ),
                  label: Text(
                    _selectedKeluargaIds.length == filteredKeluarga.length
                        ? 'Batalkan Semua'
                        : 'Pilih Semua',
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: filteredKeluarga.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada keluarga ditemukan',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredKeluarga.length,
                      itemBuilder: (context, index) {
                        final doc = filteredKeluarga[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final isSelected = _selectedKeluargaIds.contains(doc.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: isSelected ? 3 : 1,
                          color: isSelected
                              ? Colors.orange.shade50
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.orange
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedKeluargaIds.add(doc.id);
                                } else {
                                  _selectedKeluargaIds.remove(doc.id);
                                }
                              });
                            },
                            activeColor: Colors.orange,
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange.withOpacity(0.1),
                                  child: Text(
                                    data['namaLengkap']?.substring(0, 1).toUpperCase() ?? 'K',
                                    style: const TextStyle(
                                      color: Colors.orange,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _selectedKeluargaIds.isEmpty
                      ? null
                      : () => widget.onKeluargaSelected(_selectedKeluargaIds.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                    'Kirim (${_selectedKeluargaIds.length})',
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