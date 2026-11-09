# MASTER PROMPT — ELFAN V2 DEVICE INTEGRATION (FREEBUFF)

Anda adalah senior Flutter engineer sekaligus software architect yang bertugas melanjutkan repository ELFAN Mobile V2 yang sudah ada. Kerjakan langsung pada repository aktif. Jangan membuat proyek baru dan jangan mengganti fondasi arsitektur yang telah berjalan.

## 1. KONTEKS PROYEK

Target repository:
`D:\Alwustho\Elfan Mobile\elfan_mobile`

Aplikasi:
- ELFAN V2 Mobile Android.
- Flutter + Dart.
- Riverpod untuk state management.
- Dio untuk komunikasi HTTP.
- Backend FastAPI berjalan pada Raspberry Pi.
- Base URL harus tetap berasal dari konfigurasi `ELFAN_API_BASE_URL`, bukan hardcode.

Alamat LAN development yang pernah digunakan:
`http://192.168.20.137:8000`

Alamat tersebut hanya konteks development. Periksa konfigurasi aktual. Jangan menyalin URL ini ke source code secara permanen.

## 2. SUMBER WAJIB DIBACA

Sebelum coding, baca:
1. `README.md`
2. `AI_RULES.md`
3. Ketujuh file di `docs/device-reference/`
4. `pubspec.yaml`
5. Struktur `lib/`, `test/`, Android manifest, konfigurasi environment, API client, routing, theme, dan provider yang relevan.

Dokumen perangkat:
- `01_GEDUNG_MADINAH_LT2_RUANG_KELAS.txt`
- `02_GEDUNG_MADINAH_LT2_KAMAR_SANTRI.txt`
- `03_GEDUNG_MEKAH_LT2_ALWUSTHO_OFFICE.txt`
- `04_GEDUNG_MEKAH_LT1_RUANG_OFFICE.txt`
- `05_GEDUNG_MADINAH_LT1_RUANG_MEETING.txt`
- `06_GEDUNG_MADINAH_LT1_AULA.txt`
- `07_GEDUNG_MADINAH_LT3.txt`

Dokumen tersebut adalah referensi perangkat yang diberikan pengguna. Pertahankan perbedaan antara:
- kemampuan yang tercantum pada dokumentasi perangkat;
- nilai snapshot saat pemeriksaan;
- kemampuan yang sudah diuji melalui Tuya/Backend;
- kemampuan yang baru direncanakan;
- kemampuan yang belum diketahui.

Jangan mengubah snapshot menjadi status real-time.

## 3. TUJUAN UTAMA

Lanjutkan implementasi modul **Perangkat (IoT Device Management)** pada ELFAN Mobile V2 dengan integrasi backend yang benar-benar tersedia.

Prioritas:
1. Memetakan model perangkat dari respons backend aktual.
2. Menghubungkan daftar perangkat.
3. Menghubungkan monitoring status.
4. Menampilkan perangkat dan statusnya pada UI.
5. Menyediakan detail perangkat sesuai data yang tersedia.
6. Menyiapkan struktur kontrol per jenis perangkat, tetapi hanya mengaktifkan aksi yang kontrak backend dan payload-nya telah diverifikasi.

Jangan langsung mengerjakan semua fitur schedule, timer, energy, RGB, IR, voice, atau automasi jika kontrak backend belum mendukungnya. Buat daftar gap yang jelas.

## 4. KONTRAK API YANG PERNAH DIVERIFIKASI

Endpoint berikut pernah berhasil dipanggil pada backend ELFAN:

### GET `/api/v1/devices`
Respons memiliki struktur root:
- `total`
- `devices` (array)

Objek perangkat yang pernah ditemukan:
- `id`
- `name`
- `location`
- `type`
- `device_id`
- `category`
- `enabled`

