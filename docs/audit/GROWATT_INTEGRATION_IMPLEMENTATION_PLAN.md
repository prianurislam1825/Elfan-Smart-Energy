# Growatt Integration — Implementation Plan (Backend ELFAN)

**Status:** rencana teknis. **Tidak ada implementasi** yang dilakukan pada tahap ini.
**Tanggal:** 10 November 2026.
**Sumber acuan:**

- `docs/device-reference/integrations/growatt/01-api-reference.md` … `09-security-and-limitations.md` (10 file, terbaca seluruhnya).
- Source Flutter aktual pada repository ini (`lib/**`) untuk sisi konsumen API.
- `docs/02_SYSTEM_ARCHITECTURE.md`, `docs/06_API_DOCUMENTATION.md`, `docs/07_DATABASE_AND_DATA_MODELS.md`.

---

## 0. Batasan verifikasi (harus dibaca lebih dulu)

Dokumen ini **tidak** dapat disusun dari pembacaan source backend, karena:

1. File audit yang dirujuk (`docs/audit/ELFAN_BACKEND_DIRECT_AUDIT.md`) **tidak ditemukan** di repository ini maupun di workspace lain yang dapat dibaca.
2. Source backend (`~/cv-engine` di Raspberry Pi, LAN `192.168.20.137:8000`) **tidak dapat diakses** dari lingkungan kerja ini: tidak ada direktori `~/.ssh`, tidak ada `SSH_AUTH_CONFIG`/host target, dan tidak ada salinan source backend di filesystem yang terjangkau.
3. `GET /openapi.json` / `/docs` backend tidak dipanggil pada tahap ini (tidak ada bukti kontrak OpenAPI).

Akibatnya, label yang dipakai di seluruh dokumen:

| Label | Arti |
|---|---|
| **TERSEDIA DAN TERVERIFIKASI** | Terbukti dari file yang benar-benar dibaca (source Flutter, test, atau dokumentasi Growatt). |
| **TERSEDIA TETAPI BELUM DIVERIFIKASI** | Disebut dokumentasi proyek atau diimplikasikan kode klien, tetapi bentuk/isi sebenarnya belum diperiksa dari backend. |
| **BELUM TERSEDIA** | Tidak ada bukti apa pun bahwa komponen tersebut ada. |
| **MEMERLUKAN KEPUTUSAN ARSITEKTUR** | Perlu keputusan pemilik sistem sebelum implementasi. |

**Konsekuensi:** semua rancangan di bawah adalah **rancangan yang menunggu verifikasi backend**. Tidak ada nama tabel, nama modul, atau field backend yang diklaim sudah ada kecuali yang tercantum pada §1.2.

---

## 1. Kondisi backend aktual

### 1.1 Fakta lingkungan (TERSEDIA DAN TERVERIFIKASI — dari dokumentasi proyek)

| Aspek | Nilai | Bukti |
|---|---|---|
| Framework | FastAPI | `docs/06_API_DOCUMENTATION.md`, `docs/02_SYSTEM_ARCHITECTURE.md` |
| Host | Raspberry Pi, hostname `alwustho123` | `docs/02 §3` |
| Base URL development | `http://192.168.20.137:8000` (LAN saja) | `docs/06`, `docs/02 §3` |
| Source path | `~/cv-engine` | `docs/02 §3` |
| Swagger | `http://192.168.20.137:8000/docs` | `docs/06` |
| Aplikasi | `application: "elfan-cv-engine"`, `environment: development` pada `/health` | `test/data/backend_contract_parse_test.dart` |
| Peran backend | pusat API, auth, otorisasi, orkestrasi perangkat (`DeviceController`), integrasi | `docs/02 §1–2` |
| Database engine | **tidak disebutkan** | `docs/07` menandai "Database engine" sebagai *open decision* |

### 1.2 Kontrak API yang benar-benar dipakai Flutter (TERSEDIA DAN TERVERIFIKASI)

Diambil dari `lib/core/constants/api_endpoints.dart`, `lib/data/repositories/*.dart`, dan `test/data/backend_contract_parse_test.dart`.

| Method | Path | Bentuk respons yang dibaca klien |
|---|---|---|
| GET | `/health` | `{status, application, environment}` |
| GET | `/api/v1/devices` | `{total, devices[]}` |
| GET | `/api/v1/devices/{logical_id}` | objek `Device` |
| GET | `/api/v1/devices/{logical_id}/status` | objek `Device` (belum dipakai UI) |
| GET | `/api/v1/devices/{logical_id}/state` | `{logical_id, name, location, connection_status, last_seen_at, last_updated_at, source, error, channels[]}` |
| POST | `/api/v1/devices/{logical_id}/commands` | dikirim `{switch_dp: ...}`; bentuk respons tidak diparse |
| GET | `/api/v1/monitoring/status` | `{success, data:{running, interval_seconds, last_run_at, last_result}}` |
| POST | `/api/v1/monitoring/check` | sama seperti di atas |
| GET | `/api/v1/tuya/connection` | dideklarasikan di konstanta, **tidak dipakai** repository mana pun |

