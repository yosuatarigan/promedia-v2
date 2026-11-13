// Pengirim pengingat terjadwal (sekali kirim).
//
// Hemat baca Firestore: tidak polling. Satu listener pada
// `scheduled_reminders where status == 'pending'` (himpunan kecil) — hanya
// dokumen yang berubah yang dihitung sebagai baca. Tiap jadwal dipasangi
// timer di memori; saat jatuh tempo, transaksi memindahkannya ke `reminders`.
import { FieldValue } from 'firebase-admin/firestore';

/** setTimeout maksimal ±24,8 hari; jadwal lebih jauh dicek ulang berkala. */
const MAX_DELAY = 2_000_000_000;
const RETRY_DELAYS = [30_000, 120_000, 600_000];

/**
 * Pindahkan satu jadwal ke `reminders`. Idempoten: bila status sudah bukan
 * 'pending' (dibatalkan / sudah terkirim) tidak melakukan apa pun.
 * @returns {Promise<string|null>} id reminder baru, atau null bila dilewati.
 */
export async function deliverScheduled(db, ref, now = new Date()) {
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return null;
    const d = snap.data();
    if (d.status !== 'pending') return null;
    const sendAt = d.sendAt?.toDate?.() ?? now;
    if (sendAt.getTime() > now.getTime() + 1000) return null; // belum waktunya

    const reminderRef = db.collection('reminders').doc();
    tx.create(reminderRef, {
      ...(d.payload ?? {}),
      isRead: false,
      // Waktu tampil = waktu kirim sebenarnya (≈ sendAt bila tepat waktu).
      createdAt: FieldValue.serverTimestamp(),
      scheduledFor: d.sendAt ?? null,
      scheduledReminderId: ref.id,
      createdVia: d.payload?.createdVia ? `${d.payload.createdVia}_scheduled` : 'scheduled',
    });
    tx.update(ref, {
      status: 'sent',
      sentAt: FieldValue.serverTimestamp(),
      reminderId: reminderRef.id,
    });
    return reminderRef.id;
  });
}

export class Scheduler {
  /**
   * @param {FirebaseFirestore.Firestore} db
   * @param {{info: Function, warn: Function, error: Function}} log
   * @param {(reminderId: string) => Promise<void>} [onDelivered]
   */
  constructor(db, log, onDelivered) {
    this.db = db;
    this.log = log;
    this.onDelivered = onDelivered;
    this.timers = new Map(); // id -> timeout
    this.attempts = new Map(); // id -> jumlah gagal
    this.unsubscribe = null;
    this.stats = { pending: 0, delivered: 0, failed: 0, lastDeliveredAt: null, listening: false };
  }

  start() {
    const q = this.db.collection('scheduled_reminders').where('status', '==', 'pending');
    this.unsubscribe = q.onSnapshot(
      (snap) => {
        this.stats.listening = true;
        for (const ch of snap.docChanges()) {
          if (ch.type === 'removed') this.#clear(ch.doc.id);
          else this.#arm(ch.doc);
        }
        this.stats.pending = snap.size;
      },
      (err) => {
        // Listener mati (mis. jaringan). Coba pasang ulang setelah jeda.
        this.stats.listening = false;
        this.log.error({ err: err?.message }, 'scheduler listener error');
        this.stop();
        setTimeout(() => this.start(), 60_000).unref();
      },
    );
    this.log.info('scheduler started');
  }

  stop() {
    this.unsubscribe?.();
    this.unsubscribe = null;
    for (const t of this.timers.values()) clearTimeout(t);
    this.timers.clear();
  }

  #clear(id) {
    const t = this.timers.get(id);
    if (t) clearTimeout(t);
    this.timers.delete(id);
  }

  #arm(doc, extraDelay = 0) {
    this.#clear(doc.id);
    const sendAt = doc.data().sendAt?.toDate?.();
    const wait = Math.max(0, (sendAt ? sendAt.getTime() - Date.now() : 0)) + extraDelay;
    const t = setTimeout(
      () => (wait > MAX_DELAY ? this.#arm(doc) : this.#fire(doc)),
      Math.min(wait, MAX_DELAY),
    );
    t.unref?.();
    this.timers.set(doc.id, t);
  }

  async #fire(doc) {
    this.timers.delete(doc.id);
    try {
      const reminderId = await deliverScheduled(this.db, doc.ref);
      this.attempts.delete(doc.id);
      if (!reminderId) return;
      this.stats.delivered++;
      this.stats.lastDeliveredAt = new Date().toISOString();
      this.log.info({ scheduledId: doc.id, reminderId }, 'scheduled reminder delivered');
      if (this.onDelivered) {
        this.onDelivered(reminderId).catch((e) =>
          this.log.warn({ err: e?.message, reminderId }, 'post-delivery hook failed'),
        );
      }
    } catch (e) {
      const n = (this.attempts.get(doc.id) ?? 0) + 1;
      this.attempts.set(doc.id, n);
      this.log.error({ err: e?.message, scheduledId: doc.id, attempt: n }, 'deliver failed');
      if (n <= RETRY_DELAYS.length) {
        this.#arm(doc, RETRY_DELAYS[n - 1]);
      } else {
        this.stats.failed++;
        this.attempts.delete(doc.id);
        await doc.ref
          .update({ status: 'failed', failedAt: FieldValue.serverTimestamp(), error: String(e?.message ?? e).slice(0, 300) })
          .catch(() => {});
      }
    }
  }
}

