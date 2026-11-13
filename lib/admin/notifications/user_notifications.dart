import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promedia_v2/admin/admin_session.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/notifications/notif_actions.dart';
import 'package:promedia_v2/admin/notifications/scheduled_reminders.dart';
import 'package:promedia_v2/admin/notifications/send_reminder_dialog.dart';

/// Pengguna yang riwayat notifikasinya ditampilkan.
class NotifTarget {
  final String uid;
  final String nama;
  final String noKode;
  final String role; // 'pasien' | 'keluarga'

  const NotifTarget({
    required this.uid,
    required this.nama,
    required this.noKode,
    required this.role,
  });

  factory NotifTarget.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotifTarget(
      uid: doc.id,
      nama: (d['namaLengkap'] ?? '-').toString(),
      noKode: (d['noKode'] ?? '').toString(),
      role: (d['role'] ?? '').toString(),
    );
  }
}

class ReminderType {
  final String label;
  final IconData icon;
  final Color color;
  const ReminderType(this.label, this.icon, this.color);
}

const kReminderTypes = <String, ReminderType>{
  'makan': ReminderType('Makan', Icons.restaurant_outlined, AdminColors.warning),
  'minum_obat':
      ReminderType('Minum obat', Icons.medication_outlined, AdminColors.info),
  'latihan_fisik': ReminderType(
      'Latihan fisik', Icons.directions_run_outlined, AdminColors.keluarga),
  'perawatan_kaki': ReminderType(
      'Perawatan kaki', Icons.accessibility_new_outlined, Color(0xFF2B9BA8)),
  'manajemen_stress': ReminderType(
      'Manajemen stress', Icons.self_improvement_outlined, Color(0xFF9C4DCC)),
  'edukasi':
      ReminderType('Edukasi', Icons.school_outlined, AdminColors.primary),
  'umum': ReminderType(
      'Pesan admin', Icons.campaign_outlined, AdminColors.primaryDark),
};

ReminderType reminderTypeOf(String? type) =>
    kReminderTypes[type] ??
    const ReminderType('Notifikasi', Icons.notifications_none, AdminColors.textMuted);

/// Halaman penuh riwayat notifikasi satu pengguna.
class UserNotificationsScreen extends StatelessWidget {
  final NotifTarget target;
  final AdminProfile admin;

  const UserNotificationsScreen(
      {super.key, required this.target, required this.admin});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 720;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(wide ? 20 : 8, 16, wide ? 32 : 16, 16),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  AdminAvatar(target.nama,
                      size: 44,
                      color: target.role == 'keluarga'
                          ? AdminColors.keluarga
                          : AdminColors.pasien),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifikasi ${target.nama}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.text)),
                        const SizedBox(height: 4),
                        Row(children: [
                          AdminBadge.role(target.role),
                          const SizedBox(width: 8),
                          Text('Kode ${target.noKode}',
                              style: const TextStyle(
                                  fontSize: 13, color: AdminColors.textMuted)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: wide ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
              child: UserNotificationsView(target: target, admin: admin),
            ),
          ),
        ],
      ),
    );
  }
}

/// Riwayat semua pengingat/notifikasi yang terkait satu pengguna:
/// yang diterima, yang dikirim, dan yang terkait no kode pasangannya.
class UserNotificationsView extends StatefulWidget {
  final NotifTarget target;
  final AdminProfile admin;

  const UserNotificationsView(
      {super.key, required this.target, required this.admin});

  @override
  State<UserNotificationsView> createState() => _UserNotificationsViewState();
}

