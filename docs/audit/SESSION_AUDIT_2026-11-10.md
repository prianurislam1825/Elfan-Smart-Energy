# Audit & Implementasi Sesi — 10 November 2026

Dokumen ini mencatat FASE 1 (audit), urutan implementasi, file yang berubah,
dan hasil pengujian pada sesi ini. Sumber kebenaran tetap `AI_RULES.md` dan
dokumentasi proyek.

## 1. Batasan verifikasi

- Backend LAN `192.168.20.137:8000` **tidak dapat dijangkau** dari lingkungan
  kerja (`GET /health` dan `GET /openapi.json` → tidak ada respons).
- Karena itu kontrak yang dipakai tetap kontrak terverifikasi yang sudah
  tercatat di `docs/06_API_DOCUMENTATION.md`. Tidak ada endpoint, payload,
  model, atau permission baru yang dibuat.
- Growatt/energi, CCTV, dan Voice tidak memiliki endpoint backend yang
  terverifikasi (`docs/audit/GROWATT_INTEGRATION_IMPLEMENTATION_PLAN.md` §1.3),
  sehingga modul tersebut tidak dihubungkan dan tetap menampilkan status
  "belum tersedia".

## 2. Kondisi awal (sebelum perubahan)

| Modul | Status | Catatan |
|---|---|---|
| Foundation (theme, router, shell, Dio, Riverpod) | Selesai | `flutter analyze` bersih, 16 test lulus |
| Home/Dashboard | Selesai | Data backend nyata: `/health`, `/api/v1/devices`, `/api/v1/monitoring/status` |
| Perangkat — daftar | Sebagian | Data nyata, tetapi ada bug UI/UX nyata (lihat §3) |
| Perangkat — detail | Sebagian | Informasi + `/state`, tetapi state kanal tidak dipakai di daftar kanal |
| Perangkat — kontrol | Sebagian | Payload `{switch_dp: bool}`; beberapa kontrol tidak aman |
| Energi | Belum dibuat | Placeholder; endpoint belum ada |
| CCTV | Belum dibuat | Placeholder; endpoint belum ada |
| Voice | Belum dibuat | Placeholder; endpoint belum ada |
| Pengaturan | Belum ada | Tidak ada route maupun layar |

## 3. Temuan audit yang diperbaiki

1. `DevicesScreen` mengembalikan `Scaffold` kedua dari dalam `body` untuk state
   loading/kosong sehingga muncul dua AppBar dan dua `SafeArea`.
2. Header ringkasan memakai `Row` berisi tiga `InfoChip` + tombol refresh yang
   overflow pada lebar 360 dp.
3. Dialog kontrol memanggil `ref.watch` di dalam callback (`_showControlDialog`),
   sehingga dialog bukan `Consumer` dan progres pengiriman tidak pernah tampil.
4. Exception dari perintah kontrol (`rethrow` di notifier) tidak ditangkap di
   UI: pengguna tidak mendapat umpan balik kegagalan.
5. Kontrol tetap diaktifkan untuk perangkat `enabled == false` dan perangkat
   tanpa `channels`; DP `switch_1` dipakai sebagai cadangan tebakan.
6. Dialog kontrol menampilkan "Nyalakan Semua"/"Matikan Semua" untuk perangkat
   satu kanal.
7. Detail perangkat menampilkan kondisi kanal "belum tersedia" padahal
   `GET /api/v1/devices/{id}/state` sudah tersedia di provider.
8. Ikon tipe perangkat salah (sakelar memakai ikon termometer, smart plug ikon
   angin, remote IR ikon bluetooth) dan logika label diduplikasi.
9. `_ErrorView` menambahkan page padding lagi di dalam `ListView` (padding
   ganda) dan pesan error ditebak lewat pencocokan `toString()`.
10. `ChipTone.info` memakai warna netral sehingga tidak konsisten.
11. Tidak ada akses ke pengaturan sistem; tidak ada route `/settings`.

## 4. Urutan implementasi (dependensi)

1. Komponen/utility bersama: `device_type`, `describeApiError`, `SectionCard`,
   `InfoRow`, `ErrorState`, helper status perangkat, token spacing.
2. Theme: `NavigationRailTheme` terpusat, perbaikan `ChipTone.info`.
3. Routing: route `/settings`.
4. Data/state: pengetatan `DeviceControlNotifier` (tanpa tebakan DP, menolak
   perangkat nonaktif/verifikasi/tanpa kanal).
