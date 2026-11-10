# Device Discovery — Plant, Datalogger, Device Inverter> **Label:** `BERDASARKAN DOKUMENTASI` (sumber: `api-plts-inverter.pdf` bagian `4.3 Equipment`; `verify-device.cjs`; `README.md`).  > **Tujuan:** mengubah alur konfigurasi manual `growatt.devices` menjadi proses pemilihan `device_sn` yang valid.---## 1. Tinjauan objek### `device_sn` — identitas inverterDari `GET /device/list` dan contoh PDF:```json
{"device_id": 100010001,"datalogger_sn": "601000000","device_sn": "YINGZHENTEST001","type": 1,"manufacturer": "igen","model": "","last_update_time": "2015-12-08T11:00:00Z"}```
`device_sn` adalah identitas **inverter**. Di `server.cjs`, pengecekan polling menggunakan `device_sn`:```js
const url = BASE_URL + "/device/inverter/last_new_data?device_sn=" + encodeURIComponent(deviceSn);```
Dan di `verify-device.cjs`:```js
const isInv = Number(d.type) === 1; // 1 = inverter (dari PDF)```
### `datalogger_sn` — identitas datalogger`datalogger_sn` muncul dalam response `device/list`, biasanya sebagai pemetaan antar device dengan datalogger yang terhubung. Endpoint `device/datalogger/list` sendiri menggunakan field `sn`:```json
{"sn": "601000000","type": 1,"manufacturer": "igen","model": "","last_update_time": "2015-12-08T11:00:00Z"}```
---## 2. Alur discovery### Langkah 1 — Mendapatkan daftar plantRequest:```http
GET /plant/list?page=1&perpage=100```
Header:```http
token: <token-growatt>Accept: application/json```
Response yang diharapkan:```json
{"data": {"count": N,"plants": [{"plant_id": 1,"name": "Name of Plant1","user_id": 1}]},"error_code": 0,"error_msg": ""}```
Jika `error_code` bukan `0`, lakukan diagnosis:- Token salah environment.- Akun tidak memiliki plant.- Rate limit / waktu tunggu.---### Langkah 2 — Mendapatkan daftar dataloggerRequest:```http
GET /device/datalogger/list?plant_id=1&page=1&perpage=100```
Response:```json
{"data": {"count": N,"dataloggers": [{"sn": "601000000","type": 1,"manufacturer": "igen","model": "","last_update_time": "2015-12-08T11:00:00Z"}]},"error_code": 0,"error_msg": ""}```
Dokumen ini **tidak menjamin** bahwa datalogger akan selalu terhubung ke inverter yang sedang dipollling. Datalogger dapat digunakan untuk:- Inventarisasi kolektor/datalogger di plant.- Mapping `datalogger_sn` ke plant atau device.- Verifikasi format dan keberadaan SN.---### Langkah 3 — Mendapatkan daftar deviceRequest:```http
GET /device/list?plant_id=1&page=1&perpage=100```
Response:```json
{"data": {"count": N,"devices": [{"device_id": 100010001,"datalogger_sn": "601000000","device_sn": "YINGZHENTEST001","type": 1,"manufacturer": "igen","model": "","last_update_time": "2015-12-08T11:00:00Z"}]},"error_code": 0,"error_msg": ""}```
---### Langkah 4 — Mengidentifikasi `device_sn`Ambil field `device_sn` dari response `device/list`.Di repository ini, alur pengecekan memakai kriteria:```js
const isInv = Number(d.type) === 1; // 1 = inverter (dari PDF)```
Artinya:- Jika `type === 1`, anggap sebagai inverter.- Gunakan `device_sn` sebagai identitas inverter.- Pastikan `device_sn` benar-benar dikenal oleh Growatt di environment yang sama, bukan sekadar tebakan dari konfigurasi.---### Langkah 5 — Menghubungkan `device_sn` dengan `datalogger_sn`Dari `device/list`:```json
{"datalogger_sn": "601000000","device_sn": "YINGZHENTEST001"}```
Hubungan yang dapat ditarik:| Konten | Nilai | Peran ||---|---|---|| `device_id` | `100010001` | ID internal device || `device_sn` | `YINGZHENTEST001` | Identitas inverter, dipakai untuk polling live || `datalogger_sn` | `601000000` | Identitas datalogger yang terhubung |Catatan:- Di `server.cjs`, `dataloggerSn` dari `last_new_data` divalidasi dan dicatat, tetapi **tidak** digunakan sebagai kunci polling inverter.- Di `verify-device.cjs`, datalogger SN yang muncul dibandingkan dengan konfigurasi untuk membantu diagnosa error `10005`.---## 3. Peta keputusan untuk samplingJika backend ELFAN ingin memetakan data ke objek monitoring, gunakan alur berikut:```text
plant/list-> lookup plant_id / name-> device/list?plant_id=<id>-> filter device-> device_sn = yang valid/diketahui Growatt-> last_new_data?device_sn=<device_sn>-> optionally: datalogger_sn = nilai datalogger_sn untuk plantasasi```
**Penting:** Data inverter yang ingin dipantau (output AC, PV, suhu, energi) **harus** diambil menggunakan `device_sn`, bukan `datalogger_sn`.---## 4. Mengapa `device_sn`, bukan `datalogger_sn`Kode repository menunjukkan pola ini:1. `server.cjs` menggunakan `device_sn` untuk `last_new_data`.2. `verify-device.cjs` mengidentifikasi `datalogger_sn` dan menandai SN yang tidak dikenali sebagai **bukan inverter**.3. `Verify-device` menggunakan error `10005` sebagai indikator bahwa `device_sn` tidak dikenal server, dan menyarankan jika konfigurasi hanya memakai datalogger SN sebagai device SN, nilai tersebut bukan inverter.Kesimpulan teknis:- `device_sn` → **inverter**.- `datalogger_sn` → **datalogger / collector**.- Endpoint `device/datalogger/list` mengembalikan `sn`, bukan `datalogger_sn`.- Pemetaan `datalogger_sn` ke `device_sn` hanya bisa dipercaya dari `device/list` (dan perlu diverifikasi di lingkungan yang sedang digunakan).