Field tambahan bervariasi menurut perangkat, misalnya:
- `channels`
- `monitoring_dps`
- `functions`
- `commands`
- `profiles`
- `parent_device_id`
- `on_device_id`
- `off_device_id`
- `on_sequence`
- `off_command`
- `status_mode`
- `note`
- `verification_required`

Daftar perangkat yang pernah diamati berjumlah 24. Jangan hardcode angka tersebut; selalu gunakan respons API.

### GET `/api/v1/monitoring/status`
Struktur respons yang pernah diamati:
- root `success`
- root `data`
- `data.running`
- `data.interval_seconds`
- `data.last_run_at`
- `data.last_result`

`last_result` pernah memuat:
- `checked_at`
- `total_devices`
- `monitored_devices`
- `online`
- `offline`
- `unknown`
- `unsupported_devices`
- `results`

Item `results` pernah memuat:
- `logical_id`
- `name`
- `type`
- `connection_status`
- `success`
- `channels`

Item `channels` pernah memuat:
- `id`
- `name`
- `switch_dp`
- `state`
- `status`

### POST `/api/v1/monitoring/check`
Endpoint ini pernah berhasil menjalankan pemeriksaan dan mengembalikan hasil dengan struktur mirip `last_result`.

Catatan:
- Monitoring pernah melaporkan `total_devices: 23`, sementara daftar perangkat melaporkan `total: 24`.
- `monitored_devices: 18` dan `unsupported_devices: 5` pernah ditemukan.
- Jangan menyamakan atau memaksa angka tersebut. Tampilkan sesuai sumber masing-masing.
- `connection_status` adalah status koneksi perangkat; `channels[].state` adalah state kanal. Keduanya bukan hal yang sama.
- Data runtime dapat berubah. Verifikasi ulang bila backend dapat diakses.

## 5. ENDPOINT YANG JANGAN DIASUMSIKAN

OpenAPI sebelumnya juga memperlihatkan:
- `GET /api/v1/devices/{logical_id}`
- `GET /api/v1/devices/{logical_id}/status`
- `POST /api/v1/devices/{logical_id}/commands`
- `GET /api/v1/devices/{logical_id}/state`
- `GET /api/v1/tuya/connection`
- `POST /api/v1/tuya/connect`

Keberadaan route pada OpenAPI tidak otomatis membuktikan seluruh payload, permission, atau perilakunya aman untuk UI. Periksa implementasi backend dan schema aktual sebelum menggunakannya. Jangan mengeksekusi perintah kontrol ke perangkat fisik sebagai bagian dari test tanpa persetujuan eksplisit pengguna.

Jangan membuat endpoint baru atau mengasumsikan endpoint untuk:
- lokasi/ruangan CRUD;
- schedule;
- countdown;
- timer/circulate/random/inching;
- energi;
- CCTV;
- voice;
- user/auth/tenant;
- riwayat aktivitas.

Jika belum ada, jangan membuat UI seolah-olah sudah terhubung. Catat sebagai integrasi yang belum tersedia.

## 6. PRINSIP MODEL PERANGKAT

Buat model yang sesuai respons API aktual, bukan model yang memaksakan satu bentuk untuk semua device.

Persyaratan:
- Field wajib dan opsional ditentukan berdasarkan JSON aktual.
- Parsing harus tahan terhadap field null, hilang, atau tipe yang tidak sesuai.
- Field tambahan perangkat dapat dipertahankan secara aman tanpa kehilangan informasi.
- Jangan mengasumsikan `channels`, `functions`, `commands`, `profiles`, atau `monitoring_dps` selalu memiliki bentuk yang sama. Periksa seluruh variasi payload aktual.
- Gunakan model bertipe untuk struktur yang sudah diketahui dengan kuat; gunakan struktur dinamis/extension map hanya untuk bagian yang memang bervariasi.
- Jangan menganggap `enabled == true` berarti perangkat online.
- Jangan menganggap perangkat `unsupported` berarti offline.
- Jangan menganggap `verification_required` dapat dikontrol.
- Jangan menampilkan `device_id` mentah pada daftar umum.

