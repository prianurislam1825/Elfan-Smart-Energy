# Development Roadmap

## Phase 0 — Documentation and audit
Baca dokumen, audit struktur Flutter/dependencies, audit backend routes/schema tanpa mengubah backend, buat API inventory dan gap list.
**Exit:** laporan kondisi aktual dan keputusan terbuka.

## Phase 1 — Flutter foundation
Theme, app entry, GoRouter, Riverpod, Dio/error mapping, environment config, app shell, bottom navigation.
**Exit:** aplikasi berjalan, navigasi bekerja, analyze bersih.

## Phase 2 — Authentication and context
Auth sesuai API aktual, session lifecycle, tenant/personal context, permission-aware navigation.
**Exit:** scope/session dapat diuji; tidak ada credential hardcoded.

## Phase 3 — Dashboard and locations
Dashboard, location hierarchy, loading/empty/error/stale.
**Exit:** data aktual backend.

## Phase 4 — Device management
List/detail/filter, monitoring, control, history jika tersedia.
**Exit:** kontrol melalui DeviceController dan diuji pada target yang disetujui.

## Phase 5 — Voice PTT
Permission, recording, upload, STT/command response, TTS, cancel/error.
**Exit:** alur end-to-end dengan API aktual.

## Phase 6 — CCTV
Camera list, WebRTC, multi-camera, lifecycle/reconnect.
**Exit:** stream berizin dapat diputar dan resource dibersihkan.

## Phase 7 — Energy
Telemetry, chart/history, solar/inverter bila API tersedia.
**Exit:** data dan unit diverifikasi.

## Phase 8 — Productivity/supporting
Reports, notifications, activity history, profile/settings.
**Exit:** operasi sesuai permission dan API.

## Phase 9 — Hardening/release
Security, performance, network resilience, Android permissions, device matrix, release build.
**Exit:** acceptance criteria MVP terpenuhi.

## Template task
Setiap task menyebut tujuan, dokumen rujukan, file diperiksa/diubah, API dependency, acceptance criteria, test plan, dan out of scope.