`last_result` berisi `{checked_at, total_devices, monitored_devices, online, offline, unknown, unsupported_devices, results[]}`; tiap `results[]` berisi `{logical_id, name, type, connection_status, success, channels[]}`; tiap kanal `{id, name, switch_dp, state, status}`.

Objek `Device` minimal berisi `id`/`logical_id`, `name`, lalu opsional `location`, `type`, `device_id`, `category`, `enabled`, `channels[]`, `monitoring_dps[]`, `parent_device_id`, `status_mode`, `verification_required`, dan field lain yang disimpan di `extraFields`.

### 1.3 Yang belum dapat dipastikan dari backend

| Komponen | Status |
|---|---|
| Struktur direktori `~/cv-engine` (routers, models, services, migrations) | **BELUM DIVERIFIKASI** — source tidak terbaca |
| Engine database, skema, dan versi migrasi (Alembic?) | **BELUM DIVERIFIKASI** — hanya disebut sebagai open decision |
| Implementasi scheduler monitoring (`running`, `interval_seconds`) — APScheduler? asyncio task? | **BELUM DIVERIFIKASI** |
| Mekanisme autentikasi/otorisasi request | **BELUM DIVERIFIKASI** — klien belum mengirim header auth apa pun |
| Adapter `DeviceController` / Tuya | **BELUM DIVERIFIKASI** |
| Endpoint energi/histori | **BELUM TERSEDIA** (tidak ada di konstanta klien, tidak ada di daftar endpoint dokumentasi) |
| Integrasi Growatt apa pun | **BELUM TERSEDIA** — tidak ada bukti di klien maupun dokumentasi |

### 1.4 Kondisi sisi Flutter yang relevan (TERSEDIA DAN TERVERIFIKASI)

- `ApiClient` terpusat berbasis Dio: base URL dari `--dart-define=ELFAN_API_BASE_URL`, timeout `connect 10s / receive 20s / send 30s`, `Accept: application/json`.
- `ApiException` memetakan `DioException` → `configuration, timeout, connection, cancelled, badRequest, unauthorized, forbidden, notFound, conflict, validation, server, unexpected`; ada `isTransient` untuk retry (kecuali operasi kontrol).
- `ApiLoggingInterceptor` **hanya** mencatat method, path, status, durasi — tidak mencatat header/body/query.
- `ApiError.tryParse` menerima `code`/`error` dan `message`/`detail` (string). **Bentuk error backend belum terverifikasi.**
- Parsing model bersifat defensif; nilai yang tidak dikirim menjadi `null`, tidak ditebak menjadi `0`/`OFF`.
- `EnergyScreen` masih `FeaturePlaceholder` — belum ada UI energi, belum ada pemanggilan API energi.

---

## 2. Komponen yang dapat digunakan kembali

### 2.1 Sisi Flutter (TERSEDIA DAN TERVERIFIKASI, langsung dipakai)

| Komponen | Berkas | Pemanfaatan |
|---|---|---|
| `ApiClient` (Dio, timeout, error mapping, logging aman) | `lib/data/services/api_client.dart` | Semua endpoint energi baru lewat sini; tidak membuat Dio baru |
| `ApiException` + `ApiError` | `lib/data/services/api_exception.dart`, `lib/data/models/api_error.dart` | Menampilkan status `stale`/`gagal` tanpa mengarang angka |
| `ApiEndpoints` | `lib/core/constants/api_endpoints.dart` | Tempat menambah path energi |
| Pola model `tryParse` defensif | `lib/data/models/device_state_model.dart`, `monitoring_model.dart` | Model inverter/plant mengikuti gaya yang sama (null ≠ 0) |
| Pola Riverpod `Notifier` + keluarga per-ID | `lib/data/providers/device_providers.dart` | `inverterStateProvider(deviceSn)`, `energyHistoryProvider(...)` |
| `ConnectionStatus` (`online/offline/unknown`) dan `displayName` | `lib/data/models/monitoring_model.dart` | Reuse enum untuk status inverter |
| Konfigurasi base URL via `--dart-define` | `lib/core/config/app_config.dart` | Tidak ada URL backend di kode |

### 2.2 Sisi backend (TERSEDIA TETAPI BELUM DIVERIFIKASI — kandidat reuse)

