import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
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

  late final Stream<QuerySnapshot> _stream = _service.getAllMessageFraming();

  /// Semua materi: bawaan + kategori custom yang sudah dipakai di data.
  List<String> _allMateri = [];

  List<String> _mergeMateri(List<QueryDocumentSnapshot> docs) {
    final custom = <String>{};
    for (final d in docs) {
      final m = ((d.data() as Map<String, dynamic>)['materi'] ?? '').toString().trim();
      if (m.isNotEmpty && !_materiList.contains(m)) custom.add(m);
    }
    return [..._materiList.skip(1), ...(custom.toList()..sort())];
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      title: 'Message Framing',
      subtitle:
          'Template pesan edukasi per materi dan hari, atau tulis pesan custom untuk pasien dan keluarga.',
      scrollable: false,
      actions: [
        OutlinedButton.icon(
          onPressed: () => _showAddEditDialog(),
          icon: const Icon(Icons.library_add_outlined, size: 18),
          label: const Text('Tambah Template'),
        ),
        ElevatedButton.icon(
          onPressed: () => _showComposeDialog(),
          icon: const Icon(Icons.edit_note, size: 20),
          label: const Text('Tulis Pesan Custom'),
        ),
      ],
      child: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          _allMateri = _mergeMateri(docs);
          if (_selectedMateri != 'Semua' && !_allMateri.contains(_selectedMateri)) {
            _selectedMateri = 'Semua';
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFilterBar(['Semua', ..._allMateri]),
              const SizedBox(height: 16),
              Expanded(child: _buildMessageList(snapshot)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(List<String> materiList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: materiList.map((materi) {
          final selected = _selectedMateri == materi;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: selected ? AdminColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _selectedMateri = materi),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color:
                          selected ? AdminColors.primary : AdminColors.border,
                    ),
                  ),
                  child: Text(
                    materi,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AdminColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return AdminCard(
        child: AdminEmptyState(
          icon: Icons.error_outline,
          title: 'Gagal memuat message framing',
          message: '${snapshot.error}',
        ),
      );
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    var messages = snapshot.data!.docs;
    if (_selectedMateri != 'Semua') {
      messages = messages.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['materi'] == _selectedMateri;
      }).toList();
    }

    if (messages.isEmpty) {
      return AdminCard(
        child: AdminEmptyState(
          icon: Icons.chat_bubble_outline,
          title: _selectedMateri == 'Semua'
              ? 'Belum ada message framing'
              : 'Belum ada pesan untuk materi "$_selectedMateri"',
          message: 'Klik "Tambah Template" atau "Tulis Pesan Custom".',
        ),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= 1100 ? 2 : 1;
      if (cols == 1) {
        return ListView.separated(
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = messages[index];
            return _buildMessageCard(doc.id, doc.data() as Map<String, dynamic>);
          },
        );
      }
      // Dua kolom pada layar lebar.
      final rows = <Widget>[];
      for (var i = 0; i < messages.length; i += 2) {
        final left = messages[i];
        final right = i + 1 < messages.length ? messages[i + 1] : null;
        rows.add(IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: _buildMessageCard(
                      left.id, left.data() as Map<String, dynamic>)),
              const SizedBox(width: 12),
              Expanded(
                child: right == null
                    ? const SizedBox()
                    : _buildMessageCard(
                        right.id, right.data() as Map<String, dynamic>),
              ),
            ],
          ),
        ));
      }
      return ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => rows[i],
      );
    });
  }

  Widget _buildMessageCard(String id, Map<String, dynamic> data) {
    final materi = data['materi'] ?? '-';
    final subMateri = data['subMateri'] ?? '-';
    final message = data['message'] ?? '-';
    final hari = data['hari'] ?? 0;

    return AdminCard(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminBadge('Hari $hari', color: AdminColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AdminBadge('$materi', color: AdminColors.info),
                ),
              ),
              Tooltip(
                message: 'Kirim pesan',
                child: IconButton(
                  onPressed: () => _showSendTargetDialog(data),
                  icon: const Icon(Icons.send_outlined,
                      size: 19, color: AdminColors.primary),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Aksi lain',
                icon: const Icon(Icons.more_horiz, color: AdminColors.textMuted),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'send', child: Text('Kirim pesan')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus',
                        style: TextStyle(color: AdminColors.danger)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'send') _showSendTargetDialog(data);
                  if (value == 'edit') _showAddEditDialog(id: id, data: data);
                  if (value == 'delete') _confirmDelete(id);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              subMateri,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AdminColors.text,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AdminColors.textMuted,
                height: 1.55,
              ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MessageFormDialog(
        mode: isEdit ? _MessageFormMode.editTemplate : _MessageFormMode.newTemplate,
        materiOptions: _allMateri,
        initial: data,
        onSubmit: (r) async {
          if (isEdit) {
            await _service.updateMessageFraming(
              id: id,
              materi: r.materi,
              subMateri: r.subMateri,
              message: r.message,
              hari: r.hari!,
            );
          } else {
            await _service.addMessageFraming(
              materi: r.materi,
              subMateri: r.subMateri,
              message: r.message,
              hari: r.hari!,
            );
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isEdit
                    ? 'Template berhasil diperbarui'
                    : 'Template berhasil ditambahkan')));
          }
        },
      ),
    );
  }

  /// Pesan custom: ditulis dari nol, lalu dikirim lewat alur penerima yang sama.
  void _showComposeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MessageFormDialog(
        mode: _MessageFormMode.compose,
        materiOptions: _allMateri,
        onSubmit: (r) async {
          if (r.saveAsTemplate) {
            await _service.addMessageFraming(
              materi: r.materi,
              subMateri: r.subMateri,
              message: r.message,
              hari: r.hari!,
            );
          }
          if (!mounted) return;
          _handleSendByTargetType(r.message, r.materi, r.subMateri, r.target!);
        },
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

// ========== FORM PESAN: TEMPLATE & PESAN CUSTOM ==========

enum _MessageFormMode { newTemplate, editTemplate, compose }

class _MessageFormResult {
  final String materi;
  final String subMateri;
  final String message;
  final int? hari;
  final String? target;
  final bool saveAsTemplate;

  _MessageFormResult({
    required this.materi,
    required this.subMateri,
    required this.message,
    this.hari,
    this.target,
    this.saveAsTemplate = false,
  });
}

class _MessageFormDialog extends StatefulWidget {
  final _MessageFormMode mode;
  final List<String> materiOptions;
  final Map<String, dynamic>? initial;
  final Future<void> Function(_MessageFormResult) onSubmit;

  const _MessageFormDialog({
    required this.mode,
    required this.materiOptions,
    required this.onSubmit,
    this.initial,
  });

  @override
  State<_MessageFormDialog> createState() => _MessageFormDialogState();
}

class _MessageFormDialogState extends State<_MessageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _materi;
  late final TextEditingController _subMateri;
  late final TextEditingController _message;
  late final TextEditingController _hari;
  String _target = 'pasien';
  bool _saveAsTemplate = false;
  bool _saving = false;
  bool _attempted = false;
  String? _error;

  bool get _compose => widget.mode == _MessageFormMode.compose;
  bool get _needsHari => !_compose || _saveAsTemplate;

  static const _targets = [
    ('pasien', Icons.person_outline, 'Pilih pasien', 'Bisa sekaligus ke keluarganya'),
    ('keluarga', Icons.people_outline, 'Pilih keluarga', 'Pilih akun keluarga tertentu'),
    ('semua_pasien', Icons.groups_outlined, 'Semua pasien', 'Opsional: termasuk keluarga'),
    ('semua_keluarga', Icons.family_restroom_outlined, 'Semua keluarga', 'Seluruh akun keluarga'),
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initial;
    _materi = TextEditingController(text: d?['materi']?.toString() ?? (_compose ? 'Pengumuman' : ''));
    _subMateri = TextEditingController(text: d?['subMateri']?.toString() ?? '');
    _message = TextEditingController(text: d?['message']?.toString() ?? '');
    _hari = TextEditingController(text: d?['hari']?.toString() ?? '');
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _materi.dispose();
    _subMateri.dispose();
    _message.dispose();
    _hari.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _attempted = true;
      _error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final result = _MessageFormResult(
        materi: _materi.text.trim(),
        subMateri: _subMateri.text.trim(),
        message: _message.text.trim(),
        hari: _needsHari ? int.parse(_hari.text.trim()) : null,
        target: _compose ? _target : null,
        saveAsTemplate: _compose && _saveAsTemplate,
      );
      if (_compose) {
        // Tutup dulu: alur kirim membuka dialog pemilihan penerima sendiri.
        Navigator.pop(context);
        await widget.onSubmit(result);
      } else {
        await widget.onSubmit(result);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Gagal: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.mode) {
      _MessageFormMode.compose => 'Tulis Pesan Custom',
      _MessageFormMode.editTemplate => 'Edit Template',
      _MessageFormMode.newTemplate => 'Tambah Template',
    };
    final subtitle = _compose
        ? 'Tulis pesan sendiri tanpa harus memakai template.'
        : 'Template tersimpan di daftar message framing dan bisa dikirim kapan saja.';
    final options = {
      ...widget.materiOptions,
      if (_compose) ...['Pengumuman', 'Motivasi', 'Lainnya'],
    }.toList();

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
              color: AdminColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_compose ? Icons.edit_note : Icons.library_books_outlined,
                color: AdminColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 2),
                Text(subtitle,
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
        width: 580,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _materi,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          labelText: 'Kategori / materi',
                          helperText: 'Pilih dari daftar atau ketik kategori baru',
                          suffixIcon: PopupMenuButton<String>(
                            tooltip: 'Pilih kategori',
                            icon: const Icon(Icons.arrow_drop_down),
                            itemBuilder: (_) => options
                                .map((o) => PopupMenuItem(value: o, child: Text(o)))
                                .toList(),
                            onSelected: (v) => _materi.text = v,
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Kategori wajib diisi'
                            : null,
                      ),
                    ),
                    if (_needsHari) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: TextFormField(
                          controller: _hari,
                          enabled: !_saving,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Hari ke-'),
                          validator: (v) {
                            final n = int.tryParse(v?.trim() ?? '');
                            if (n == null || n < 1) return 'Angka ≥ 1';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _subMateri,
                  enabled: !_saving,
                  decoration: InputDecoration(
                    labelText: _compose ? 'Judul pesan' : 'Sub materi',
                    hintText: _compose ? 'mis. Jadwal kontrol bulan ini' : null,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? (_compose ? 'Judul wajib diisi' : 'Sub materi wajib diisi')
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _message,
                  enabled: !_saving,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 600,
                  decoration: const InputDecoration(
                    labelText: 'Isi pesan',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Isi pesan wajib diisi'
                      : null,
                ),
                if (_compose) ...[
                  _buildPreview(),
                  const SizedBox(height: 18),
                  const Text('KIRIM KE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AdminColors.textSubtle)),
                  const SizedBox(height: 10),
                  LayoutBuilder(builder: (context, c) {
                    final w = c.maxWidth >= 480 ? (c.maxWidth - 10) / 2 : c.maxWidth;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in _targets)
                          SizedBox(
                            width: w,
                            child: _TargetOption(
                              icon: t.$2,
                              title: t.$3,
                              subtitle: t.$4,
                              selected: _target == t.$1,
                              onTap: _saving
                                  ? null
                                  : () => setState(() => _target = t.$1),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  CheckboxListTile(
                    value: _saveAsTemplate,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _saveAsTemplate = v ?? false),
                    activeColor: AdminColors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Simpan juga sebagai template',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: const Text(
                        'Pesan masuk ke daftar message framing agar bisa dipakai lagi.',
                        style: TextStyle(fontSize: 12, color: AdminColors.textMuted)),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: AdminColors.danger)),
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
          onPressed: _saving ? null : _submit,
          icon: Icon(_compose ? Icons.arrow_forward : Icons.check, size: 18),
          label: Text(_compose ? 'Lanjut pilih penerima' : 'Simpan'),
        ),
      ],
    );
  }

  /// Pratinjau seperti yang terlihat di daftar notifikasi aplikasi pasien.
  Widget _buildPreview() {
    final text = _message.text.trim();
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, size: 18, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PRATINJAU DI APLIKASI',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AdminColors.textSubtle)),
                const SizedBox(height: 4),
                Text(_materi.text.trim().isEmpty ? 'Edukasi' : _materi.text.trim(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AdminColors.text)),
                Text(text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, color: AdminColors.textMuted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;

  const _TargetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AdminColors.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AdminColors.primary : AdminColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? AdminColors.primary : AdminColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: selected ? AdminColors.primary : AdminColors.text)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AdminColors.textMuted)),
                ],
              ),
            ),
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected ? AdminColors.primary : AdminColors.textSubtle),
          ],
        ),
      ),
    );
  }
}
