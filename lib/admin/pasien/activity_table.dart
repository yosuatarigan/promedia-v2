import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/pasien/activity_config.dart';
import 'package:promedia_v2/admin/pasien/activity_editor.dart';

/// Tabel semua catatan satu jenis aktivitas milik satu pasien.
class ActivityTable extends StatefulWidget {
  final ActivityConfig config;
  final PasienRef pasien;
  final AdminProfile admin;

  const ActivityTable({
    super.key,
    required this.config,
    required this.pasien,
    required this.admin,
  });

  @override
  State<ActivityTable> createState() => _ActivityTableState();
}

class _ActivityTableState extends State<ActivityTable>
    with AutomaticKeepAliveClientMixin {
  static const _pageSize = 25;
  int _limit = _pageSize;

  /// Hanya [_limit] catatan terbaru yang dibaca (diurutkan di server).
  /// Stream dibuat ulang hanya saat [_limit] berubah, bukan tiap build.
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  /// Jumlah total catatan lewat agregasi count() — 1 baca per 1.000 dokumen.
  int? _total;

  ActivityConfig get c => widget.config;

  Query<Map<String, dynamic>> get _base => FirebaseFirestore.instance
      .collection(c.collection)
      .where('noKode', isEqualTo: widget.pasien.noKode);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _stream = _pageStream();
    _loadTotal();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _pageStream() => _base
      .orderBy(c.dateKey, descending: true)
      .limit(_limit)
      .snapshots();

  Future<void> _loadTotal() async {
    try {
      final agg = await _base.count().get();
      if (mounted) setState(() => _total = agg.count);
    } catch (_) {
      // Jumlah hanya informasi; tabel tetap tampil.
    }
  }

  void _loadMore() {
    setState(() {
      _limit += _pageSize;
      _stream = _pageStream();
    });
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AdminColors.danger : null,
    ));
  }

  Future<void> _add() async {
    final ok = await showActivityEditor(context,
        config: c, pasien: widget.pasien, admin: widget.admin);
    if (ok == true) {
      _snack('${_cap(c.singular)} ditambahkan');
      _loadTotal();
    }
  }

  Future<void> _edit(DocumentSnapshot doc) async {
    final ok = await showActivityEditor(context,
        config: c, pasien: widget.pasien, admin: widget.admin, doc: doc);
    if (ok == true) _snack('${_cap(c.singular)} diperbarui');
  }

  Future<void> _delete(DocumentSnapshot doc) async {
    final d = doc.data() as Map<String, dynamic>;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus ${c.singular}?'),
        content: Text(
            'Catatan tanggal ${formatActivityDate(c, d)} akan dihapus permanen '
            'dari aplikasi pasien. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await doc.reference.delete();
      _snack('${_cap(c.singular)} dihapus');
      _loadTotal();
    } catch (e) {
      _snack('Gagal menghapus: $e', error: true);
    }
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return AdminCard(
            child: AdminEmptyState(
              icon: Icons.error_outline,
              title: 'Gagal memuat ${c.title.toLowerCase()}',
              message: '${snap.error}',
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs.toList()
          ..sort((a, b) {
            final ta = activityDate(c, a.data()) ?? DateTime(1970);
            final tb = activityDate(c, b.data()) ?? DateTime(1970);
            final byDate = tb.compareTo(ta);
            if (byDate != 0) return byDate;
            final ja = c.timeKey == null ? '' : (a.data()[c.timeKey] ?? '').toString();
            final jb = c.timeKey == null ? '' : (b.data()[c.timeKey] ?? '').toString();
            return jb.compareTo(ja);
          });
        final shown = docs;
        // Data di server bisa lebih banyak dari yang sudah dimuat.
        final total = _total ?? docs.length;
        // Bila jumlah total tak diketahui (count() gagal), anggap masih ada
        // data lama selama halaman terisi penuh.
        final hasMore = _total == null
            ? docs.length >= _limit
            : total > docs.length;

        return AdminCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Icon(c.icon, size: 20, color: c.color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _total == null
                            ? (hasMore
                                ? '${docs.length} ${c.singular} terbaru ditampilkan'
                                : '${docs.length} ${c.singular}')
                            : _total == docs.length
                                ? '${docs.length} ${c.singular}'
                                : '$total ${c.singular}  ·  menampilkan ${docs.length} terbaru',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AdminColors.textMuted,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _add,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: docs.isEmpty
                    ? AdminEmptyState(
                        icon: c.icon,
                        title: 'Belum ada ${c.singular}',
                        message:
                            'Catatan yang diinput pasien di aplikasi akan muncul di sini.',
                      )
                    : LayoutBuilder(builder: (context, box) {
                        return Scrollbar(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints:
                                        BoxConstraints(minWidth: box.maxWidth),
                                    child: DataTable(
                                      showCheckboxColumn: false,
                                      dataRowMinHeight: 52,
                                      dataRowMaxHeight: 60,
                                      columns: [
                                        const DataColumn(label: Text('TANGGAL')),
                                        ...c.columns.map((col) => DataColumn(
                                            numeric: col.numeric,
                                            label: Text(col.label))),
                                        const DataColumn(label: Text('AKSI')),
                                      ],
                                      rows: shown.map(_row).toList(),
                                    ),
                                  ),
                                ),
                                if (hasMore)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: OutlinedButton(
                                        onPressed: _loadMore,
                                        child: Text(_total == null
                                            ? 'Tampilkan $_pageSize lagi'
                                            : 'Tampilkan $_pageSize lagi (${total - docs.length} catatan lebih lama)'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
              ),
            ],
          ),
        );
      },
    );
  }

  DataRow _row(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return DataRow(
      onSelectChanged: (_) =>
          showActivityDetail(context, config: c, doc: doc, onEdit: () => _edit(doc)),
      cells: [
        DataCell(Text(formatActivityDate(c, d),
            style: const TextStyle(fontWeight: FontWeight.w500))),
        ...c.columns.map((col) => DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(col.value(d),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AdminColors.textMuted)),
              ),
            )),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminIconAction(
              icon: Icons.edit_outlined,
              tooltip: 'Edit',
              color: AdminColors.warning,
              onPressed: () => _edit(doc),
            ),
            AdminIconAction(
              icon: Icons.delete_outline,
              tooltip: 'Hapus',
              color: AdminColors.danger,
              onPressed: () => _delete(doc),
            ),
          ],
        )),
      ],
    );
  }
}