| Komponen | Dugaan reuse | Yang harus diverifikasi lebih dulu |
|---|---|---|
| Aplikasi FastAPI + pola router `/api/v1/...` | Menambah router `energy` di bawah prefiks yang sama | Struktur router & registrasi `include_router` |
| `/health` | Tidak diubah; dipakai sebagai bukti backend hidup | — |
| Scheduler monitoring (`running`, `interval_seconds`) | Menjadi pola/acuan untuk poller inverter, atau menjadi tempat menempelkan job baru | Mekanisme (asyncio loop vs APScheduler), perilaku saat restart |
| Registri perangkat + `logical_id` | Menautkan inverter Growatt ke perangkat yang sudah terdaftar (relasi `device_sn` ↔ `logical_id`) | Apakah tabel perangkat ada di DB atau dari konfigurasi/Tuya |
| `DeviceController` | **Tidak** dipakai untuk Growatt (Growatt hanya baca) | — |

**Tidak boleh diasumsikan:** bahwa tabel `device` dapat menyimpan inverter Growatt (butuh kolom `device_sn`/`plant_id`). Ini bagian dari §3 dan §5.

---

## 3. Gap antara kondisi backend dan kebutuhan Growatt

| # | Kebutuhan | Kondisi saat ini | Gap |
|---|---|---|---|
| G1 | Klien HTTP Growatt (header `token`, validasi `error_code`, timeout, retry) | Tidak ada | Buat service baru |
| G2 | Penyimpanan credential Growatt | Tidak ada | Env var + tidak pernah ke klien |
| G3 | Katalog plant / datalogger / inverter | Tidak ada | Tabel + endpoint discovery |
| G4 | Polling data inverter (30s+) | Tidak ada; yang ada hanya monitoring perangkat Tuya (belum diverifikasi) | Poller + scheduler |
| G5 | Normalisasi field Growatt (W, kWh, °C, V, A) | Tidak ada | Mapper + validasi satuan |
| G6 | Penyimpanan histori energi persisten | Tidak ada; histori di `monitoring-inverter` hanya in-memory/simulasi | Tabel time-series + agregat |
| G7 | Semantik `online/offline/stale` untuk inverter | Ada `connection_status` per perangkat Tuya, bukan inverter | Aturan staleness berbasis `poll_at` |
| G8 | Endpoint energi untuk Flutter | `/api/v1/energy/*` tidak ada | Rancang §7 |
| G9 | Retensi & agregasi histori | Tidak ada | Kebijakan retensi §8 |
| G10 | Observabilitas poller (sukses terakhir, error, kode) | `last_result` hanya untuk monitoring perangkat | Status poll inverter |
| G11 | Isolasi kegagalan per inverter | Pola `Promise.allSettled` di repo referensi | Terapkan `gather(return_exceptions=True)` |
| G12 | Rate-limit handling (`10012`) | Tidak ada | Backoff terjadwal |

---

## 4. Rancangan arsitektur integrasi

Prinsip: **in-process di dalam FastAPI yang sudah ada** (Raspberry Pi, satu proses), bukan service terpisah. Menambah service baru berarti menambah deployment, port, dan monitoring yang belum ada buktinya dibutuhkan.

```text
Flutter (ELFAN Mobile)
  │  GET /api/v1/energy/...            (tanpa token Growatt)
  ▼
FastAPI — router energy (read-only)
  │  baca dari DB (tidak pernah memanggil Growatt saat request)
  ▼
Repository layer (SQL)
  ▲
  │ upsert reading + agregat
Growatt Poller (background task, 1 instance)
  │  POST /device/inverter/invs_data  (batch)  atau  GET .../last_new_data
  │  GET  /plant/list, /device/list, /device/datalogger/list (discovery, jarang)
  ▼
Growatt API  ← token dari environment (hanya di server)
```

Tanggung jawab tiap lapisan:

1. **GrowattClient** — satu-satunya tempat yang tahu base URL, header `token`, timeout, dan arti `error_code`. Mengembalikan objek domain atau melempar error bertipe (`GrowattAuthError`, `GrowattNotFoundError`, `GrowattRateLimitError`, `GrowattTransportError`, `GrowattPayloadError`).
2. **DiscoveryService** — memetakan `plant_id` → `datalogger_sn` → `device_sn` (hanya `type == 1` yang dianggap inverter, sesuai `03-device-discovery.md`). Dijalankan manual/terjadwal jarang (mis. harian), bukan tiap poll.
3. **Poller** — satu loop, interval ≥ 30 s (dokumen Growatt mensyaratkan minimum ini), batch per 5–10 inverter, timeout 10–15 s, backoff pada `10012`.
4. **Normalizer** — peta field Growatt → kolom DB, konversi satuan, timestamp UTC, penandaan `source`.
5. **Repository** — upsert idempoten berbasis `(device_sn, sampled_at)`.
6. **Router energy** — read-only, selalu menyertakan `stale`/`last_poll_at` agar klien tidak menyajikan data basi sebagai real-time.

**Aturan keras:** Flutter tidak pernah memegang token Growatt; backend tidak pernah memanggil Growatt dari dalam request HTTP pengguna (kecuali endpoint admin "refresh" yang eksplisit dan terbatas).

---

## 5. Rancangan database / model

