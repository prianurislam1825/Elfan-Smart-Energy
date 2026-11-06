# System Architecture — ELFAN Mobile V2

**Status:** baseline konseptual; detail kontrak wajib diverifikasi.

## 1. Prinsip
Flutter adalah client/presentation layer. FastAPI menjadi pusat API, autentikasi, otorisasi, logika bisnis, orkestrasi perangkat, dan integrasi. Adapter perangkat tidak dipanggil langsung oleh UI.

## 2. Komponen
- **Flutter Mobile:** UI, routing, Riverpod, Dio, preferensi lokal, audio PTT, WebRTC player.
- **FastAPI:** backend existing pada Raspberry Pi, source `~/cv-engine`.
- **Device control:** Mobile → FastAPI → service/controller → adapter/protocol → perangkat. `DeviceController` adalah entry point kontrol yang telah ditetapkan.
- **Tuya:** adapter berada di backend; credential tidak berada di mobile.
- **MediaMTX:** WebRTC untuk live CCTV; signaling, URL, token, dan remote access perlu audit.
- **Voice:** PTT → Voice API/backend → STT/intent → command engine → DeviceController jika perlu → respons/TTS.
- **Energy:** data melalui API/backend; sumber sensor, unit, interval, retention perlu inventarisasi.

## 3. Lingkungan diketahui
- Raspberry Pi hostname `alwustho123`.
- IP LAN pernah digunakan `192.168.20.137`.
- FastAPI port `8000`; Swagger `http://192.168.20.137:8000/docs`.
- Backend folder `~/cv-engine`.
- Flutter project `D:\Alwustho\Elfan Mobile\elfan_mobile`.
IP LAN bukan alamat produksi atau akses internet.

## 4. Multi-tenant
Backend memvalidasi identitas, membership/ownership, tenant, dan permission pada setiap request. Jangan percaya tenant ID dari client tanpa validasi. Personal account dapat menggunakan personal workspace/owner scope; model final TBD.

## 5. Struktur Flutter baseline
```text
lib/
  main.dart
  core/config constants routing theme utils
  data/models repositories services
  features/assistant
  features/cctv/screens
  features/dashboard/screens
  features/devices/screens
  features/energy/screens
  features/locations/screens
  features/productivity/screens
  features/settings/screens
  features/voice/screens
  shared/widgets
```
Struktur aktual repository adalah sumber kebenaran; jangan duplikasi folder.

## 6. Layering
Presentation (screen/widget), state (Riverpod), domain (aturan client seperlunya), repository (abstraksi data), service (API/audio/WebRTC/preferences), model (DTO/domain). Widget tidak melakukan HTTP langsung.

## 7. Keamanan dan reliability
HTTPS produksi; token disimpan aman setelah auth ditetapkan; jangan log secret/audio/URL sensitif; backend validasi tenant; timeout Dio; retry hanya operasi aman; jangan retry kontrol secara buta; tampilkan stale/error; kelola lifecycle audio dan WebRTC.

## 8. Wajib diaudit
Auth, user, tenant membership, lokasi, device list/control/monitoring, Voice API, CCTV signaling, Energy API, Productivity, notifications/history, TLS/network/deployment.

Dokumen ini bukan bukti bahwa semua endpoint tersedia. Agent wajib memeriksa backend aktual.
