# 12 --- Debugging Workflow

## Tujuan

Menetapkan prosedur debugging agar perbaikan dilakukan berdasarkan root
cause, bukan tebakan atau perubahan acak.

## Aturan utama

-   Pahami bug dan perilaku yang diharapkan sebelum mengubah kode.
-   Reproduksi masalah jika memungkinkan.
-   Kumpulkan log, stack trace, langkah reproduksi, kondisi
    perangkat/jaringan, dan versi.
-   Pisahkan fakta, dugaan, dan informasi yang belum diketahui.
-   Jangan refactor kode yang tidak terkait.
-   Jangan mengklaim bug selesai sebelum diverifikasi.

## Informasi awal

Catat deskripsi bug, expected behavior, actual behavior, langkah
reproduksi, frekuensi, lingkungan/versi, log/error, waktu kejadian,
kondisi jaringan/perangkat jika relevan, dan perubahan terakhir yang
mungkin terkait. Informasi yang tidak tersedia harus ditandai `UNKNOWN`.

## Prosedur

1.  **Restate:** jelaskan ulang masalah agar definisi bug disepakati.
2.  **Reproduce:** ikuti langkah reproduksi dan catat hasil. Jika gagal
    direproduksi, dokumentasikan percobaannya.
3.  **Hypothesize:** buat kemungkinan root cause berdasarkan bukti,
    urutkan berdasarkan probabilitas, dan jelaskan alasannya.
4.  **Test hypotheses:** tentukan pemeriksaan tercepat, bukti yang
    diharapkan, bukti yang membantah, dan test kecil yang aman.
5.  **Confirm root cause:** tandai `Confirmed`, `Probable`, atau
    `Unknown`.
6.  **Minimal fix:** ubah bagian terkecil yang menyelesaikan penyebab.
    Pertahankan kontrak dan perilaku lain.
7.  **Verify:** jalankan test yang relevan, regression test, analyzer,
    dan pemeriksaan efek samping.

## Format laporan debugging

-   Bug dan dampak.
-   Expected vs actual behavior.
-   Langkah reproduksi.
-   Bukti dan log.
-   Hipotesis root cause dan probabilitas.
-   Pemeriksaan yang dilakukan.
-   Root cause dan tingkat keyakinan.
-   Perubahan yang diusulkan/dilakukan.
-   Test dan hasil sebenarnya.
-   Risiko tersisa atau kebutuhan konfirmasi.

## Larangan

Jangan melakukan shotgun debugging, menghapus test yang gagal,
menonaktifkan validasi/authentication sebagai jalan pintas,
menyembunyikan exception tanpa memahami penyebab, atau mengubah file
tidak terkait.

## Kriteria selesai

Root cause dikonfirmasi atau keterbatasannya dijelaskan, perbaikan
minimal diverifikasi, regression test relevan lulus, dan hasil
dilaporkan.