**Catatan:** ini **rancangan**, bukan deskripsi skema yang sudah ada. Nama tabel/kolom harus disesuaikan dengan konvensi backend yang belum terbaca. Tipe ditulis netral (SQLAlchemy); keputusan engine di §11.

### 5.1 `growatt_plant`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | PK | |
| `plant_id` | string, unik | dari `plant/list` |
| `name` | string | |
| `user_id` | string, nullable | dari Growatt, bukan user ELFAN |
| `timezone` | string, nullable | **BELUM DIVERIFIKASI** tersedia di API |
| `created_at`, `updated_at` | timestamptz UTC | |

### 5.2 `growatt_device`

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | PK | |
| `device_sn` | string, unik | identitas inverter; **kunci polling** |
| `datalogger_sn` | string, nullable, index | relasi kolektor |
| `plant_id` | FK → `growatt_plant.plant_id` | |
| `kind` | enum `inverter`/`datalogger`/`other` | dari `type == 1` |
| `manufacturer`, `model` | string, nullable | |
| `display_name` | string, nullable | nama tampilan (bukan dari Growatt) |
| `logical_id` | string, nullable, unik | tautan opsional ke perangkat ELFAN yang ada |
| `is_active` | bool | inverter nonaktif tidak dipolling |
| `last_seen_at` | timestamptz UTC, nullable | waktu data Growatt terakhir yang valid |
| `created_at`, `updated_at` | timestamptz UTC | |

### 5.3 `inverter_reading` (time-series)

| Kolom | Tipe | Keterangan |
|---|---|---|
| `id` | PK | |
| `device_sn` | FK, index | |
| `sampled_at` | timestamptz UTC | dari field `time` Growatt, dikonversi ke UTC |
| `polled_at` | timestamptz UTC | waktu backend mengambil |
| `status_code` | smallint | `status` |
| `status_text` | string | `statusText` |
| `pac_w` | numeric(12,2), nullable | `pac` (W) |
| `ppv_w` | numeric(12,2), nullable | `ppv` |
| `vpv1_v`, `vpv2_v` | numeric(10,2), nullable | |
| `ipv1_a`, `ipv2_a` | numeric(10,2), nullable | |
| `vacr_v` | numeric(10,2), nullable | |
| `fac_hz` | numeric(6,2), nullable | |
| `pf` | numeric(6,3), nullable | satuan **BELUM DIVERIFIKASI** (rasio vs %) |
| `temperature_c` | numeric(6,2), nullable | |
| `power_today_kwh` | numeric(12,3), nullable | `powerToday` |
| `power_total_kwh` | numeric(14,3), nullable | `powerTotal` |
| `fault_code`, `warn_code` | integer, nullable | |
| `source` | string | mis. `growatt/invs_data` |
| `raw` | JSON, nullable | respons mentah (tanpa token) |

Constraint: `UNIQUE (device_sn, sampled_at)`; index `(device_sn, sampled_at DESC)` dan `(sampled_at)`.

### 5.4 `inverter_energy_hourly` / `inverter_energy_daily`

| Kolom | Tipe |
|---|---|
| `device_sn` | FK |
| `bucket_start` | timestamptz UTC (awal jam/hari lokal) |
| `energy_kwh` | numeric(12,3) |
| `peak_pac_w` | numeric(12,2) |
| `avg_pac_w` | numeric(12,2) |
| `sample_count` | integer |
| PK | `(device_sn, bucket_start)` |

### 5.5 `growatt_poll_run` (observabilitas)

`id`, `started_at`, `finished_at`, `trigger` (`scheduled`/`manual`), `requested_count`, `success_count`, `failed_count`, `error_code`, `error_message` (tanpa token), `http_status`.

### 5.6 Aturan data

- Semua timestamp disimpan **UTC**; konversi ke zona lokal dilakukan di klien.
- `NULL` berarti "tidak tersedia". **Jangan** menormalkan `NULL` menjadi `0` — ini konsisten dengan aturan parsing Flutter saat ini dan `05-data-mapping.md`.
- Baris dengan `status` tidak valid tetap disimpan (berguna untuk mendeteksi inverter mati), tetapi tidak diagregasi ke energi.
- `sample_count` pada agregat memberi tahu kualitas bucket; bucket tanpa data **tidak dibuat** (bukan nol).

---

## 6. Rancangan service dan background polling

### 6.1 Job

| Job | Frekuensi | Isi |
|---|---|---|
| `poll_inverters` | setiap 60 s (minimum 30 s) | batch `invs_data` untuk semua `device_sn` aktif |
| `refresh_catalog` | harian / manual | `plant/list`, `device/list`, `device/datalogger/list` |
| `aggregate_energy` | setiap 5 menit + saat start | isi bucket jam/hari yang sudah lengkap |
| `prune_readings` | harian | hapus raw > retensi |

Pilihan 60 s (bukan 30 s) adalah margin aman dari batas minimum Growatt dan mengurangi risiko `10012`.

