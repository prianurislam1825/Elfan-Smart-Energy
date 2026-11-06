# AI_RULES.md — Aturan Agent ELFAN Mobile V2

Dokumen ini wajib dibaca Freebuf CLI atau AI coding agent sebelum mengubah repository.

## Peran dan aturan
1. Baca README dan dokumen yang relevan sebelum bekerja.
2. Audit file/implementasi aktual sebelum menyimpulkan kondisi proyek.
3. Jangan mengarang endpoint, method, payload, response, schema, atau mekanisme autentikasi.
4. Jangan mengubah backend Raspberry Pi kecuali tugas secara eksplisit meminta.
5. Jangan menyimpan token, password, API key, atau credential di source, dokumentasi publik, commit, atau log.
6. Jangan menyajikan data dummy sebagai data aktual.
7. Jangan menghapus fitur berjalan tanpa persetujuan.
8. Jangan mengganti framework, dependency utama, atau arsitektur tanpa persetujuan.
9. Jangan hardcode nama organisasi, gedung, lantai, ruangan, kamera, dan perangkat Alwustho.
10. Isolasi tenant wajib ditegakkan backend; filter UI bukan keamanan.
11. Jangan mengklaim selesai sebelum implementasi dan pengujian berhasil.
12. Jika kontrak belum jelas, lakukan audit dan laporkan gap; jangan menebak.

## Stack baseline
- Flutter + Dart.
- Riverpod (`flutter_riverpod`).
- GoRouter.
- Dio.
- Shared Preferences untuk preferensi non-rahasia.
- Backend existing: FastAPI pada Raspberry Pi.
- Tuya, MediaMTX WebRTC, Voice API/Command Engine, dan energy source melalui integrasi yang diverifikasi.

Versi saat ini: Flutter 3.35.4, Dart 3.9.2, dio 5.11.1, flutter_riverpod 3.3.2, go_router 17.2.3, shared_preferences 2.5.5. Jangan upgrade massal tanpa tugas khusus.

## Arsitektur kode
Gunakan feature-based structure. Pisahkan presentation, state, repository, service, dan model. UI tidak memanggil adapter perangkat langsung. Mobile berkomunikasi melalui backend.

## Alur setiap tugas
Sebelum coding: pahami tugas, baca dokumen, periksa file, verifikasi API dependency, buat rencana singkat.
Saat coding: ubah file seperlunya, hindari refactor tak diminta, sediakan loading/empty/error/success states, tangani timeout, jangan masukkan secret.
Setelah coding: jalankan `dart format` pada file terkait, `flutter analyze`, test relevan, lalu laporkan file berubah, perintah, hasil, dan keterbatasan.

## Keamanan
Jangan meminta `.env` atau credential. Jangan log token, password, audio, atau URL stream sensitif. Minta izin runtime Android. Backend memvalidasi tenant dan permission. Gunakan HTTPS di produksi. Shared Preferences bukan tempat menyimpan secret; gunakan secure storage setelah mekanisme auth ditetapkan.

## Definition of Done
Sesuai requirement, tidak melanggar arsitektur, tidak memalsukan data, tidak membocorkan secret, analyze bersih, test relevan lulus atau dijelaskan, dan dokumentasi diperbarui.
