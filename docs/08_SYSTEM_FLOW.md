# System Flows

## Startup
1. App memuat konfigurasi non-rahasia.
2. Memeriksa session sesuai mekanisme backend.
3. Jika belum login, tampilkan auth.
4. Jika valid, muat profil dan konteks tenant/personal.
5. Muat dashboard.
6. Saat gagal, tampilkan error/retry; jangan tampilkan data palsu.

## Tenant/personal context
1. User memilih konteks yang tersedia.
2. App meminta data konteks.
3. Backend memvalidasi membership/ownership.
4. App mengganti scope dan memuat ulang data.
5. Cache scope lama dipisahkan/dibersihkan.
6. Backend tetap memvalidasi setiap request.

## Device monitoring
1. User membuka dashboard/perangkat.
2. App meminta status.
3. Backend mengembalikan hasil monitoring.
4. App memetakan online/offline/unknown/unsupported.
5. Tampilkan timestamp/stale jika tersedia.
6. Jika gagal, jangan menebak status.

## Device control
1. User memilih device dan aksi.
2. UI memeriksa permission untuk UX.
3. App mengirim command ke endpoint terverifikasi.
4. Backend memvalidasi auth, tenant, permission, target.
5. Backend menggunakan DeviceController.
6. Adapter mengirim perintah.
7. Backend mengembalikan hasil.
8. App menampilkan sukses/gagal.
9. Timeout dengan hasil tidak pasti tidak boleh retry buta.

## Push-to-Talk
1. User menekan mic.
2. App meminta izin.
3. App merekam dengan indikator.
4. User stop/cancel.
5. Audio dikirim melalui kontrak Voice API.
6. Backend memproses STT dan intent.
7. Jika command, backend validasi akses dan jalankan flow kontrol.
8. Backend menyiapkan jawaban/TTS.
9. App menampilkan dan memutar respons.
10. Error ditampilkan secara informatif.

## CCTV
1. App meminta kamera sesuai permission.
2. User memilih kamera.
3. App memperoleh stream/session reference melalui mekanisme terverifikasi.
4. WebRTC player memulai koneksi MediaMTX.
5. UI menunjukkan loading/live/disconnected/error.
6. Saat keluar halaman, player/resource dilepas.

## Energy
App meminta data periode/lokasi; backend mengembalikan telemetry; UI menampilkan nilai, unit, timestamp, quality. Null ditampilkan sebagai tidak tersedia, bukan nol.

## Productivity
User mengisi periode, lokasi, pekerjaan selesai, kendala, rencana. App validasi input; backend validasi user/tenant/lokasi; hasil dan histori ditampilkan.

## Logout
Akhiri/revoke session jika didukung; bersihkan credential/session dan cache sensitif; kembali ke auth screen.
