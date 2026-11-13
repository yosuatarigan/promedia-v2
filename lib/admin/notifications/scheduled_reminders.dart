import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:promedia_v2/admin/admin_ui.dart';
import 'package:promedia_v2/admin/notifications/notif_actions.dart';
import 'package:promedia_v2/admin/notifications/user_notifications.dart';

/// Antrean pengingat terjadwal (sekali kirim, tidak berulang).
///
/// Dokumen `scheduled_reminders/{id}`:
///   payload   — isi dokumen `reminders` yang akan dibuat (tanpa createdAt)
///   sendAt    — waktu kirim
///   status    — 'pending' | 'sent' | 'cancelled' | 'failed'
///   toUserId  — salinan payload.toUserId agar bisa difilter per pengguna
///   createdBy / createdByName / createdAt
///
/// Layanan VPS memindahkan dokumen yang jatuh tempo ke `reminders`
/// (createdAt = sendAt) lalu mengisi status 'sent' + reminderId.
class ScheduledReminders {
  static final col = FirebaseFirestore.instance.collection('scheduled_reminders');

  static Future<void> schedule({
    required Map<String, dynamic> payload,
    required DateTime sendAt,
    required String adminUid,
    required String adminName,
  }) =>
      col.add({
        'payload': payload,
        'toUserId': payload['toUserId'],
        'noKode': payload['noKode'],
        'sendAt': Timestamp.fromDate(sendAt),
        'status': 'pending',
        'createdBy': adminUid,
        'createdByName': adminName,
        'createdAt': FieldValue.serverTimestamp(),
      });

  static Future<void> cancel(DocumentReference ref, String adminUid) =>
      ref.update({
        'status': 'cancelled',
        'cancelledBy': adminUid,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

  /// Hanya yang masih menunggu — daftar kecil, listener murah.
  static Stream<QuerySnapshot<Map<String, dynamic>>> pendingFor(String uid) => col
      .where('toUserId', isEqualTo: uid)
      .where('status', isEqualTo: 'pending')
      .snapshots();
}

/// Daftar pengingat terjadwal yang belum terkirim untuk satu pengguna.
/// Tidak tampil apa pun bila kosong.
class ScheduledRemindersPanel extends StatelessWidget {
  final NotifTarget target;
  final String adminUid;
  const ScheduledRemindersPanel(
      {super.key, required this.target, required this.adminUid});

  Future<void> _cancel(BuildContext context, DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan jadwal?'),
        content: const Text('Pengingat ini tidak akan dikirim.'),
        actions: [
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Kembali')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Batalkan jadwal'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ScheduledReminders.cancel(ref, adminUid);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal membatalkan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ScheduledReminders.pendingFor(target.uid),
      builder: (context, snap) {
        final docs = [...?snap.data?.docs]..sort((a, b) {
            final ta = (a.data()['sendAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
            final tb = (b.data()['sendAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
            return ta.compareTo(tb);
          });
        if (docs.isEmpty) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          decoration: BoxDecoration(
            border: Border.all(color: AdminColors.info.withOpacity(0.35)),
            color: AdminColors.info.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                child: Row(children: [
                  const Icon(Icons.schedule_send_outlined,
                      size: 18, color: AdminColors.info),
                  const SizedBox(width: 8),
                  Text('Terjadwal (${docs.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AdminColors.text)),
                ]),
              ),
              for (final doc in docs) _item(context, doc),
            ],
          ),
        );
      },
    );
  }

  Widget _item(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    final p = (d['payload'] as Map?)?.cast<String, dynamic>() ?? const {};
    final type = reminderTypeOf(p['type'] as String?);
    final at = (d['sendAt'] as Timestamp?)?.toDate();
    final sender = p['sentOnBehalf'] == true
        ? '${p['fromUserName']} (atas nama, oleh admin)'
        : 'Admin';
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(type.icon, size: 18, color: type.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type.label} · ${at == null ? '-' : formatNotifDate(at)}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.text),
                ),
                const SizedBox(height: 2),
                Text((p['message'] ?? '-').toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AdminColors.text)),
                const SizedBox(height: 2),
                Text('Dari $sender',
                    style: const TextStyle(
                        fontSize: 12, color: AdminColors.textMuted)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _cancel(context, doc.reference),
            style: TextButton.styleFrom(foregroundColor: AdminColors.danger),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }
}
