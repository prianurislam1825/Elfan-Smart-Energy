# 13 --- Code Quality & Refactoring Guidelines

## Tujuan

Mengatur audit kualitas kode, identifikasi dead code, dan refactoring
agar kode mudah dipahami, diuji, dan dipelihara.

## Prinsip

-   Utamakan keterbacaan, konsistensi, dan kesederhanaan.
-   Pertahankan perilaku aplikasi.
-   Refactoring harus memiliki alasan dan ruang lingkup.
-   Jangan menghapus kode yang belum terbukti tidak digunakan.
-   Jangan menambah dependency tanpa kebutuhan dan persetujuan.

## Fase 1 --- Audit read-only

Periksa kandidat: - File, class, function, method, atau variable yang
tidak digunakan. - Import atau dependency yang tampak tidak digunakan. -
Environment variable atau konfigurasi yang tidak direferensikan. - Kode
komentar yang tidak relevan. - Logic duplikat. - Placeholder dan TODO
yang belum diimplementasikan.

Periksa referensi tidak langsung, dependency injection, routing,
reflection, annotation, konfigurasi, build, test, dan platform-specific
code. Tidak ditemukannya referensi teks bukan bukti tunggal bahwa file
aman dihapus.

Beri confidence: - **High:** bukti kuat tidak digunakan. - **Medium:**
kemungkinan tidak digunakan, tetapi jalur dinamis belum terverifikasi. -
**Low:** bukti belum cukup.

Jangan menghapus item dengan confidence di bawah 90% tanpa pemeriksaan
tambahan dan persetujuan.

## Fase 2 --- Rencana

Untuk setiap perubahan, catat masalah, bukti/lokasi, manfaat, file
terdampak, risiko regresi, test, dan rencana rollback.

## Fase 3 --- Eksekusi setelah persetujuan

1.  Periksa kondisi Git.
2.  Catat hasil test baseline.
3.  Lakukan satu kelompok perubahan logis.
4.  Pisahkan cleanup, feature, dan bug fix.
5.  Jalankan formatter, analyzer, dan test relevan.
6.  Review diff untuk memastikan tidak ada perubahan tak terkait.
7.  Laporkan hasil dan risiko.

## Aturan refactoring

Pertahankan kontrak API dan model data publik kecuali disetujui. Hindari
rename massal, abstraction prematur, perubahan dependency tanpa alasan,
serta perubahan struktur file yang tidak memberi manfaat terukur.

## Format laporan

  -----------------------------------------------------------------------------------------------------------------------------------------------------
  Item          Temuan                        Bukti         Confidence        Risiko     Rekomendasi                        Approval
  ------------- ----------------------------- ------------- ----------------- ---------- ---------------------------------- ---------------------------
  File/symbol   Dead                          Referensi     High/Medium/Low   Dampak     Keep/Investigate/Refactor/Remove   Pending/Approved/Rejected
                code/duplikasi/kompleksitas   pemeriksaan                                                                   

  -----------------------------------------------------------------------------------------------------------------------------------------------------

## Kriteria selesai

Perubahan disetujui, diff sesuai ruang lingkup, kontrak terjaga, test
relevan lulus, dan hasil sebelum/sesudah dapat ditinjau.