class _UserNotificationsViewState extends State<UserNotificationsView>
    with AutomaticKeepAliveClientMixin {
  final _db = FirebaseFirestore.instance;
  final List<StreamSubscription> _subs = [];
  final Map<String, Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>>
      _sources = {};
  final Map<String, String> _names = {};

  /// Keluarga dengan no kode yang sama (untuk "kirim atas nama").
  final List<NotifTarget> _keluarga = [];
  int _loadedSources = 0;
  int _expectedSources = 0;
  Object? _error;
  String _filter = 'semua';
  bool _selectMode = false;
  final Set<String> _selected = {};
  bool _bulkBusy = false;

  @override
  bool get wantKeepAlive => true;

  NotifTarget get t => widget.target;

  @override
  void initState() {
    super.initState();
    final col = _db.collection('reminders');
    final queries = <String, Query<Map<String, dynamic>>>{
      'to': col.where('toUserId', isEqualTo: t.uid),
      'from': col.where('fromUserId', isEqualTo: t.uid),
      if (t.noKode.isNotEmpty) 'kode': col.where('noKode', isEqualTo: t.noKode),
    };
    _expectedSources = queries.length;
    queries.forEach((key, q) {
      var first = true;
      _subs.add(q.snapshots().listen((snap) {
        setState(() {
          _sources[key] = {for (final d in snap.docs) d.id: d};
          if (first) {
            _loadedSources++;
            first = false;
          }
        });
      }, onError: (e) => setState(() => _error = e)));
    });
    _loadNames();
  }

  Future<void> _loadNames() async {
    if (t.noKode.isEmpty) return;
    try {
      final snap =
          await _db.collection('users').where('noKode', isEqualTo: t.noKode).get();
      setState(() {
        for (final d in snap.docs) {
          _names[d.id] = (d.data()['namaLengkap'] ?? '-').toString();
          if (d.data()['role'] == 'keluarga') _keluarga.add(NotifTarget.fromDoc(d));
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _all {
    final merged = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    for (final m in _sources.values) {
      merged.addAll(m);
    }
    final list = merged.values.toList()
      ..sort((a, b) {
        final ta = (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final tb = (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return tb.compareTo(ta);
      });
    return list;
  }

  /// Pengingat "atas nama keluarga" dihitung sebagai pengingat keluarga.
  bool _isFromAdmin(Map<String, dynamic> d) =>
      d['sentOnBehalf'] != true &&
      (d['fromAdmin'] == true || d['sentByAdmin'] == true);

  bool _match(Map<String, dynamic> d) {
    switch (_filter) {
      case 'diterima':
        return d['toUserId'] == t.uid ||
            (d['toUserId'] == null && t.role == 'pasien');
      case 'dikirim':
        return d['fromUserId'] == t.uid;
      case 'keluarga':
        return !_isFromAdmin(d) && d['fromUserId'] != null;
      case 'admin':
        return _isFromAdmin(d);
      case 'belum':
        return d['isRead'] != true;
    }
    return true;
  }

  String _nameOf(String? uid, {String fallback = '-'}) {
    if (uid == null) return fallback;
    if (uid == t.uid) return t.nama;
    return _names[uid] ?? fallback;
  }

  Future<void> _send() async {
    final msg = await showSendReminderDialog(context,
        target: widget.target, admin: widget.admin, keluarga: _keluarga);
    if (msg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _snack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _setRead(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, bool read) async {
    if (docs.isEmpty) return;
    setState(() => _bulkBusy = true);
    try {
      await NotifActions.setRead(docs.map((d) => d.reference), read, widget.admin);
      _snack('${docs.length} notifikasi ditandai ${read ? 'sudah' : 'belum'} dibaca');
      if (_selectMode) {
        setState(() {
          _selected.clear();
          _selectMode = false;
        });
      }
    } catch (e) {
      _snack('Gagal mengubah status: $e');
    } finally {
      if (mounted) setState(() => _bulkBusy = false);
    }
  }

  Future<void> _editDate(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    final ok =
        await showEditNotifDateDialog(context, doc: doc, admin: widget.admin);
    if (ok == true) _snack('Tanggal notifikasi diperbarui');
  }

  Future<void> _delete(DocumentSnapshot doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus notifikasi?'),
        content: const Text(
            'Notifikasi ini akan hilang juga dari aplikasi penerima. Tindakan ini tidak bisa dibatalkan.'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final all = _all;
    final shown = all.where((d) => _match(d.data())).toList();
    final unread = all.where((d) => d.data()['isRead'] != true).length;
    final fromKeluarga = all
        .where((d) => !_isFromAdmin(d.data()) && d.data()['fromUserId'] != null)
        .length;
    final fromAdmin = all.where((d) => _isFromAdmin(d.data())).length;

    final filters = <(String, String)>[
      ('semua', 'Semua (${all.length})'),
      ('diterima', 'Diterima'),
      if (t.role == 'keluarga') ('dikirim', 'Dikirim'),
      if (t.role == 'pasien') ('keluarga', 'Dari keluarga ($fromKeluarga)'),
      ('admin', 'Dari admin ($fromAdmin)'),
      ('belum', 'Belum dibaca ($unread)'),
    ];

    return AdminCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Riwayat Notifikasi',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.text)),
                      const SizedBox(height: 2),
                      Text(
                        t.role == 'pasien'
                            ? '$fromKeluarga pengingat dari keluarga  ·  $fromAdmin dari admin  ·  $unread belum dibaca'
                            : 'Pengingat yang dikirim ke pasien dan pesan dari admin',
                        style: const TextStyle(
                            fontSize: 13, color: AdminColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (!_selectMode && all.isNotEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _selectMode = true),
                    icon: const Icon(Icons.checklist, size: 18),
                    label: const Text('Pilih'),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Kirim Pengingat'),
                ),
              ],
            ),
          ),
          ScheduledRemindersPanel(target: t, adminUid: widget.admin.uid),
          if (_selectMode) _buildBulkBar(shown),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                for (final f in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: f.$2,
                      selected: _filter == f.$1,
                      onTap: () => setState(() => _filter = f.$1),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: _buildList(shown)),
        ],
      ),
    );
  }

  Widget _buildBulkBar(List<QueryDocumentSnapshot<Map<String, dynamic>>> shown) {
    final picked = shown.where((d) => _selected.contains(d.id)).toList();
    final allPicked = shown.isNotEmpty && picked.length == shown.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.primarySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Checkbox(
            value: allPicked,
            activeColor: AdminColors.primary,
            onChanged: _bulkBusy
                ? null
                : (v) => setState(() {
                      if (v == true) {
                        _selected.addAll(shown.map((d) => d.id));
                      } else {
                        _selected.removeAll(shown.map((d) => d.id));
                      }
                    }),
          ),
          Text('${picked.length} dipilih',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AdminColors.text)),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed:
                _bulkBusy || picked.isEmpty ? null : () => _setRead(picked, true),
            icon: const Icon(Icons.mark_email_read_outlined, size: 18),
            label: const Text('Tandai dibaca'),
          ),
          TextButton.icon(
            onPressed:
                _bulkBusy || picked.isEmpty ? null : () => _setRead(picked, false),
            icon: const Icon(Icons.mark_email_unread_outlined, size: 18),
            label: const Text('Tandai belum dibaca'),
          ),
          TextButton(
            onPressed: _bulkBusy
                ? null
                : () => setState(() {
                      _selectMode = false;
                      _selected.clear();
                    }),
            child: const Text('Selesai'),
          ),
          if (_bulkBusy)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (_error != null) {
      return AdminEmptyState(
          icon: Icons.error_outline,
          title: 'Gagal memuat notifikasi',
          message: '$_error');
    }
    if (_loadedSources < _expectedSources) {
      return const Center(child: CircularProgressIndicator());
    }
    if (docs.isEmpty) {
      return AdminEmptyState(
        icon: Icons.notifications_none,
        title: _filter == 'semua'
            ? 'Belum ada notifikasi'
            : 'Tidak ada notifikasi untuk filter ini',
        message: _filter == 'semua'
            ? 'Pengingat dari keluarga dan pesan dari admin akan muncul di sini.'
            : null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const Divider(indent: 76, endIndent: 20),
      itemBuilder: (_, i) => _buildItem(docs[i]),
    );
  }

  Widget _buildItem(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final type = reminderTypeOf(d['type'] as String?);
    final admin = _isFromAdmin(d);
    final created = (d['createdAt'] as Timestamp?)?.toDate();
    final isRead = d['isRead'] == true;
    final snoozedUntil = (d['snoozedUntil'] as Timestamp?)?.toDate();
    final snoozed = d['isSnoozed'] == true &&
        snoozedUntil != null &&
        snoozedUntil.isAfter(DateTime.now());

    final from = admin
        ? (d['fromUserName']?.toString().isNotEmpty == true && d['sentByAdmin'] == true
            ? '${d['fromUserName']}'
            : 'Admin')
        : _nameOf(d['fromUserId'] as String?,
            fallback: (d['fromUserName'] ?? 'Keluarga').toString());
    final to = _nameOf(d['toUserId'] as String?,
        fallback: d['toUserId'] == null ? 'Pasien (belum terdaftar)' : 'Pengguna lain');

    final original = (d['originalCreatedAt'] as Timestamp?)?.toDate();
    final onBehalf = d['sentOnBehalf'] == true;

    final title = d['type'] == 'edukasi' && (d['subMateri'] ?? '').toString().isNotEmpty
        ? '${d['materi'] ?? 'Edukasi'} · ${d['subMateri']}'
        : type.label;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Checkbox(
                value: _selected.contains(doc.id),
                activeColor: AdminColors.primary,
                onChanged: _bulkBusy
                    ? null
                    : (v) => setState(() => v == true
                        ? _selected.add(doc.id)
                        : _selected.remove(doc.id)),
              ),
            ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(type.icon, color: type.color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AdminColors.text)),
                    if (!isRead)
                      const AdminBadge('Belum dibaca',
                          color: AdminColors.primary, icon: Icons.circle),
                    if (isRead)
                      const AdminBadge('Dibaca', color: AdminColors.success),
                    if (snoozed)
                      const AdminBadge('Ditunda', color: AdminColors.warning),
                    if (d['sentByAdmin'] == true && d['fromAdmin'] == false)
                      const AdminBadge('Pop-up', color: AdminColors.info),
                    if (onBehalf)
                      Tooltip(
                        message:
                            'Dikirim oleh ${d['actingAdminName'] ?? 'admin'} atas nama ${d['fromUserName'] ?? 'keluarga'}. '
                            'Label ini hanya terlihat di Admin Panel.',
                        child: const AdminBadge('Dikirim admin atas nama',
                            color: AdminColors.keluarga,
                            icon: Icons.support_agent),
                      ),
                    if (original != null)
                      Tooltip(
                        message: 'Waktu asli: ${formatNotifDate(original)}',
                        child: const AdminBadge('Tanggal diubah',
                            color: AdminColors.warning,
                            icon: Icons.edit_calendar_outlined),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  (d['message'] ?? '-').toString(),
                  style: const TextStyle(
                      fontSize: 14, color: AdminColors.text, height: 1.45),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                        fontSize: 12, color: AdminColors.textMuted),
                    children: [
                      TextSpan(
                          text: from,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const TextSpan(text: '  →  '),
                      TextSpan(
                          text: to,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (created != null)
                        TextSpan(
                            text:
                                '   ·   ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(created)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Aksi',
            icon: const Icon(Icons.more_horiz, color: AdminColors.textMuted),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'read',
                child: Text(isRead ? 'Tandai belum dibaca' : 'Tandai dibaca'),
              ),
              const PopupMenuItem(
                value: 'date',
                child: Text('Ubah tanggal & jam'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Hapus notifikasi',
                    style: TextStyle(color: AdminColors.danger)),
              ),
            ],
            onSelected: (v) {
              switch (v) {
                case 'read':
                  _setRead([doc], !isRead);
                case 'date':
                  _editDate(doc);
                case 'delete':
                  _delete(doc);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AdminColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
                color: selected ? AdminColors.primary : AdminColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AdminColors.textMuted)),
        ),
      ),
    );
  }
}

// ───────────────────── jumlah notifikasi belum dibaca ─────────────────────

class UnreadNotif {
  final int count;
  final DateTime? latest;
  const UnreadNotif(this.count, this.latest);

  static const none = UnreadNotif(0, null);

  UnreadNotif operator +(UnreadNotif o) {
    DateTime? l = latest;
    if (o.latest != null && (l == null || o.latest!.isAfter(l))) l = o.latest;
    return UnreadNotif(count + o.count, l);
  }
}

/// Indeks notifikasi belum dibaca per penerima, dari satu query
/// `reminders where isRead == false` (dipakai tabel Manage Users).
class UnreadNotifIndex {
  final Map<String, UnreadNotif> byUid;

  /// Reminder untuk pasien yang belum terdaftar (toUserId null) per noKode.
  final Map<String, UnreadNotif> byKode;

  const UnreadNotifIndex(this.byUid, this.byKode);
  static const empty = UnreadNotifIndex({}, {});

  UnreadNotif forUser(String uid, String noKode, String role) {
    var r = byUid[uid] ?? UnreadNotif.none;
    if (role == 'pasien' && noKode.isNotEmpty) r = r + (byKode[noKode] ?? UnreadNotif.none);
    return r;
  }

  /// Jendela "notifikasi terbaru". Dibatasi agar listener tidak ikut membaca
  /// pesan lama yang menumpuk (mis. edukasi ke akun keluarga).
  static const window = Duration(days: 30);

  static Stream<UnreadNotifIndex> watch() => FirebaseFirestore.instance
      .collection('reminders')
      .where('isRead', isEqualTo: false)
      .where('createdAt',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(DateTime.now().subtract(window)))
      .snapshots()
      .map((snap) {
        final byUid = <String, UnreadNotif>{};
        final byKode = <String, UnreadNotif>{};
        for (final d in snap.docs) {
          final data = d.data();
          final at = (data['createdAt'] as Timestamp?)?.toDate();
          final one = UnreadNotif(1, at);
          final to = data['toUserId'] as String?;
          if (to != null) {
            byUid[to] = (byUid[to] ?? UnreadNotif.none) + one;
          } else if ((data['noKode'] ?? '').toString().isNotEmpty) {
            final k = data['noKode'].toString();
            byKode[k] = (byKode[k] ?? UnreadNotif.none) + one;
          }
        }
        return UnreadNotifIndex(byUid, byKode);
      });
}

String timeAgoId(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes} menit lalu';
  if (d.inHours < 24) return '${d.inHours} jam lalu';
  if (d.inDays < 7) return '${d.inDays} hari lalu';
  return DateFormat('d MMM yyyy', 'id_ID').format(t);
}

/// Label jumlah notifikasi baru + waktu notifikasi terbaru.
class UnreadNotifBadge extends StatelessWidget {
  final UnreadNotif info;
  final VoidCallback? onTap;
  final bool compact;

  const UnreadNotifBadge(
      {super.key, required this.info, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final has = info.count > 0;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: has ? AdminColors.primary : AdminColors.divider,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(has ? Icons.notifications_active : Icons.notifications_none,
              size: 13, color: has ? Colors.white : AdminColors.textSubtle),
          const SizedBox(width: 4),
          Text(
            has ? '${info.count} baru' : '0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: has ? Colors.white : AdminColors.textSubtle,
            ),
          ),
        ],
      ),
    );

    final child = compact || !has || info.latest == null
        ? pill
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pill,
              const SizedBox(height: 3),
              Text(timeAgoId(info.latest!),
                  style: const TextStyle(
                      fontSize: 11, color: AdminColors.textSubtle)),
            ],
          );

    return Tooltip(
      message: has
          ? '${info.count} notifikasi belum dibaca (30 hari terakhir)'
              '${info.latest == null ? '' : '\nTerbaru: ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(info.latest!)}'}'
          : 'Tidak ada notifikasi baru',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: child,
      ),
    );
  }
}
