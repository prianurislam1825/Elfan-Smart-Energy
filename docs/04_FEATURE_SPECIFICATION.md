# Feature Specification

## Home
Ringkasan tenant/properti aktif, perangkat, online/offline, lokasi, monitoring, energi, notifikasi, quick actions. State wajib: loading, success, partial, empty, error, stale. Semua metrik harus dari API aktual.

## Perangkat
List/detail/filter/status/control/refresh/history. Hierarki tenant/personal → property/building → floor opsional → room/area → device. Jenis awal switch, plug, bulb, Universal IR Controller dan appliance IR jika didukung. Semua kontrol melalui backend DeviceController. Jangan mengasumsikan status berubah sebelum hasil terkonfirmasi.

Catatan inventaris historis: 23 active devices; 18 Tuya switch/plug/bulb dimonitor; 5 logical IR virtual devices belum didukung monitoring generik; dua Universal IR controller fisik pernah disebutkan. Verifikasi ulang; jangan hardcode angka ini.

## Voice Assistant
PTT saja untuk MVP; wake word tidak termasuk. Permission mic, record, stop/cancel, upload, STT/intent, command processing, response/TTS. Perintah ambigu meminta klarifikasi. Kontrol wajib permission. Jangan merekam tanpa tindakan eksplisit.

## CCTV
MediaMTX WebRTC. Daftar, lokasi, live view, multi-camera, status, reconnect. Wajib audit signaling, auth, URL, codec, remote access. Hentikan player saat meninggalkan layar.

## Energi
Metrik sesuai data tersedia: power, voltage, current, energy, history/chart, solar/inverter. Unit/timestamp/source/quality harus jelas. Null bukan nol. Definisi perhitungan mengikuti backend/perangkat.

## Productivity
Field: user, period, location, completed work, obstacles, next plan. Pola dua jam. Create/view/filter/edit sesuai permission. API dan approval flow perlu audit.

## Notifications dan History
Offline, failed control, connectivity, system, energy warning jika didukung. Event memuat actor, time, target, action, outcome bila tersedia.

## Profile/Settings
Profil, konteks aktif, preferensi, notifikasi, tema, diagnostik aman, logout, versi aplikasi.

## Tenant context
Pergantian konteks harus memuat ulang data dan membersihkan/memisahkan cache. Backend tetap memvalidasi setiap akses.
