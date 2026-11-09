# Changelog

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