### 6.2 Perilaku poll

1. Ambil daftar `device_sn` aktif dari DB.
2. Bagi ke chunk ≤ 10; satu request `POST /device/inverter/invs_data` per chunk (`pageNum: 1`).
3. Timeout 12 s per request; **jangan** paralel tanpa batas.
4. Respons: `error_code == 0` → normalisasi; `10005` → tandai `device_sn` perlu discovery ulang (jangan hapus); `10012` → hentikan siklus, jadwalkan ulang +60 s; HTTP 401/403 → tandai status integrasi `auth_failed` dan berhenti sampai token diperbaiki (jangan spam).
5. Upsert hanya jika `sampled_at` lebih baru dari baris terakhir untuk `device_sn` itu (idempoten, tahan restart).
6. Simpan satu `growatt_poll_run` per siklus.

### 6.3 Ketahanan restart

- Tidak ada state di memori yang penting: semua hasil masuk DB.
- Saat start, poller langsung menjalankan satu siklus (bukan menunggu interval), lalu masuk jadwal tetap.
- Gunakan single-worker; jika uvicorn dijalankan dengan >1 worker, poller harus dijaga agar hanya berjalan di satu proses (**MEMERLUKAN KEPUTUSAN ARSITEKTUR** — lihat §11).

### 6.4 Endpoint admin (opsional, dibatasi)

`POST /api/v1/energy/admin/refresh` — memicu `refresh_catalog` dan satu siklus poll. Tidak boleh terbuka publik; statusnya bergantung pada mekanisme auth yang **BELUM DIVERIFIKASI**.

---

## 7. Rancangan endpoint API untuk Flutter

Konvensi mengikuti yang sudah ada: prefiks `/api/v1`, `snake_case`, daftar memakai `{total, items[]}` (meniru `{total, devices[]}`), objek tunggal langsung (meniru `/state`). **Semua di bawah ini rancangan baru.**

### 7.1 `GET /api/v1/energy/plants`

```json
{
  "total": 1,
  "plants": [
    {
      "plant_id": "contoh-plant",
      "name": "PLTS Gedung Contoh",
      "inverter_count": 3,
      "total_power_w": 5420.5,
      "energy_today_kwh": 12.4,
      "last_poll_at": "2026-11-10T03:12:00Z",
      "stale": false
    }
  ]
}
```

### 7.2 `GET /api/v1/energy/inverters?plant_id={id}`

```json
{
  "total": 1,
  "inverters": [
    {
      "device_sn": "CONTOH0001",
      "datalogger_sn": "CONTOH-DL-1",
      "plant_id": "contoh-plant",
      "display_name": "Inverter Aula",
      "connection_status": "online",
      "status_code": 1,
      "status_text": "Normal",
      "pac_w": 2835.1,
      "energy_today_kwh": 8.83,
      "energy_total_kwh": 462.87,
      "last_sample_at": "2026-11-10T03:11:40Z"
    }
  ]
}
```

### 7.3 `GET /api/v1/energy/inverters/{device_sn}`

Detail statis + snapshot terakhir: seluruh field pada §7.2 ditambah `ppv_w`, `vpv1_v`, `vpv2_v`, `ipv1_a`, `ipv2_a`, `vacr_v`, `fac_hz`, `temperature_c`, `fault_code`, `warn_code`, `source`, `stale`, `age_seconds`.

### 7.4 `GET /api/v1/energy/inverters/{device_sn}/state`

Snapshot real-time ringan untuk polling UI (payload kecil):

```json
{
  "device_sn": "CONTOH0001",
  "connection_status": "online",
  "status_text": "Normal",
  "pac_w": 2835.1,
  "energy_today_kwh": 8.83,
  "energy_total_kwh": 462.87,
  "voltage_v": 229.6,
  "current_a": 12.35,
  "temperature_c": 52.6,
  "sampled_at": "2026-11-10T03:11:40Z",
  "polled_at": "2026-11-10T03:12:00Z",
  "age_seconds": 20,
  "stale": false,
  "source": "growatt/invs_data"
}
```

`connection_status` dihitung dari `age_seconds` (mis. `online` < 4× interval, `offline` di atasnya, `unknown` bila belum ada sampel) — meniru aturan `online = lastPollAtMs < EFFECTIVE_POLL_MS * 4` pada `04-inverter-monitoring.md §8`.

**Catatan `current_a`:** Growatt menyediakan arus PV (`ipv1`/`ipv2`) dan arus AC (`iacr`, status `BERDASARKAN DOKUMENTASI` tetapi tidak dipakai repo referensi). Rancangan ini memakai arus PV per-string sebagai field eksplisit (`ipv1_a`, `ipv2_a`) dan menyediakan `current_a` agregat hanya jika satuannya terverifikasi. **Jangan** mengarang `current_a` dari `pac/vacr` sebelum diputuskan (lihat §11).

