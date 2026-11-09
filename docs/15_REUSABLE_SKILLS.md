# 15 --- Reusable Skills & AI Agent Procedures

## Tujuan

Mengatur dokumentasi prosedur berulang agar AI coding agent dapat
bekerja konsisten tanpa bergantung pada konteks percakapan sebelumnya.

Dokumen ini adalah standar dan indeks skill. Dokumen ini sendiri tidak
berarti skill sudah terdaftar atau aktif di Freebuff.

## Prinsip

-   Skill harus spesifik, dapat dijalankan, dan memiliki batasan jelas.
-   Skill tidak menggantikan `AI_RULES.md` atau spesifikasi produk.
-   Skill merujuk dokumentasi proyek sebagai sumber kebenaran.
-   Jangan menyimpan secret, token, data pribadi, atau kredensial.
-   Jangan menganggap skill aktif sebelum file dan mekanisme
    pemanggilannya diverifikasi.
-   Hindari duplikasi aturan tanpa prosedur praktis tambahan.

## Kapan membuat skill

Buat skill jika prosedur dilakukan berulang, membutuhkan urutan
konsisten, memiliki acceptance criteria, atau dapat mencegah kesalahan
berulang. Hindari membuat skill untuk pekerjaan satu kali tanpa pola
reusable.

## Struktur skill

Setiap skill sebaiknya memiliki: 1. Name --- nama singkat dan
berorientasi tindakan. 2. Purpose --- masalah yang diselesaikan. 3.
Trigger --- kapan digunakan dan kapan tidak. 4. Inputs ---
informasi/file yang diperlukan. 5. Prerequisites --- kondisi awal. 6.
Instructions --- langkah berurutan. 7. Constraints --- hal wajib dan
terlarang. 8. Output --- hasil yang diharapkan. 9. Validation --- cara
memeriksa hasil. 10. Failure handling --- tindakan jika
prasyarat/validasi gagal. 11. Example --- contoh input dan output. 12.
Version/owner --- riwayat dan penanggung jawab jika diketahui.

## Template skill

``` markdown
# Skill: [Action-oriented name]

## Purpose
[Masalah yang diselesaikan]

## Trigger
[Kondisi penggunaan dan pengecualian]

## Inputs
[File, data, dan informasi yang diperlukan]

## Prerequisites
[Kondisi yang harus terpenuhi]

## Instructions
1. [Langkah pertama]
2. [Langkah berikutnya]
3. [Langkah validasi]

## Constraints
- [Hal wajib]
- [Hal yang dilarang]

## Output
[Hasil yang harus dihasilkan]

## Validation
[Acceptance criteria dan cara verifikasi]

## Failure Handling
[Tindakan jika gagal atau informasi kurang]

## Example
[Contoh penggunaan]

## Version History
[Versi dan perubahan]
```

## Kandidat skill ELFAN

Ini adalah usulan, bukan pernyataan bahwa skill sudah tersedia: -
`project-discovery-audit`: audit dokumentasi, source code, dan kondisi
proyek secara read-only. - `flutter-feature-implementation`:
implementasi fitur berdasarkan spesifikasi. - `root-cause-debugging`:
investigasi bug berdasarkan bukti. - `security-review`: audit keamanan
read-only. - `flutter-test-review`: memilih dan menjalankan test Flutter
yang relevan. - `safe-refactoring`: audit dan usulan refactoring sebelum
eksekusi. - `git-change-review`: review diff, file untracked, dan
kesiapan commit. - `documentation-maintenance`: memperbarui dokumentasi
tanpa mengubah requirement sepihak.

Lokasi dan mekanisme implementasi skill harus mengikuti kemampuan
agent/tool yang benar-benar digunakan.

## Lifecycle

1.  Identifikasi prosedur berulang.
2.  Catat proses yang telah terbukti.
3.  Tulis skill secara mandiri dan eksplisit.
4.  Review terhadap `AI_RULES.md` dan dokumentasi terkait.
5.  Uji dengan contoh nyata yang aman.
6.  Revisi berdasarkan hasil.
7.  Catat versi dan perubahan.
8.  Perbarui atau hentikan skill yang tidak lagi sesuai.

## Evaluasi skill

  Kriteria        Pertanyaan
  --------------- --------------------------------------------------------
  Reusability     Apakah prosedur digunakan berulang?
  Clarity         Dapatkah dipahami tanpa konteks chat?
  Safety          Apakah batasan dan operasi berisiko jelas?
  Verifiability   Apakah hasil dapat diuji?
  Scope           Apakah tidak mengambil alih tanggung jawab skill lain?
  Maintenance     Apakah perubahan dapat ditelusuri?

## Kriteria selesai

Skill siap jika tujuan, trigger, input, prasyarat, instruksi, batasan,
output, dan validasi jelas serta prosedur telah diuji.
