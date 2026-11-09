# ELFAN V2 — Freebuff Implementation Kit

Paket ini ditujukan untuk ditempatkan pada root repository Flutter:

`D:\Alwustho\Elfan Mobile\elfan_mobile`

## Penempatan

Ekstrak isi ZIP sehingga struktur berikut berada di root repository:

```text
elfan_mobile/
├── AI_RULES.md
├── AI_IMPLEMENTATION_PROMPT.md
└── docs/
    └── device-reference/
        ├── 01_GEDUNG_MADINAH_LT2_RUANG_KELAS.txt
        ├── 02_GEDUNG_MADINAH_LT2_KAMAR_SANTRI.txt
        ├── 03_GEDUNG_MEKAH_LT2_ALWUSTHO_OFFICE.txt
        ├── 04_GEDUNG_MEKAH_LT1_RUANG_OFFICE.txt
        ├── 05_GEDUNG_MADINAH_LT1_RUANG_MEETING.txt
        ├── 06_GEDUNG_MADINAH_LT1_AULA.txt
        └── 07_GEDUNG_MADINAH_LT3.txt
```

Jika `AI_RULES.md` atau folder `docs/device-reference` sudah ada, jangan menimpa pekerjaan yang lebih baru tanpa membandingkan isinya terlebih dahulu.

## Cara menjalankan Freebuff

1. Buka Freebuff pada root repository `elfan_mobile`.
2. Pastikan agent memiliki akses baca/tulis ke repository.
3. Buka `AI_IMPLEMENTATION_PROMPT.md`.
4. Salin seluruh isi prompt tersebut ke Freebuff.
5. Izinkan agent memeriksa dan mengubah file proyek sesuai ruang lingkup dan aturan.
6. Periksa ringkasan perubahan dan hasil pengujian sebelum menerima perubahan.

## Prinsip dokumentasi

Tujuh TXT ditata ulang secara ringan: nama file diseragamkan, metadata sumber ditambahkan, dan line ending/whitespace dinormalisasi. Isi teknis sumber dipertahankan; tidak ada nilai DP, Device ID, rentang, atau payload yang sengaja direka atau dikoreksi.

Dokumentasi perangkat adalah referensi kemampuan perangkat, bukan bukti bahwa seluruh fitur sudah tersedia pada backend. Freebuff wajib memverifikasi kontrak API dari source backend/OpenAPI aktual sebelum menghubungkan UI.