### 7.5 `GET /api/v1/energy/inverters/{device_sn}/history`

Parameter: `from` (ISO-8601 UTC), `to`, `interval` ∈ `raw|hour|day` (default `hour`), `limit` (default 168, max 1000).

```json
{
  "device_sn": "CONTOH0001",
  "interval": "hour",
  "timezone": "UTC",
  "points": [
    {"bucket_start": "2026-11-10T02:00:00Z", "energy_kwh": 0.84, "peak_pac_w": 3100.0, "sample_count": 60}
  ],
  "truncated": false
}
```

`interval=day` dipakai untuk grafik produksi energi harian; `interval=raw` dibatasi ketat (mis. maksimum 24 jam) agar tidak membebani Pi.

### 7.6 `GET /api/v1/energy/summary?plant_id={id}`

Agregat untuk kartu dashboard: `total_power_w`, `energy_today_kwh`, `energy_total_kwh`, `inverters_online/offline/unknown`, `last_poll_at`, `stale`.

### 7.7 Aturan konsistensi dengan Flutter

- Field waktu selalu ISO-8601 dengan akhiran `Z` — model Flutter memanggil `.toLocal()` pada string berakhiran `Z` (terlihat di `device_state_model.dart`, `monitoring_model.dart`).
- Nilai tidak tersedia → `null` (bukan `0`), dan UI wajib menampilkan "tidak tersedia".
- Error memakai bentuk yang sudah dibaca `ApiError`: `{"code": "...", "message": "..."}` atau `{"detail": "..."}`. Bentuk mana yang dipakai backend **BELUM DIVERIFIKASI**; klien sudah menerima keduanya.
- Path baru ditambahkan ke `ApiEndpoints` + `DeviceRepository` (atau `EnergyRepository` baru) — tidak ada Dio ad-hoc di widget.

---

## 8. Strategi penyimpanan histori energi

1. **Sumber kebenaran histori = DB backend**, bukan memori proses dan bukan Growatt. Alasan: `monitoring-inverter` hanya menyimpan 720/180/30 titik di memori dan histori-nya simulasi (`06-polling-and-streaming.md §7–9`).
2. **Raw** (`inverter_reading`): retensi 30 hari. Cukup untuk audit dan rekalkulasi agregat.
3. **Hourly**: 13 bulan. **Daily**: permanen (tabel kecil).
4. **Idempoten**: `UNIQUE (device_sn, sampled_at)` + upsert. Restart, retry, atau poll ganda tidak menghasilkan duplikat.
5. **Bukan turunan dari `powerToday` saja.** `powerToday`/`powerTotal` disimpan sebagai kolom (sumber Growatt), sedangkan `energy_kwh` bucket dihitung dari integrasi `pac_w` antar sampel; selisih keduanya dapat dipakai mendeteksi data bolong. Ini menjawab risiko "energi hilang saat restart" tanpa mengklaim akurasi yang belum teruji.
6. **Deteksi gap:** jika selisih `sampled_at` > 3× interval, bucket ditandai `sample_count` rendah; endpoint menyertakan `truncated`/`sample_count` agar UI bisa menandai data tidak lengkap.
7. **Zona waktu:** bucket harian dihitung pada zona lokal site (default `Asia/Jakarta`, **MEMERLUKAN KEPUTUSAN**), disimpan sebagai `bucket_start` UTC + metadata `timezone`.
8. **Backfill** dari endpoint historis Growatt (`/device/inverter/data`, dll.) **tidak** dilakukan pada tahap awal: endpoint tersebut ada di PDF tetapi belum diverifikasi (`09-security-and-limitations.md §6`).

---

## 9. Strategi autentikasi dan keamanan credential

1. **Penyimpanan:** `GROWATT_TOKEN` dan `GROWATT_BASE_URL` sebagai environment variable pada unit service backend; file `.env` bila ada wajib `chmod 600` dan masuk `.gitignore`. Tidak ada token di repo, image, Flutter, dokumen, atau log.
2. **Prioritas konfigurasi:** env > file lokal > default (pola `02-authentication.md §4`), dengan **wajib** gagal-start (fail fast) bila `GROWATT_TOKEN` kosong dan integrasi diaktifkan.
3. **Environment terpisah:** token test (`test.growatt.com`) dan produksi tidak boleh tercampur; base URL produksi masih **BELUM DIVERIFIKASI** (kandidat yang disebut dokumentasi: `open.growatt.com/v1` dan `api.growatt.com/v1`).
4. **Tidak pernah ke klien:** tidak ada endpoint yang mengembalikan token, base URL berkredensial, atau respons mentah Growatt. `raw` di DB tidak berisi header.
5. **Logging:** hanya `device_sn`, `http_status`, `error_code`, `error_msg` yang sudah disanitasi; exception tidak boleh menyertakan header request.
6. **Error ke klien:** `401/403` dari Growatt dipetakan menjadi status integrasi `auth_failed` (bukan diteruskan sebagai 401 ke pengguna Flutter, agar tidak memicu logout aplikasi).
7. **Rotasi:** token diganti lewat env + restart; tidak ada UI pengelolaan token pada tahap ini.
8. **Transport:** HTTPS ke Growatt produksi; jangan memakai `http://test.growatt.com` di luar pengujian.
9. **Kontrol akses endpoint energi:** mengikuti mekanisme auth backend yang ada. Karena mekanisme itu **BELUM DIVERIFIKASI** dan saat ini klien tidak mengirim kredensial, endpoint energi **tidak boleh** diekspos ke internet sebelum auth terpasang.

