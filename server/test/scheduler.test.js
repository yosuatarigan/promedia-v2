// Dijalankan di Firebase emulator (firestore), BUKAN produksi:
//   firebase emulators:exec --only auth,firestore --project demo-promedia "npm --prefix server test"
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { deliverScheduled, Scheduler } from '../src/scheduler.js';
import { buildNotification, shouldPush, PushSender } from '../src/push.js';

if (!process.env.FIRESTORE_EMULATOR_HOST) {
  throw new Error('Tes ini hanya boleh dijalankan di emulator');
}

if (!getApps().length) initializeApp({ projectId: 'demo-promedia' });
const db = getFirestore();
const quiet = { info() {}, warn() {}, error() {} };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

function payload(extra = {}) {
  return {
    toUserId: 'pasS',
    noKode: 'KS',
    type: 'makan',
    message: 'Jangan lupa makan',
    fromAdmin: false,
    sentByAdmin: true,
    fromUserId: 'admin1',
    fromUserName: 'Admin Promedia',
    isRead: false,
    createdVia: 'admin_web',
    ...extra,
  };
}

async function schedule(msFromNow, extra) {
  return db.collection('scheduled_reminders').add({
    payload: payload(extra),
    toUserId: 'pasS',
    sendAt: Timestamp.fromMillis(Date.now() + msFromNow),
    status: 'pending',
    createdBy: 'admin1',
  });
}

test('jadwal jatuh tempo dipindah ke reminders, sekali saja', async () => {
  const ref = await schedule(-5_000);
  const id = await deliverScheduled(db, ref);
  assert.ok(id);
  const r = (await db.doc(`reminders/${id}`).get()).data();
  assert.equal(r.message, 'Jangan lupa makan');
  assert.equal(r.toUserId, 'pasS');
  assert.equal(r.isRead, false);
  assert.equal(r.scheduledReminderId, ref.id);
  assert.equal(r.createdVia, 'admin_web_scheduled');
  assert.ok(r.createdAt);
  const s = (await ref.get()).data();
  assert.equal(s.status, 'sent');
  assert.equal(s.reminderId, id);
  // Panggilan kedua tidak membuat duplikat.
  assert.equal(await deliverScheduled(db, ref), null);
});

test('jadwal belum waktunya / dibatalkan tidak dikirim', async () => {
  const future = await schedule(60_000);
  assert.equal(await deliverScheduled(db, future), null);
  assert.equal((await future.get()).data().status, 'pending');

  const cancelled = await schedule(-1_000);
  await cancelled.update({ status: 'cancelled' });
  assert.equal(await deliverScheduled(db, cancelled), null);
});

test('Scheduler mengirim tepat waktu dan menghormati pembatalan', async () => {
  const due = await schedule(1_500, { message: 'tepat waktu' });
  const toCancel = await schedule(2_500, { message: 'batal' });
  const delivered = [];
  const s = new Scheduler(db, quiet, async (id) => delivered.push(id));
  s.start();
  await sleep(800);
  await toCancel.update({ status: 'cancelled' });
  await sleep(3_500);
  s.stop();

  assert.equal((await due.get()).data().status, 'sent');
  assert.equal((await toCancel.get()).data().status, 'cancelled');
  assert.equal(delivered.length, 1);
  const r = (await db.doc(`reminders/${delivered[0]}`).get()).data();
  assert.equal(r.message, 'tepat waktu');
  const batal = await db.collection('reminders').where('message', '==', 'batal').get();
  assert.equal(batal.size, 0);
});

test('isi notifikasi push', () => {
  assert.deepEqual(buildNotification({ fromAdmin: true, message: 'Halo' }), {
    title: 'Pesan dari Promedia',
    body: 'Halo',
  });
  assert.equal(
    buildNotification({ fromAdmin: false, sentOnBehalf: true, sentByAdmin: false, fromUserName: 'Budi', message: 'x' }).title,
    'Pengingat dari Budi',
  );
  const now = Date.now();
  const at = (ms) => ({ toDate: () => new Date(now + ms) });
  assert.equal(shouldPush({ toUserId: 'a', createdAt: at(-1_000) }, now), true);
  assert.equal(shouldPush({ toUserId: 'a', createdAt: at(-60 * 60_000) }, now), false); // tanggal lampau
  assert.equal(shouldPush({ toUserId: 'a', createdAt: at(-1_000), pushedAt: 1 }, now), false);
  assert.equal(shouldPush({ toUserId: null, createdAt: at(-1_000) }, now), false);
});

test('push: kirim ke token penerima, buang token mati', async () => {
  await db.doc('users/pasP').set({ role: 'pasien', fcmTokens: ['good', 'dead'] });
  const ref = await db.collection('reminders').add({
    toUserId: 'pasP',
    message: 'Ayo jalan kaki',
    fromUserName: 'Keluarga P',
    fromAdmin: false,
    createdAt: Timestamp.now(),
  });
  let sentMsg = null;
  const fakeMessaging = {
    async sendEachForMulticast(msg) {
      sentMsg = msg;
      return {
        successCount: 1,
        failureCount: 1,
        responses: [
          { success: true },
          { success: false, error: { code: 'messaging/registration-token-not-registered' } },
        ],
      };
    },
  };
  const p = new PushSender(db, fakeMessaging, quiet);
  await p.send(ref, (await ref.get()).data());
  assert.deepEqual(sentMsg.tokens, ['good', 'dead']);
  assert.equal(sentMsg.notification.title, 'Pengingat dari Keluarga P');
  assert.deepEqual((await db.doc('users/pasP').get()).data().fcmTokens, ['good']);
  assert.ok((await ref.get()).data().pushedAt);

  // Tanpa token: tidak memanggil FCM.
  await db.doc('users/pasQ').set({ role: 'pasien' });
  sentMsg = null;
  const ref2 = await db.collection('reminders').add({ toUserId: 'pasQ', createdAt: Timestamp.now() });
  await p.send(ref2, (await ref2.get()).data());
  assert.equal(sentMsg, null);
  assert.equal(p.stats.skippedNoToken, 1);
});

after(() => {});
