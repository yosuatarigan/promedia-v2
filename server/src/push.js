// Push notification (FCM) untuk pengingat baru.
//
// Token perangkat disimpan aplikasi di `users/{uid}.fcmTokens` (array) —
// diisi mulai rilis mobile Tahap 4. Selama belum ada token, tidak ada yang
// dikirim. Aktif hanya bila PUSH_ENABLED=1.
//
// Hemat baca: listener pada `reminders where createdAt >= batas` dipasang
// ulang tiap 30 menit dengan batas baru, sehingga himpunannya tetap kecil.
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

const WINDOW_MS = 10 * 60_000; // hanya pengingat ≤10 menit terakhir yang di-push
const RESUBSCRIBE_MS = 30 * 60_000;
const DEAD_TOKEN = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

/** Judul & isi notifikasi dari dokumen reminder. */
export function buildNotification(r) {
  const fromAdmin = r.fromAdmin === true || (r.sentByAdmin === true && r.sentOnBehalf !== true);
  const title = fromAdmin
    ? 'Pesan dari Promedia'
    : `Pengingat dari ${r.fromUserName || 'keluarga'}`;
  const body = String(r.message ?? '').slice(0, 200) || 'Ada pengingat baru untuk Anda.';
  return { title, body };
}

/** Perlu di-push? Hanya yang baru, belum di-push, dan punya penerima. */
export function shouldPush(r, now = Date.now()) {
  if (!r || r.pushedAt || !r.toUserId) return false;
  const at = r.createdAt?.toDate?.()?.getTime();
  if (!at) return false;
  return now - at <= WINDOW_MS && at - now <= 60_000;
}

export class PushSender {
  constructor(db, messaging, log) {
    this.db = db;
    this.messaging = messaging;
    this.log = log;
    this.seen = new Set();
    this.unsubscribe = null;
    this.timer = null;
    this.stats = { sent: 0, skippedNoToken: 0, failed: 0 };
  }

  start() {
    this.#subscribe();
    this.timer = setInterval(() => this.#subscribe(), RESUBSCRIBE_MS);
    this.timer.unref?.();
    this.log.info('push sender started');
  }

  stop() {
    this.unsubscribe?.();
    clearInterval(this.timer);
  }

  #subscribe() {
    this.unsubscribe?.();
    const since = Timestamp.fromMillis(Date.now() - WINDOW_MS);
    this.unsubscribe = this.db
      .collection('reminders')
      .where('createdAt', '>=', since)
      .onSnapshot(
        (snap) => {
          for (const ch of snap.docChanges()) {
            if (ch.type === 'removed' || this.seen.has(ch.doc.id)) continue;
            const r = ch.doc.data();
            if (!shouldPush(r)) continue;
            this.seen.add(ch.doc.id);
            this.send(ch.doc.ref, r).catch((e) =>
              this.log.warn({ err: e?.message, reminderId: ch.doc.id }, 'push failed'),
            );
          }
          if (this.seen.size > 5000) this.seen.clear();
        },
        (err) => this.log.error({ err: err?.message }, 'push listener error'),
      );
  }

  /** Kirim ke semua token penerima; token mati dibuang. */
  async send(ref, r) {
    const userRef = this.db.collection('users').doc(r.toUserId);
    const tokens = ((await userRef.get()).data()?.fcmTokens ?? []).filter(Boolean);
    if (!tokens.length) {
      this.stats.skippedNoToken++;
      return;
    }
    const { title, body } = buildNotification(r);
    const res = await this.messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: { reminderId: ref.id, type: String(r.type ?? '') },
      // Tanpa channelId: aplikasi belum membuat channel khusus, FCM memakai
      // channel bawaan sehingga notifikasi tetap tampil.
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
    const dead = res.responses
      .map((x, i) => (!x.success && DEAD_TOKEN.has(x.error?.code) ? tokens[i] : null))
      .filter(Boolean);
    if (dead.length) await userRef.update({ fcmTokens: FieldValue.arrayRemove(...dead) });
    this.stats.sent += res.successCount;
    this.stats.failed += res.failureCount;
    await ref.update({ pushedAt: FieldValue.serverTimestamp(), pushSuccess: res.successCount });
  }
}