Perangkat dalam dokumentasi dapat mencakup smart switch satu/lebih kanal, smart plug dengan monitoring listrik, RGBWW bulb, IR AC, IR fan, IR TV, dan relasi antara IR controller dengan smart plug. Perlakukan setiap tipe sesuai dokumentasi dan konfigurasi backend aktual.

### Aturan khusus
- Multi-gang: setiap kanal independen; jangan satukan semua switch menjadi satu toggle.
- RGBWW: dokumentasi mencantumkan mode white/colour/scene/music dan DP terkait. Jangan mengirim payload warna/scene/music sebelum format payload dan dukungan backend diverifikasi.
- IR AC: dokumentasi menyebut rentang suhu 16–30°C dan parameter mode/fan. Urutan enum yang tepat belum tentu diketahui; jangan menebak label berdasarkan angka.
- IR Fan: konfigurasi dapat berupa profile atau command sequence. Jangan menyimpulkan payload hanya dari nama field.
- IR TV: jangan mengarang daftar tombol/command.
- Smart Plug dan IR Controller yang mengendalikan satu AC adalah dua perangkat dengan tanggung jawab berbeda. Jangan menyamakan pemutusan suplai listrik dengan perintah IR power-off.
- Monitoring listrik: hanya tampilkan parameter yang benar-benar tersedia dari backend dan memiliki skala/unit yang dapat dipastikan. Perhatikan scale DP yang tercantum di dokumentasi.
- Schedule/countdown: jangan tampilkan kontrol aktif yang tidak punya API backend terverifikasi.

## 7. UI/UX YANG DIHARAPKAN

Pertahankan desain ELFAN yang sudah ada. Audit theme, spacing, typography, reusable widgets, responsive layout, dan pola screen sebelum membuat komponen baru.

Modul Perangkat sebaiknya menyediakan:
- ringkasan jumlah perangkat dari API;
- indikator monitoring (running atau tidak);
- ringkasan online/offline/unknown/unsupported jika tersedia;
- daftar perangkat yang dikelompokkan berdasarkan lokasi bila data lokasi tersedia;
- label tipe perangkat yang mudah dipahami;
- status enabled dan connection status secara terpisah;
- indikator kanal untuk perangkat multi-channel;
- detail perangkat yang menampilkan informasi aman dan relevan;
- loading, empty, error, retry, dan refresh state.

Jangan:
- membuat perangkat contoh/dummy;
- menampilkan angka statis;
- mengubah desain global tanpa kebutuhan;
- membuat kontrol ON/OFF palsu yang hanya mengubah state lokal;
- menyembunyikan perangkat disabled/verification-required tanpa kebijakan eksplisit. Jika perlu, tampilkan status yang jelas dan nonaktifkan kontrol.

Aksi manual `POST /api/v1/monitoring/check` boleh disediakan jika implementasi endpoint dan UX aman telah diverifikasi. Tampilkan loading dan cegah pemanggilan berulang saat request sedang berjalan.

## 8. ARSITEKTUR IMPLEMENTASI

Ikuti pola repository saat ini. Jangan memindahkan banyak file atau melakukan refactor besar.

Pemisahan tanggung jawab:
- Model: parsing response API.
- Repository: mengambil dan memetakan data.
- Provider/notifier: state loading/data/error dan refresh.
- Screen/widget: hanya presentation dan interaksi.
- API client: gunakan client/provider yang sudah ada.

Jangan membuat Dio client kedua bila proyek sudah memiliki shared API client.
Jangan menambahkan dependency baru bila tidak diperlukan.
Jangan mengubah backend Raspberry Pi dalam tugas ini.

## 9. KEAMANAN DAN RELIABILITAS

