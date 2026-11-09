# 11 --- Security Audit Guidelines

## Tujuan

Menetapkan proses audit keamanan ELFAN Mobile V2. Dokumen ini melengkapi
`03_USER_ROLES_AND_ACCESS.md`, `06_API_DOCUMENTATION.md`,
`07_DATABASE_AND_DATA_MODELS.md`, dan `10_TESTING_GUIDELINES.md`.

## Prinsip wajib

-   Audit berdasarkan source code, konfigurasi, dokumentasi, dan bukti
    yang tersedia.
-   Jangan mengarang endpoint, role, permission, autentikasi, atau alur
    data.
-   Audit awal bersifat read-only. Jangan mengubah kode sebelum
    persetujuan.
-   Jangan menampilkan secret, token, password, atau kredensial dalam
    laporan.
-   Setiap temuan harus memiliki bukti, lokasi, dampak, severity, dan
    rekomendasi.
-   Jika mekanisme belum tersedia atau tidak terdokumentasi, tandai
    `NEEDS CONFIRMATION`.

## Area pemeriksaan

### Authentication dan session

Periksa mekanisme autentikasi yang benar-benar digunakan, penyimpanan
token/kredensial, masa berlaku dan pencabutan sesi jika tersedia,
logout, serta kemungkinan kebocoran melalui log atau penyimpanan lokal.

### Authorization dan access control

Cocokkan pemeriksaan akses dengan `03_USER_ROLES_AND_ACCESS.md`.
Pastikan akses tidak hanya dibatasi pada UI. Periksa akses lintas
pengguna atau workspace/resource yang memang didefinisikan. Jangan
menambah role atau permission baru saat audit.

### Data dan secret

Cari secret yang tertanam di source/configuration, data sensitif pada
log dan error, file lokal yang tidak semestinya masuk version control,
serta pemisahan konfigurasi development/testing/production. Jangan
menyalin nilai secret ke laporan.

### Input, API, dan komunikasi

Periksa validasi input, penanganan response/error, risiko injection yang
relevan, validasi tipe/ukuran/format, HTTPS/TLS sesuai deployment,
timeout/retry, dan konfigurasi jaringan yang relevan.

### Dependency dan build

Periksa dependency dan versinya, advisory keamanan yang dapat
diverifikasi, konfigurasi debug, signing, permission aplikasi, dan
konfigurasi build. Jangan memperbarui dependency selama audit read-only.

### Logging dan error handling

Pastikan log tidak memuat secret atau data pribadi yang tidak diperlukan
dan pesan error tidak mengekspos stack trace atau konfigurasi internal.

## Klasifikasi severity

  -----------------------------------------------------------------------
  Severity                            Kriteria
  ----------------------------------- -----------------------------------
  Critical                            Kompromi sistem luas atau
                                      akses/kebocoran data sangat
                                      sensitif.

  High                                Dampak besar pada kerahasiaan,
                                      integritas, atau ketersediaan.

  Medium                              Risiko nyata dengan cakupan atau
                                      prasyarat terbatas.

  Low                                 Dampak terbatas atau memerlukan
                                      kondisi khusus.

  Informational                       Saran penguatan tanpa bukti
                                      kerentanan langsung.
  -----------------------------------------------------------------------

Sertakan alasan untuk setiap severity.

## Format temuan

1.  ID dan judul.
2.  Severity dan status: Confirmed / Suspected / Needs Confirmation.
3.  Lokasi file/baris/komponen.
4.  Bukti yang aman untuk dibagikan.
5.  Dampak dan skenario penyalahgunaan.
6.  Prasyarat eksploitasi.
7.  Rekomendasi perbaikan.
8.  Test verifikasi setelah perbaikan.

## Alur audit

1.  Tetapkan ruang lingkup dan revisi yang diperiksa.
2.  Baca aturan proyek dan dokumentasi terkait.
3.  Petakan komponen, data, dan alur akses yang benar-benar ada.
4.  Jalankan pemeriksaan statis dan pengujian aman.
5.  Validasi temuan dan singkirkan false positive.
6.  Susun laporan berdasarkan severity.
7.  Minta persetujuan sebelum mengubah kode/configuration.
8.  Setelah perbaikan disetujui, lakukan regression test dan audit
    ulang.

## Batasan

Jangan melakukan pengujian terhadap sistem eksternal tanpa izin,
menghapus data, mengubah permission produksi, atau menyatakan aplikasi
aman secara absolut. Laporkan ruang lingkup dan keterbatasan audit.

## Kriteria selesai

Ruang lingkup, metode, hasil, temuan, keterbatasan, dan rekomendasi
terdokumentasi serta dapat ditinjau.
