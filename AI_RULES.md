# AI_RULES.md — Aturan Coding Agent ELFAN V2

## Prinsip utama
1. Dokumentasi dan source code aktual adalah acuan; jangan menebak.
2. Audit repository sebelum mengubah file.
3. Jangan mengarang endpoint, HTTP method, payload, response, schema, permission, atau autentikasi.
4. Jangan mengubah backend Raspberry Pi dalam tugas mobile ini kecuali diminta eksplisit.
5. Jangan menampilkan atau mencetak `.env`, token, password, API key, device secret, atau URL stream sensitif.
6. Jangan menampilkan data dummy seolah-olah data aktual.
7. Jangan menghapus fitur yang sudah berjalan.
8. Jangan mengganti framework, dependency utama, routing, state management, atau arsitektur tanpa alasan teknis dan persetujuan.
9. Jangan hardcode organisasi, tenant, gedung, lantai, ruangan, kamera, dan perangkat Alwustho ke dalam logika produk.
10. Isolasi tenant dan permission wajib ditegakkan backend; filter UI bukan mekanisme keamanan.
11. Jika kontrak API belum jelas, catat gap dan jangan mengaktifkan kontrol yang belum terverifikasi.
12. Jangan menyatakan selesai sebelum test dijalankan dan hasilnya dilaporkan.

## Baseline teknis yang diketahui
- Aplikasi: Flutter + Dart.
- State management: Riverpod.
- HTTP client: Dio.
- Backend existing: FastAPI pada Raspberry Pi.
- Endpoint yang pernah diverifikasi: `GET /api/v1/devices`, `GET /api/v1/monitoring/status`, `POST /api/v1/monitoring/check`.
- Base URL dikonfigurasi melalui `ELFAN_API_BASE_URL`; jangan hardcode URL di source.
- Versi dependency dan struktur repository wajib diperiksa dari `pubspec.yaml` dan source aktual, jangan mengandalkan angka versi dari dokumen lama.

## Standar implementasi
- Pertahankan feature-based architecture yang sudah ada.
- Pisahkan presentation, state/provider, repository, service, dan model sesuai pola proyek.
- UI berkomunikasi dengan backend; UI tidak memanggil Tuya/device adapter secara langsung.
- Sediakan loading, empty, error, retry, dan success state yang sesuai.
- Parse JSON secara defensif; field opsional boleh null/tidak ada.
- Bedakan status koneksi perangkat dengan state kanal (ON/OFF).
- Jangan menampilkan Device ID mentah di UI kecuali memang diperlukan untuk halaman diagnostik berizin.
- Hindari logging payload sensitif dan data identifikasi perangkat.
- Gunakan tema, komponen, routing, dan pola UI yang telah ada.

## Alur kerja
1. Baca README, AI_RULES, tujuh referensi perangkat, dan prompt implementasi.
2. Audit struktur dan implementasi Flutter saat ini.
3. Audit kontrak API dari backend source/OpenAPI yang benar-benar tersedia.
4. Buat rencana singkat dan daftar file yang akan diubah.
5. Implementasikan secara bertahap dengan perubahan minimal.
6. Jalankan formatter, analyzer, dan test relevan.
7. Laporkan perubahan, perintah pengujian, hasil, gap, serta pekerjaan yang belum dilakukan.

## Definition of Done
- Implementasi sesuai kontrak backend yang terverifikasi.
- Tidak ada endpoint atau payload rekaan.
- Tidak ada credential atau secret yang bocor.
- Loading/empty/error/success state ditangani.
- `dart format`, `flutter analyze`, dan test relevan dijalankan.
- Dokumentasi dan changelog diperbarui bila perilaku atau kontrak berubah.
