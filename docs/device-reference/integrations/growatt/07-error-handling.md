# Error Handling> **Label:** `BERDASARKAN IMPLEMENTASI` untuk kode `server.cjs`, `api/snapshot.js`, `verify-device.cjs`, `demo-test.cjs`.  > **Label:** `BERDASARKAN DOKUMENTASI` hanya untuk `error_code`, `error_msg`, dan pola validasi `error_code === 0`.> **Catatan:** Kode error detail masih diperlukan untuk dokumentasi, tetapi kita tidak mengandalkan beberapa kode error yang tidak kelihatan dalam kode yang dibaca.---## 1. Klasifikasi error### 1.1 Error HTTPDari `server.cjs`:```js
if (!response.ok) throw new Error("HTTP " + response.status + " dari Growatt");```
Dari `api/snapshot.js`:```js
if (!res.ok) throw new Error("HTTP " + res.status);```
Maksud: jika status HTTP bukan `ok`, tangani sebagai HTTP error.**Contoh kode yang dapat timbul:**- `401` — autentikasi / token gagal- `403` — akses ditolak- `429` — rate limit / terlalu banyak request- `500`, `502`, `503`, `504` — server/ingress/Growatt tidak menjawab### 1.2 Error `error_code` bukan 0Dari `server.cjs`:```js
if (Number(body.error_code) !== 0) {throw new Error("Growatt error_code " + body.error_code + ": " + (body.error_msg || "?"));}```
From `api/snapshot.js`:```js
if (Number(body.error_code) !== 0) {throw new Error("Growatt code " + body.error_code + ": " + (body.error_msg || "?"));}```
Artinya:- HTTP `200` belum tentu berarti berhasil.- `error_code` harus dicek.- `error_code === 0` adalah kondisi sukses.### 1.3 TimeoutDari `server.cjs`:```js
fetchWithTimeout(url, options, REQUEST_TIMEOUT_MS)```
`api/snapshot.js` menggunakan `AbortController`:```js
const controller = new AbortController();const timer = setTimeout(() => controller.abort(), timeoutMs);```
`verify-device.cjs` menggunakan `Promise.race` dengan mendeteksi timeout koneksi + membaca body.Error dari timeout harus dipisahkan dari error jaringan tertentu, sehingga bisa ditangani ulang sesuai kebutuhan.---## 2. Error yang terlihat di `verify-device.cjs`Dari komentar kode (tanpa mengubah) kita tahu indikator error yang sering terjadi:- `10005` — `inverterNotExistError`: `growatt.devices` di config tidak dikenal server. Biasanya karena menggunakan `datalogger_sn` sebagai `device_sn`.- `10012` — `error_frequently_access`: rate limit. Script otomatis retry setelah 30s, kemudian 60s.Implementasi retry:```js
const RETRY_DELAYS_S = [30, 60];```
Dan tetap retry untuk `10012`:```js
if (Number(body.error_code) === 10012 && attempt < RETRY_DELAYS_S.length) { ... }```
---## 3. Kategori error yang harus didokumentasikan| Kategori | Ciri | Langkah umum ||---|---|---|| HTTP error | `!response.ok` | Cek `status`, jangan lanjut ke parsing || `error_code` bukan 0 | Body `error_code !== 0` | Cek `error_msg`, dapatkan `data` yang valid || Token tidak valid | `401`, `403`, atau `error_code` terkait token | Periksa env, base URL, token, environment || Device SN tidak valid | `10005` / `inverterNotExistError` | Ganti ke `device_sn` yang valid dari `device/list` || Inverter tidak tersedia | `error_code` terkait device tidak ditemukan | Hapus atau tandai offline, amati riwayat ulang || Rate limit | `10012` | Jeda 30–60 detik, batasi concurrency || Timeout | `Timeout ms` / abort | Batasi interval, retry dengan backoff || Koneksi gagal | Network error | Retry, periksa DNS, firewall, cert, proxy, base URL || Body bukan JSON | `response.json()` gagal | Ambil body error, lakukan diagnostic || Simulator data | `mode === simulate` | Tandai sebagai fiktif, jangan gunakan untuk produksi |---## 4. `data kosong`, `stale`, `offline`, `error`### `data kosong````js
const raw = entry.data ? entry.data.data : null;```
Jika `raw` null, field di snapshot diisi `-1` / `null` / `MENUNGGU DATA`.Kode:```js
status: raw ? raw.status : -1,statusText: raw ? raw.statusText || "—" : "MENUNGGU DATA",```
### `stale`Kode di `server.cjs`:```js
online: !!(raw && Date.now() - state.lastPollAtMs < EFFECTIVE_POLL_MS * 4),```
Perhitungan menunjukkan:- `raw` ada, tapi `lastPollAtMs` terlalu lama, `online` menjadi false.- `statusText` tetap yang merepresentasikan status.### `offline`Implementasi `api/snapshot.js`:```js
const sim = simulateDevice(sn, now);sim.online = false;sim.statusText = "OFFLINE";```
### `error`Dalam `server.cjs`:```js
state.lastError = okCount === 0 ? "semua device gagal pada poll #" + state.pollCount : null;```
Dalam `api/snapshot.js`:```js
lastError = res.reason ? res.reason.message : "Fetch gagal";```
Flexibel:- `lastPollOk` false → minimal ada 1 device gagal.- `lastError` null → tidak ada error global.- `lastError` string → semua device gagal.---## 5. Pola penanganan yang harus dipakai oleh ELFAN1. **Validasi `error_code`**.2. **Batasi `pollInterval` minimal 30s** jika mode growatt.3. **Gunakan `Promise.allSettled`**, bukan `Promise.all`.4. **Retry dengan backoff** untuk `10012`, timeout, atau jaringan.5. **Jangan menghentikan seluruh pollling** karena 1 device gagal.6. **Simpan status `offline`**, bukan menghapus device secara otomatis.7. **Jangan menampilkan data simulasi ke laporan pengukuran** tanpa label.8. **Log awal error** dengan `device_sn`, `baseUrl`, `error_code`, `error_msg`, `http_status`.---## 6. field `dataloggerSn` vs `device_sn` saat errorBila Growatt mengembalikan:```json
{"dataloggerSn": "AH13140003","device_sn": "2033022963","data": { ... }}```
Praktik yang benar:- Gunakan `device_sn` untuk berikutnya.- Gunakan `dataloggerSn` untuk pemetaan device, tag, dan riwayat.**Jangan** lakukan:```text
last_new_data?device_sn=<dataloggerSn>```
Kecuali ada dokumentasi baru yang menegaskan sebaliknya. Tidak ada bukti dalam kode yang diamati.