5. UI: daftar perangkat, dialog kontrol, detail perangkat, Home, Pengaturan.
6. Validasi: `dart format`, `flutter analyze`, `flutter test`.

## 5. File yang berubah

### Baru
- `lib/core/utils/device_type.dart` — pemetaan kategori perangkat ke label/ikon
  berdasarkan `docs/device-reference`.
- `lib/shared/utils/error_message.dart` — `describeApiError` (satu pemetaan
  pesan error).
- `lib/shared/widgets/section_card.dart` — kartu berjudul standar.
- `lib/shared/widgets/info_row.dart` — baris label–nilai standar.
- `lib/shared/widgets/error_state.dart` — state error dengan aksi coba lagi.
- `lib/features/devices/widgets/device_status.dart` — label/tone/ikon status
  koneksi dan state kanal.
- `lib/features/settings/screens/settings_screen.dart` — halaman Pengaturan.
- `test/core/device_type_test.dart`, `test/shared/error_message_test.dart`,
  `test/widgets/devices_screen_test.dart`.
- `docs/audit/SESSION_AUDIT_2026-11-10.md` — dokumen ini.

### Diubah
- `lib/core/theme/component_theme.dart` — token spacing + `navigationRailTheme`.
- `lib/core/theme/app_theme.dart` — mendaftarkan tema navigation rail.
- `lib/core/constants/app_constants.dart` — label platform + versi aplikasi;
  label fase usang dihapus.
- `lib/core/routing/app_routes.dart`, `lib/core/routing/app_router.dart` —
  route `/settings`.
- `lib/shared/widgets/info_chip.dart` — `ChipTone.info` memakai warna info.
- `lib/shared/widgets/app_shell.dart` — memakai `NavigationRailTheme`.
- `lib/data/providers/device_control_provider.dart` — guard kontrol, penghapusan
  tebakan DP dan perintah custom tanpa kontrak.
- `lib/data/services/api_exception.dart` — jenis `unsupported`.
- `lib/features/dashboard/screens/home_screen.dart` — aksi Pengaturan, label
  platform, pemetaan error tunggal.
- `lib/features/devices/screens/devices_screen.dart` — perbaikan UI/UX daftar
  dan dialog kontrol.
- `lib/features/devices/screens/device_detail_screen.dart` — state kanal dari
  `/state`, kontrol aman, umpan balik perintah.
- `test/widget_test.dart` — test navigasi Pengaturan.
- `CHANGELOG.md` — entri 1.2.0.

### Tidak diubah
- `ApiClient`, konfigurasi base URL, interceptor logging, model JSON, dan
  kontrak endpoint. Tidak ada perubahan backend.

## 6. Validasi

| Perintah | Hasil |
|---|---|
| `dart format lib test` | Berhasil (format diterapkan pada file yang berubah) |
| `flutter analyze` | `No issues found!` |
| `flutter test` | `All tests passed!` — 29 test |

Test baru mencakup: pemetaan kategori `cz/kg/tdq/wnykq/qt` dan kategori tak
dikenal, pemetaan pesan error, render layar Perangkat pada 360×800 tanpa
overflow beserta indikator kanal, pembukaan dialog kontrol, penonaktifan
kontrol untuk perangkat `verification_required`, dan navigasi Home →
Pengaturan.

Tidak ada kontrol perangkat fisik yang dijalankan; widget test memakai
repository palsu yang tidak mengirim perintah.

## 7. Gap yang belum diselesaikan

| Gap | Alasan |
|---|---|
| Energi/inverter (Growatt) | Tidak ada endpoint `/api/v1/energy/*`; backend tidak terjangkau untuk verifikasi |
| CCTV + WebRTC MediaMTX | Tidak ada endpoint katalog kamera/signaling; dependency WebRTC belum ada di `pubspec.yaml` |
| Voice PTT | Tidak ada endpoint unggah audio/respons; permission mikrofon & perekam belum ditambahkan karena belum ada alur terverifikasi |
| Autentikasi, sesi, logout, tenant context | Kontrak auth belum ditetapkan |
| Riwayat aktivitas, notifikasi, produktivitas | Endpoint belum tersedia |
| Kontrol perangkat pada perangkat fisik | Butuh target uji dan persetujuan eksplisit pemilik sistem |