---

## 10. Urutan implementasi berdasarkan dependensi

| Tahap | Isi | Prasyarat | Kriteria selesai |
|---|---|---|---|
| **T0** | Verifikasi read-only: panggil `plant/list` + `device/list` dengan token nyata, catat `device_sn` inverter, satuan, dan bentuk error | Akses jaringan ke Growatt + token + izin | Daftar inverter nyata terdokumentasi; satuan `pac/powerTotal/pf` terkonfirmasi |
| **T1** | Skema DB + migrasi (`growatt_plant`, `growatt_device`, `inverter_reading`) | Keputusan engine DB (§11) | Migrasi naik/turun bersih di lingkungan dev |
| **T2** | `GrowattClient` + normalizer + test unit dengan respons rekaman (tanpa token) | T0 | Parsing & klasifikasi error teruji |
| **T3** | Poller + `growatt_poll_run`, simpan reading | T1, T2 | Restart backend tidak menghilangkan data; tidak ada duplikat |
| **T4** | Endpoint read-only §7.1–7.4, 7.6 | T3 | Kontrak cocok dengan model Flutter |
| **T5** | Agregasi + endpoint history §7.5 + retensi | T4 | Grafik harian konsisten dengan `powerToday` dalam toleransi |
| **T6** | UI Flutter: `EnergyRepository`, provider, `EnergyScreen` (plant → inverter → grafik) | T4, T5 | Angka `null` tampil "tidak tersedia", status stale terlihat |

Catatan dependensi: T6 tidak boleh dimulai sebelum T4 stabil, karena UI akan mengunci bentuk kontrak.

---

## 11. Risiko teknis dan hal yang membutuhkan keputusan

### 11.1 Risiko

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Rate limit `10012` | Polling berhenti, data bolong | Interval ≥ 60 s, chunk ≤ 10, backoff 30/60 s, satu job saja |
| Salah environment (test vs prod) | `10005`/data kosong, diagnosis menyesatkan | Token & base URL dipasangkan, validasi saat start, log environment |
| Satuan tidak pasti (`pac`, `pf`, `powerTotal`) | Angka salah 1000× | Konfirmasi T0; simpan nama field asli + satuan di kode, bukan asumsi |
| Zona waktu Growatt | Bucket harian bergeser | Simpan UTC + `timezone` eksplisit; konversi di klien |
| Data basi tampil sebagai real-time | Keputusan operasional salah | `stale`, `age_seconds`, `last_poll_at` wajib ada di setiap respons |
| `NULL` dinormalkan jadi `0` | "Inverter mati" palsu | Larangan eksplisit; test untuk kasus null |
| Token bocor lewat log/error/repo | Akses pihak lain ke akun Growatt | Sanitasi log, review diff, `.gitignore`, secret di env |
| Beban Raspberry Pi (penulisan time-series) | I/O lambat, SD card aus | Retensi 30 hari, batch insert, pertimbangkan SQLite WAL |
| Polller ganda (multi-worker uvicorn) | Dua poll bersamaan → `10012` | Single worker atau advisory lock |
| Duplikasi domain dengan data Tuya | Dua sumber "energi" berbeda angka | Pisahkan namespace `energy` dan beri label `source` |

### 11.2 MEMERLUKAN KEPUTUSAN ARSITEKTUR

1. **Engine database** — SQLite (sederhana, cocok Pi, tanpa service tambahan) vs PostgreSQL (time-series lebih baik, butuh service). Belum ada bukti engine saat ini.
2. **Mekanisme scheduler** — memakai scheduler monitoring yang sudah ada, APScheduler baru, atau `asyncio` task. Bergantung pada implementasi yang belum terbaca.
3. **Model inverter: entitas baru atau perangkat ELFAN?** Pilihan: (a) tabel `growatt_device` terpisah + `logical_id` opsional (rancangan §5), atau (b) menambahkan kolom Growatt ke tabel perangkat yang ada. (a) lebih aman karena tidak menyentuh alur kontrol/Tuya.
4. **Cakupan endpoint `/api/v1/energy/*` vs menyatukan ke `/api/v1/devices`** — memisahkan domain energi lebih jelas; menyatukan lebih sedikit layar baru.
5. **Auth endpoint energi** — perlu keputusan karena saat ini klien tidak mengirim kredensial apa pun.
6. **Zona waktu bucket harian** — `Asia/Jakarta` atau zona site.
7. **Apakah `current_a` agregat ditampilkan** — hanya jika `iacr` terverifikasi; jika tidak, tampilkan arus PV per string.
8. **Backfill histori Growatt** — perlu verifikasi endpoint historis dan izin akun.

