// Operasi akun pengguna (pasien / keluarga) yang butuh Admin SDK:
// menonaktifkan akun login dan menghapus pengguna beserta datanya.

/** Koleksi catatan yang terhubung ke pasien lewat `noKode`. */
export const PATIENT_COLLECTIONS = [
  'food_logs',
  'medication_logs',
  'foot_care_logs',
  'stress_management_logs',
  'latihan_fisik_logs',
  'aktivitas_tidur_logs',
  'blood_sugar_logs',
  'glucose_logs',
  'hba1c_logs',
  'chat_messages',
];

/**
 * Daftar query yang datanya ikut terhapus bila pengguna dihapus.
 * - Pasien: semua catatan dengan noKode-nya + notifikasi ke/dari dia
 *   + notifikasi untuk noKode-nya yang belum punya penerima.
 * - Keluarga: hanya notifikasi ke/dari dia. Catatan pasien TIDAK disentuh.
 */
export function relatedQueries(db, uid, user) {
  const queries = [];
  const role = user?.role;
  const noKode = (user?.noKode ?? '').toString();

  if (role === 'pasien' && noKode) {
    for (const c of PATIENT_COLLECTIONS) {
      queries.push({ label: c, query: db.collection(c).where('noKode', '==', noKode) });
    }
    queries.push({
      label: 'reminders (noKode, belum terdaftar)',
      query: db.collection('reminders').where('noKode', '==', noKode).where('toUserId', '==', null),
    });
  }
  queries.push({ label: 'reminders (diterima)', query: db.collection('reminders').where('toUserId', '==', uid) });
  queries.push({ label: 'reminders (dikirim)', query: db.collection('reminders').where('fromUserId', '==', uid) });
  return queries;
}

export async function loadUser(db, uid) {
  const snap = await db.collection('users').doc(uid).get();
  return snap.exists ? snap.data() : null;
}

/** Jumlah dokumen per query (agregasi count — murah). */
export async function previewDelete(db, uid) {
  const user = await loadUser(db, uid);
  const counts = {};
  let total = 0;
  for (const { label, query } of relatedQueries(db, uid, user)) {
    const n = (await query.count().get()).data().count;
    if (n > 0) counts[label] = n;
    total += n;
  }
  return {
    uid,
    exists: !!user,
    nama: user?.namaLengkap ?? null,
    role: user?.role ?? null,
    noKode: user?.noKode ?? null,
    counts,
    totalRelated: total,
  };
}

/** Nonaktifkan / aktifkan akun login. Data tidak dihapus. */
export async function setDisabled(auth, db, uid, disabled, adminUid) {
  try {
    await auth.updateUser(uid, { disabled });
  } catch (e) {
    if (e?.code !== 'auth/user-not-found') throw e;
  }
  const ref = db.collection('users').doc(uid);
  if ((await ref.get()).exists) {
    await ref.update({
      accountDisabled: disabled,
      accountDisabledAt: new Date(),
      accountDisabledBy: adminUid,
    });
  }
  // Sesi yang sedang aktif ikut diputus.
  if (disabled) {
    try {
      await auth.revokeRefreshTokens(uid);
    } catch (_) {}
  }
  return { uid, disabled };
}

/**
 * Hapus total: catatan terkait, notifikasi, dokumen profil, lalu akun login.
 * Catatan audit disimpan di `admin_audit`.
 */
export async function deleteUserCompletely(auth, db, uid, adminUid) {
  const user = await loadUser(db, uid);
  const writer = db.bulkWriter();
  const deleted = {};
  const seen = new Set();

  for (const { label, query } of relatedQueries(db, uid, user)) {
    // Halaman 500 agar memori tetap kecil.
    let last = null;
    for (;;) {
      let q = query.orderBy('__name__').limit(500);
      if (last) q = q.startAfter(last);
      const snap = await q.get();
      if (snap.empty) break;
      for (const d of snap.docs) {
        if (seen.has(d.ref.path)) continue;
        seen.add(d.ref.path);
        writer.delete(d.ref);
        deleted[label] = (deleted[label] ?? 0) + 1;
      }
      last = snap.docs[snap.docs.length - 1];
      if (snap.size < 500) break;
    }
  }
  if (user) writer.delete(db.collection('users').doc(uid));
  await writer.close();

  let authDeleted = false;
  try {
    await auth.deleteUser(uid);
    authDeleted = true;
  } catch (e) {
    if (e?.code !== 'auth/user-not-found') throw e;
  }

  const summary = {
    action: 'delete_user',
    targetUid: uid,
    targetNama: user?.namaLengkap ?? null,
    targetRole: user?.role ?? null,
    targetNoKode: user?.noKode ?? null,
    deleted,
    profileDeleted: !!user,
    authDeleted,
    by: adminUid,
    at: new Date(),
  };
  await db.collection('admin_audit').add(summary);
  return summary;
}
