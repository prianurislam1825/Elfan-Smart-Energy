# Authentication — Token Growatt

> **Label:** `BERDASARKAN DOKUMENTASI` (sumber: `api-plts-inverter.pdf`, halaman 3–4; `README.md`; `config.json`; `verify-device.cjs`).

---

## 1. Mekanisme token

Dokumen Growatt menyatakan bahwa token adalah:

> “Token is generally defined as 32-bit verification code.”

Token diperoleh langsung dari Growatt New Energy Co. dan bersifat khusus milik akun/organisasi. Token digunakan untuk mengautentikasi request API.

## 2. Pengiriman token

Berdasarkan implementasi repository dan dokumen:

- Header yang tersedia: `token`
- Contoh dari `server.cjs`:
  ```js
  headers: { token: TOKEN, "Accept": "application/json" }
  ```
- Contoh dari `api/snapshot.js`:
  ```js
  headers: { token, Accept: "application/json" }
  ```
- `verify-device.cjs` menggunakan header yang sama:
  ```js
  headers: { token: TOKEN, Accept: "application/json" }
  ```

**Kesimpulan:** Username/password atau `Authorization: Bearer` tidak terpakai dalam kode yang diamati. Header `token` adalah mekanisme autentikasi yang digunakan.

> ⚠️ Token contoh tersebut ada dalam dokumen Growatt. Mengingat ketentuan dokumen ini, **token ini tidak boleh ditulis dalam dokumen integrasi**.

---

## 3. Environment test dan production

Dokumen terlihat menguji lingkungan:

- Halaman 3 `api-plts-inverter.pdf`:
  - `Need token authentication please contact Growatt New Energy Co. to obtain the only token`
- Halaman 4 `api-plts-inverter.pdf`:
  - `http://test.growatt.com/v1/`
- `README.md` menyebutkan:
  > Base URL di PDF adalah environment test — untuk produksi ganti `baseUrl` dan pakai token asli dari Growatt.
- `verify-device.cjs` menawarkan opsi base URL lain:
  - `http://test.growatt.com/v1`
  - `https://open.growatt.com/v1`
  - `https://api.growatt.com/v1` (tidak ada di file, hanya sebagai contoh diagnosis)

**Kesimpulan:** Ada minimal dua lingkungan yang diindikasikan:

1. **Test / contoh**: `http://test.growatt.com/v1` dengan token yang sesuai environment tersebut.
2. **Production / live**: ganti `baseUrl` dan gunakan token yang diberlakukan untuk akun produksi.

---

## 4. Pengelolaan token dengan environment variable

Repo `monitoring-inverter` belum mengelola token secara penuh melalui lingkungan tunggal: `config.json` berisi token, dan ada `config.local.json` yang berisi token lainnya.

Untuk backend ELFAN, rekomendasi penanganan token:

1. **Jangan simpan token di `config.json` yang bisa terbaca oleh siapa saja** jika repo dipublikasikan.
2. Simpan token di environment variable yang berbeda, misalnya:
   - `GROWATT_TOKEN`
   - `GROWATT_BASE_URL`
   - `GROWATT_DEVICES`
3. `api/snapshot.js` memuat override dari environment variable:
   ```js
   if (process.env.GROWATT_TOKEN) {
     base.growatt.token = process.env.GROWATT_TOKEN;
   }
   if (process.env.GROWATT_BASE_URL) {
     base.growatt.baseUrl = process.env.GROWATT_BASE_URL;
   }
   if (process.env.GROWATT_DEVICES) {
     base.growatt.devices = process.env.GROWATT_DEVICES.split(",").map((s) => s.trim());
   }
   ```
4. Backend ELFAN harus mengikuti pola yang sama:
   - Priority: env var > config lokal > config default
   - Token tidak boleh terekspos lewat endpoint publik, log, atau error message yang dikembalikan ke klien.

> ⚠️ **Larangan:** Jangan simpan token dalam source code, Flutter, dokumen publik, version control, atau log yang bisa dibaca pengguna akhir.

---

## 5. Perbedaan test vs production

| Aspek | Test / contoh | Production / live |
|---|---|---|
| Base URL | Umumnya `http://test.growatt.com/v1` | Ganti dengan URL yang valid untuk akun |
| Token | Token test yang diberikan Growatt | Token production yang diberikan Growatt |
| Daftar device | Mungkin berubah atau kosong | Gunakan `device_sn` yang valid dari `device/list` atau `plant/list` |
| Kestabilan | Bisa flaky (rate limit, plant/device hilang) | Perlu pengujian awal |
| Validasi | Tidak mengikat untuk produksi | Harus diverifikasi sebelum integrasi |

> **Penting:** Mode `simulate` di `monitoring-inverter` tidak akan menguji autentikasi Growatt. Mode `growatt` hanya akan berfungsi jika `token`, `baseUrl`, dan daftar `device_sn` valid di environment yang sama.
