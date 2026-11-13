# Layanan Promedia di VPS

Pengganti Cloud Functions (Firebase tetap paket **Spark**). Dipakai Admin Panel untuk operasi yang
butuh Firebase Admin SDK: menonaktifkan dan menghapus akun login pengguna.

VPS ini **dipakai bersama** aplikasi lain (Jungle Guide, SIDAKAR, gkii.org, jostar.id, tinyproxy/flash-kuota).
Jangan ubah apa pun di luar bagian Promedia di bawah ini.

| | |
|---|---|
| VPS | Tencent Lighthouse Jakarta, `43.173.34.20`, Ubuntu 24.04, 2 vCPU, RAM 1,9 GB |
| SSH | `ssh -i ~/.ssh/flashkuota_proxy ubuntu@43.173.34.20` |
| Domain API | `https://api-promedia.jostar.id` (DNS A di DomaiNesia → 43.173.34.20) |
| Firebase project | `app-jarak-penentu` |

## Susunan

| Bagian | Lokasi |
|---|---|
| User sistem | `promedia` (tanpa login, tanpa home) |
| Kode | `/opt/promedia/app` (src + node_modules produksi) |
| Node pribadi | `/opt/promedia/node` (v22.23.3, checksum diverifikasi). Node sistem tidak disentuh |
| Konfigurasi | `/opt/promedia/.env` (600) |
| Kunci service account | `/opt/promedia/secrets/service-account.json` (600). Service account `promedia-vps@app-jarak-penentu.iam.gserviceaccount.com`, peran **Firebase Authentication Admin** + **Cloud Datastore User** saja. Kunci dibuat langsung ke VPS, tidak pernah disimpan di Mac |
| Service | `promedia-api.service` — `127.0.0.1:8750`, `MemoryMax=160M`, `CPUQuota=25%`, `ProtectSystem=strict` (pemakaian normal ±40 MB) |
| Reverse proxy | Blok `api-promedia.jostar.id` di akhir `/etc/caddy/Caddyfile`. Sertifikat Let's Encrypt otomatis oleh Caddy |

## Endpoint

Semua `/v1/*` wajib header `Authorization: Bearer <Firebase ID token>` milik **admin aktif** (koleksi `admins`).

| Method | Path | Fungsi |
|---|---|---|
| GET | `/health` | Cek hidup (tanpa login) |
| GET | `/v1/users/:uid/delete-preview` | Jumlah data yang akan ikut terhapus (tidak menghapus apa pun) |
| POST | `/v1/users/:uid/disable` `{ "disabled": true\|false }` | Nonaktifkan / aktifkan akun login; sesi aktif diputus |
| DELETE | `/v1/users/:uid` | Hapus permanen: akun login, profil, notifikasi; untuk pasien juga semua catatan aktivitas & chat dengan `noKode`-nya. Akun keluarga tidak menyentuh catatan pasien. Dicatat di koleksi `admin_audit` |

## Pekerjaan rutin

Deploy kode (dari Mac, folder `server/`):

```bash
./scripts/deploy.sh
```

Log & restart:

```bash
ssh -i ~/.ssh/flashkuota_proxy ubuntu@43.173.34.20 'sudo journalctl -u promedia-api -n 50 --no-pager'
```

```bash
ssh -i ~/.ssh/flashkuota_proxy ubuntu@43.173.34.20 'sudo systemctl restart promedia-api'
```

Tes (emulator lokal, bukan produksi):

```bash
firebase emulators:exec --only auth,firestore --project demo-promedia "npm --prefix server test"
```

## Pemasangan ulang dari nol

1. `scp server/scripts/setup-vps.sh` ke VPS, lalu `sudo bash setup-vps.sh` (user, folder, Node, `.env`).
2. Buat kunci service account langsung ke VPS:
   `gcloud iam service-accounts keys create /dev/stdout --iam-account promedia-vps@app-jarak-penentu.iam.gserviceaccount.com | ssh … 'sudo install -o promedia -g promedia -m 600 /dev/stdin /opt/promedia/secrets/service-account.json'`
3. `cd server && ./scripts/deploy.sh`.
4. Tambahkan blok Caddy (lihat di atas), `sudo caddy validate --config /etc/caddy/Caddyfile`, `sudo systemctl reload caddy`.

## Jika VPS mati

Aplikasi pasien/keluarga dan Admin Panel tetap jalan. Yang tidak bisa sementara: menonaktifkan dan menghapus
akun dari Admin Panel (muncul pesan "Layanan server Promedia tidak dapat dihubungi").
