// Dijalankan di Firebase emulator (auth + firestore), BUKAN produksi:
//   firebase emulators:exec --only auth,firestore --project demo-promedia "npm --prefix server test"
import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { deleteUserCompletely, previewDelete, setDisabled } from '../src/users.js';

if (!process.env.FIRESTORE_EMULATOR_HOST || !process.env.FIREBASE_AUTH_EMULATOR_HOST) {
  throw new Error('Tes ini hanya boleh dijalankan di emulator');
}

initializeApp({ projectId: 'demo-promedia' });
const auth = getAuth();
const db = getFirestore();

async function count(col, field, value) {
  return (await db.collection(col).where(field, '==', value).count().get()).data().count;
}

before(async () => {
  for (const uid of ['pas1', 'kel1', 'pas2']) {
    await auth.createUser({ uid, email: `${uid}@test.local`, password: 'rahasia123' });
  }
  await db.doc('users/pas1').set({ role: 'pasien', noKode: 'K1', namaLengkap: 'Pasien Satu' });
  await db.doc('users/kel1').set({ role: 'keluarga', noKode: 'K1', namaLengkap: 'Keluarga Satu' });
  await db.doc('users/pas2').set({ role: 'pasien', noKode: 'K2', namaLengkap: 'Pasien Dua' });
  for (let i = 0; i < 3; i++) {
    await db.collection('food_logs').add({ noKode: 'K1', foodName: `makan ${i}` });
    await db.collection('food_logs').add({ noKode: 'K2', foodName: `lain ${i}` });
  }
  await db.collection('hba1c_logs').add({ noKode: 'K1', nilaiHbA1c: 6 });
  await db.collection('chat_messages').add({ noKode: 'K1', text: 'halo' });
  await db.collection('reminders').add({ toUserId: 'pas1', fromUserId: 'kel1', noKode: 'K1' });
  await db.collection('reminders').add({ toUserId: 'kel1', fromAdmin: true });
  await db.collection('reminders').add({ toUserId: null, noKode: 'K1', fromUserId: 'kel1' });
  await db.collection('reminders').add({ toUserId: 'pas2', fromAdmin: true });
});

test('preview pasien menghitung catatan & notifikasinya', async () => {
  const p = await previewDelete(db, 'pas1');
  assert.equal(p.role, 'pasien');
  assert.equal(p.counts.food_logs, 3);
  assert.equal(p.counts.hba1c_logs, 1);
  assert.equal(p.counts.chat_messages, 1);
  assert.ok(p.totalRelated >= 7);
});

test('nonaktifkan lalu aktifkan akun login', async () => {
  await setDisabled(auth, db, 'pas2', true, 'admin1');
  assert.equal((await auth.getUser('pas2')).disabled, true);
  assert.equal((await db.doc('users/pas2').get()).data().accountDisabled, true);
  await setDisabled(auth, db, 'pas2', false, 'admin1');
  assert.equal((await auth.getUser('pas2')).disabled, false);
});

test('hapus keluarga tidak menyentuh catatan pasiennya', async () => {
  const r = await deleteUserCompletely(auth, db, 'kel1', 'admin1');
  assert.equal(r.authDeleted, true);
  assert.equal((await db.doc('users/kel1').get()).exists, false);
  await assert.rejects(auth.getUser('kel1'));
  // Catatan pasien tetap ada.
  assert.equal(await count('food_logs', 'noKode', 'K1'), 3);
  assert.equal(await count('hba1c_logs', 'noKode', 'K1'), 1);
  assert.equal((await db.doc('users/pas1').get()).exists, true);
  // Notifikasi dari/ke keluarga terhapus.
  assert.equal(await count('reminders', 'fromUserId', 'kel1'), 0);
  assert.equal(await count('reminders', 'toUserId', 'kel1'), 0);
});

test('hapus pasien membersihkan semua datanya, pasien lain aman', async () => {
  const r = await deleteUserCompletely(auth, db, 'pas1', 'admin1');
  assert.equal(r.authDeleted, true);
  assert.equal(r.profileDeleted, true);
  assert.equal(await count('food_logs', 'noKode', 'K1'), 0);
  assert.equal(await count('hba1c_logs', 'noKode', 'K1'), 0);
  assert.equal(await count('chat_messages', 'noKode', 'K1'), 0);
  assert.equal(await count('reminders', 'toUserId', 'pas1'), 0);
  // Pasien lain tidak tersentuh.
  assert.equal(await count('food_logs', 'noKode', 'K2'), 3);
  assert.equal(await count('reminders', 'toUserId', 'pas2'), 1);
  assert.equal((await db.doc('users/pas2').get()).exists, true);
  // Audit tercatat.
  assert.ok((await db.collection('admin_audit').where('targetUid', '==', 'pas1').get()).size === 1);
});

test('hapus pengguna yang sudah tidak ada tidak error', async () => {
  const r = await deleteUserCompletely(auth, db, 'tidak-ada', 'admin1');
  assert.equal(r.authDeleted, false);
  assert.equal(r.profileDeleted, false);
});
