// Promedia API di VPS — dipanggil Admin Panel untuk operasi yang butuh
// Firebase Admin SDK (tidak bisa dari browser).
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { initializeApp, getApps } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { deleteUserCompletely, previewDelete, setDisabled } from './users.js';
import { Scheduler } from './scheduler.js';
import { PushSender } from './push.js';

const VERSION = '0.2.0';
const PORT = Number(process.env.PORT ?? 8750);
const HOST = process.env.HOST ?? '127.0.0.1';
const ORIGINS = (process.env.CORS_ORIGINS ?? 'https://promedia-v2.vercel.app')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

// Kredensial dari GOOGLE_APPLICATION_CREDENTIALS (service account).
if (!getApps().length) initializeApp({ projectId: process.env.FIREBASE_PROJECT_ID });
const auth = getAuth();
const db = getFirestore();

const app = Fastify({ logger: { level: process.env.LOG_LEVEL ?? 'info' } });
await app.register(cors, {
  origin: ORIGINS,
  methods: ['GET', 'POST', 'DELETE'],
  allowedHeaders: ['Authorization', 'Content-Type'],
});

/** Hanya admin aktif (koleksi `admins`) yang boleh memanggil /v1. */
async function requireAdmin(req, reply) {
  const header = req.headers.authorization ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return reply.code(401).send({ error: 'Token tidak ada' });
  let decoded;
  try {
    decoded = await auth.verifyIdToken(token, true);
  } catch {
    return reply.code(401).send({ error: 'Token tidak valid' });
  }
  const snap = await db.collection('admins').doc(decoded.uid).get();
  const a = snap.data();
  if (!snap.exists || a.isActive === false || !['admin', 'superadmin'].includes(a.role)) {
    return reply.code(403).send({ error: 'Bukan admin aktif' });
  }
  req.admin = { uid: decoded.uid, role: a.role };
}

const uidParam = {
  params: {
    type: 'object',
    required: ['uid'],
    properties: { uid: { type: 'string', minLength: 1, maxLength: 128 } },
  },
};

// Pengingat terjadwal (default aktif) & push FCM (default mati sampai
// aplikasi mobile menyimpan token dan service account punya izin FCM).
const scheduler = process.env.SCHEDULER_ENABLED === '0' ? null : new Scheduler(db, app.log);
const push = process.env.PUSH_ENABLED === '1' ? new PushSender(db, getMessaging(), app.log) : null;

app.get('/health', async () => ({
  ok: true,
  service: 'promedia',
  version: VERSION,
  scheduler: scheduler ? scheduler.stats : 'off',
  push: push ? push.stats : 'off',
}));

app.register(async (v1) => {
  v1.addHook('preHandler', requireAdmin);

  v1.get('/users/:uid/delete-preview', { schema: uidParam }, async (req) =>
    previewDelete(db, req.params.uid),
  );

  v1.post(
    '/users/:uid/disable',
    {
      schema: {
        ...uidParam,
        body: {
          type: 'object',
          required: ['disabled'],
          properties: { disabled: { type: 'boolean' } },
        },
      },
    },
    async (req) => {
      const r = await setDisabled(auth, db, req.params.uid, req.body.disabled, req.admin.uid);
      req.log.info({ uid: req.params.uid, disabled: req.body.disabled, by: req.admin.uid }, 'set disabled');
      return r;
    },
  );

  v1.delete('/users/:uid', { schema: uidParam }, async (req, reply) => {
    if (req.params.uid === req.admin.uid) {
      return reply.code(400).send({ error: 'Tidak bisa menghapus akun sendiri' });
    }
    const r = await deleteUserCompletely(auth, db, req.params.uid, req.admin.uid);
    req.log.info({ uid: req.params.uid, deleted: r.deleted, by: req.admin.uid }, 'user deleted');
    return r;
  });
}, { prefix: '/v1' });

/** Firestore menolak karena kuota harian habis (gRPC 8 / HTTP 429). */
function isQuotaExhausted(err) {
  return err?.code === 8 || err?.code === 'resource-exhausted' || /RESOURCE_EXHAUSTED|Quota exceeded/i.test(err?.message ?? '');
}

app.setErrorHandler((err, req, reply) => {
  req.log.error(err);
  if (isQuotaExhausted(err)) {
    return reply.code(503).send({
      error: 'Kuota database harian sedang habis. Coba lagi setelah pukul 15.00 WIB.',
    });
  }
  const status = err.statusCode && err.statusCode < 500 ? err.statusCode : 500;
  reply.code(status).send({ error: status === 500 ? 'Terjadi kesalahan di server' : err.message });
});

await app.listen({ port: PORT, host: HOST });
scheduler?.start();
push?.start();

for (const sig of ['SIGTERM', 'SIGINT']) {
  process.once(sig, async () => {
    scheduler?.stop();
    push?.stop();
    await app.close();
    process.exit(0);
  });
}