---

## 12. Daftar file aktual yang akan dibuat atau diubah pada tahap implementasi

### 12.1 Backend (`~/cv-engine`)

**Peringatan:** struktur direktori backend **BELUM DIVERIFIKASI**. Nama di bawah mengikuti konvensi FastAPI umum dan harus dipetakan ulang ke layout nyata sebelum implementasi.

| Aksi | Path (usulan) | Isi |
|---|---|---|
| Buat | `app/integrations/growatt/client.py` | HTTP client, header `token`, timeout, klasifikasi error |
| Buat | `app/integrations/growatt/discovery.py` | `plant/list`, `device/list`, `datalogger/list` |
| Buat | `app/integrations/growatt/mapper.py` | Normalisasi field + satuan |
| Buat | `app/integrations/growatt/poller.py` | Loop, chunking, upsert, `poll_run` |
| Buat | `app/integrations/growatt/aggregator.py` | Bucket jam/hari + retensi |
| Buat | `app/models/growatt.py` (atau `energy.py`) | Model §5 |
| Buat | `app/schemas/energy.py` | Pydantic response §7 |
| Buat | `app/api/v1/energy.py` | Router read-only |
| Ubah | `app/main.py` (nama aktual belum diverifikasi) | `include_router`, start/stop poller |
| Ubah | `app/core/config.py` (nama aktual belum diverifikasi) | `GROWATT_TOKEN`, `GROWATT_BASE_URL`, interval, retensi |
| Buat | `alembic/versions/<rev>_growatt_energy.py` | Migrasi §5 (jika Alembic dipakai) |
| Ubah | `.env.example` | Placeholder `GROWATT_TOKEN=<...>`, tanpa nilai nyata |

### 12.2 Flutter (repository ini, path terverifikasi)

| Aksi | Path |
|---|---|
| Ubah | `lib/core/constants/api_endpoints.dart` — tambah `energyPlants`, `energyInverters`, `energyInverterState`, `energyInverterHistory`, `energySummary` |
| Buat | `lib/data/models/energy_models.dart` — `GrowattPlant`, `GrowattInverter`, `InverterState`, `EnergyHistoryPoint`, parser `tryParse` defensif |
| Buat | `lib/data/repositories/energy_repository.dart` — memakai `ApiClient` |
| Buat | `lib/data/providers/energy_providers.dart` — `Notifier` + keluarga per `device_sn` |
| Ubah | `lib/features/energy/screens/energy_screen.dart` — ganti placeholder dengan daftar plant/inverter + grafik |
| Ubah | `test/data/backend_contract_parse_test.dart` — tambah kasus parsing (null ≠ 0) |
| Ubah | `docs/06_API_DOCUMENTATION.md` — daftarkan endpoint energi setelah terverifikasi |

**Tidak diubah** pada tahap ini: `ApiClient`, `ApiException`, `app_config.dart`, alur kontrol perangkat, konfigurasi Growatt mana pun, dan apa pun pada `monitoring-inverter`.

---

## 13. Rekomendasi tahap implementasi pertama

**Lakukan T0 — verifikasi read-only Growatt dan inventaris inverter nyata — sebelum menulis kode apa pun.**

Alasannya konkret:

- Seluruh rancangan §5–§7 bergantung pada tiga hal yang belum terbukti: `device_sn` inverter yang benar-benar terdaftar, satuan `pac`/`powerTotal`/`pf`, dan base URL produksi. Tanpa itu, skema DB dan grafik berisiko salah sejak fondasi.
- T0 tidak memerlukan perubahan kode produksi: cukup skrip sekali-jalan (di luar repository produksi atau sebagai modul CLI terpisah) yang memanggil `GET /plant/list` dan `GET /device/list`, lalu mencatat `plant_id`, `device_sn`, `type`, dan `datalogger_sn` — **tanpa** memanggil endpoint yang mengubah state, tanpa mencetak token, dan tanpa menulis ke DB.
- Hasil T0 langsung mengubah satu-satunya bagian rencana yang paling rapuh (satuan dan identitas perangkat) menjadi terverifikasi, sehingga T1 (migrasi) bisa dikunci dengan aman.

Jika T0 menyimpulkan token/izin belum siap, **hentikan** dan jangan lanjut ke T1: menarik integrasi Growatt tanpa akses baca yang valid hanya akan menghasilkan tabel kosong dan endpoint yang tidak pernah berisi data.