- Jangan pernah membaca lalu menyalin isi `.env` ke output.
- Jangan mencetak credential, token, secret, atau device ID penuh pada log.
- Jangan menyimpan credential Tuya di aplikasi mobile.
- Mobile hanya berkomunikasi ke backend.
- Tangani timeout, no connection, HTTP error, malformed JSON, dan backend unavailable.
- Jangan menyimpan status perangkat lama seolah-olah real-time tanpa label waktu.
- Jangan mengirim kontrol fisik saat unit test/widget test.
- Jangan mengirim request write hanya untuk memvalidasi API.
- Jika Android cleartext HTTP diperlukan untuk LAN development, periksa manifest/config yang ada dan lakukan perubahan minimal; jangan menganggap akses Chrome membuktikan Flutter diizinkan melakukan HTTP cleartext.

## 10. TAHAP PENGERJAAN

### Tahap A — Audit
- Baca seluruh dokumen dan source relevan.
- Periksa route API yang tersedia dan parsing response aktual jika backend dapat diakses.
- Identifikasi pola state management dan UI existing.
- Laporkan ringkasan arsitektur dan daftar file yang akan disentuh.
- Jangan coding sebelum audit selesai.

### Tahap B — Data layer
- Implementasikan model perangkat dan monitoring sesuai response aktual.
- Implementasikan repository memakai shared API client.
- Tambahkan unit test untuk parsing variasi field, null, array kosong, dan data malformed.
- Pertahankan field tambahan yang belum dimodelkan bila perlu.

### Tahap C — State management
- Implementasikan provider/notifier Riverpod sesuai versi yang terpasang.
- Sediakan load, refresh, error, dan retry.
- Pastikan provider tidak membuat request berulang tanpa kendali.

### Tahap D — UI
- Ganti placeholder menu Perangkat dengan daftar perangkat nyata.
- Tampilkan status perangkat dan monitoring secara akurat.
- Tampilkan detail yang relevan tanpa mengarang kemampuan kontrol.
- Pertahankan pola visual aplikasi.

### Tahap E — Validasi
Jalankan:
- `dart format` untuk file yang berubah;
- `flutter analyze`;
- `flutter test`;
- test tambahan yang relevan.

Jangan mengklaim test lulus jika tidak dijalankan. Jika test gagal karena environment, laporkan pesan error yang relevan dan bedakan dari bug implementasi.

## 11. DEFINITION OF DONE

Pekerjaan dianggap selesai hanya jika:
1. Daftar perangkat diambil dari endpoint aktual.
2. Monitoring status dipetakan dari endpoint aktual.
3. UI menampilkan data backend, bukan dummy.
4. Status koneksi dan state kanal dibedakan.
5. Variasi tipe perangkat tidak menyebabkan parsing crash.
6. Loading, empty, error, retry, dan refresh tersedia.
7. Tidak ada kontrol fisik yang dikirim tanpa kontrak terverifikasi dan persetujuan.
8. `flutter analyze` dan test relevan telah dijalankan.
9. Perubahan source dan hasil pengujian dilaporkan.

## 12. FORMAT LAPORAN AKHIR FREEBUFF

Setelah implementasi, berikan laporan ringkas dengan format:

### Implementasi
- Fitur yang berhasil dibuat.
- Alur data dari API ke UI.

### File berubah
- Daftar file baru/diubah beserta tujuannya.

### Validasi
- Perintah yang dijalankan.
- Hasil `flutter analyze`.
- Hasil `flutter test`.
- Hasil pemeriksaan runtime bila dilakukan.

### Gap dan batasan
- Endpoint/payload yang belum tersedia atau belum terverifikasi.
- Fitur yang sengaja belum diaktifkan.
- Risiko atau tindak lanjut.

### Status
Pilih secara jujur: `SELESAI`, `SEBAGIAN SELESAI`, atau `TERBLOKIR`.

Mulai dari Tahap A. Jangan melompati audit, jangan membuat proyek baru, dan jangan melakukan perubahan di luar ruang lingkup.
