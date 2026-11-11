# Changelog

## 1.2.0 — Perbaikan UI Perangkat & halaman Pengaturan
- Perangkat: Scaffold/AppBar ganda pada state loading dan kosong dihapus (sebelumnya tampil dua AppBar).
- Perangkat: header ringkasan kini memakai `Wrap` sehingga tidak overflow pada layar 360 dp; refresh dipindah ke AppBar.
- Perangkat: daftar menampilkan indikator state kanal dari hasil monitoring, serta alasan bila kontrol diblokir.
- Dialog kontrol dijadikan `ConsumerWidget`: progres pengiriman benar-benar tampil, kontrol per kanal tersedia, `Semua ON/OFF` hanya untuk perangkat multi-kanal, dan hasil/error ditampilkan lewat SnackBar (sebelumnya exception perintah tidak tertangani).
- Kontrol hanya dikirim bila backend menyediakan `switch_dp` dan perangkat aktif serta tidak `verification_required`; fallback DP `switch_1` yang ditebak dihapus.
- Detail perangkat: state kanal diambil dari `GET /api/v1/devices/{logical_id}/state` sebagai satu sumber, status koneksi tetap terpisah dari state kanal, dan data dimuat ulang setelah perintah.
- Pemetaan tipe perangkat mengikuti kategori pada `docs/device-reference` (`cz`, `kg`, `tdq`, `wnykq`, `qt`); kategori lain memakai field `type` backend apa adanya.
- Halaman Pengaturan baru pada `/settings`, dibuka dari ikon di Home: status `/health`, konfigurasi base URL dan timeout, status monitoring dengan periksa manual, informasi aplikasi, serta daftar modul yang belum tersedia.
- Design system: token spacing, `NavigationRailTheme` terpusat, `ChipTone.info` memakai warna info, komponen bersama `SectionCard`/`InfoRow`/`ErrorState`, dan pemetaan pesan error tunggal `describeApiError`.
- Label "Phase 1 · Foundation" pada Home diganti "Mobile V2".
- Test: 35 test lulus (baru: pemetaan tipe perangkat, pemetaan pesan error, layar Perangkat pada lebar 360 dp, dialog kontrol, navigasi Pengaturan, dialog kontrol kanal, statistik perangkat, dan sinkronisasi versi). Tidak ada endpoint baru; Energi, CCTV, dan Voice tetap belum diaktifkan.
- Perbaikan hasil validasi: judul kartu "Ringkasan lokasi" tidak lagi overflow pada 320/360 dp, dialog kontrol kanal tidak dapat ditutup lewat barrier selama perintah dikirim (dan penyelesaiannya tidak mem-pop halaman detail), jumlah perangkat "didukung" tidak pernah negatif, dan versi aplikasi dijaga tetap sama dengan `pubspec.yaml` melalui test.

## 1.1.0 — Integrasi LAN
- Menambahkan pemeriksaan koneksi backend aktual melalui `GET /health`: status belum diperiksa, memeriksa, terhubung, atau tidak terhubung (beserta pesan kegagalan dan waktu pemeriksaan). Status "terhubung" hanya muncul setelah ada respons nyata dari backend.
- Home dashboard memakai data aktual: status koneksi backend, total perangkat, jumlah perangkat didukung/perlu verifikasi, online/offline/unknown dari hasil monitoring, ringkasan lokasi, serta waktu pembaruan data.
- Ringkasan monitoring pada layar Perangkat kini menampilkan interval monitoring dan waktu pemeriksaan terakhir dari backend.
- Android: permission `INTERNET` ditambahkan ke manifest utama, dan cleartext HTTP hanya diizinkan untuk host backend LAN pada build debug melalui network security config (release tetap HTTPS-only).

## 1.0.0 — Documentation baseline
- Menetapkan ELFAN Mobile V2 untuk implementasi Alwustho dan arah multi-organization/personal.
- Menyusun PRD, arsitektur konseptual, role/access, spesifikasi fitur, UI/UX, API audit, model data, flow, roadmap, dan testing.
- Menetapkan aturan coding agent.
- Menandai endpoint dan keputusan yang belum diverifikasi sebagai TBD/perlu audit.
