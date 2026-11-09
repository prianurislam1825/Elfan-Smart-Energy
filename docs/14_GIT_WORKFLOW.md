# 14 --- Git Workflow & Commit Guidelines

## Tujuan

Menetapkan cara merekam perubahan ELFAN Mobile V2 secara aman,
terstruktur, dan dapat ditinjau.

## Prinsip

-   Periksa kondisi repository sebelum dan sesudah pekerjaan.
-   Jangan mengasumsikan repository memiliki remote.
-   Jangan mengasumsikan strategi branch atau release yang belum
    dikonfirmasi.
-   Jangan menjalankan destructive Git command tanpa persetujuan
    eksplisit.
-   Jangan memasukkan secret, cache, artefak build, atau file lokal yang
    tidak diperlukan.
-   Jangan membuat commit jika belum diminta atau aturan proyek belum
    mengizinkannya.

## Pemeriksaan awal

Jalankan: - `git status` - `git branch --show-current` -
`git log -5 --oneline` - `git remote -v`

Remote kosong berarti belum ada remote yang dikonfigurasi; jangan
menyatakan GitHub sudah terhubung hanya karena Git lokal aktif.

## Review perubahan

Sebelum staging, tinjau: - `git diff` - `git diff --stat` -
`git status --short`

Periksa file untracked secara eksplisit. Untuk staged changes, tinjau
`git diff --cached` dan `git diff --cached --stat`.

## Atomic commit

Satu commit mewakili satu perubahan logis. Pisahkan feature, bug fix,
refactor, test, documentation, dan build/configuration jika merupakan
pekerjaan berbeda.

## Format commit

Gunakan Conventional Commits jika sesuai aturan repository:

`type(scope): imperative summary`

Jenis umum: - `feat`: fitur. - `fix`: perbaikan bug. - `refactor`:
perubahan struktur tanpa perubahan perilaku yang dimaksud. - `test`:
pengujian. - `docs`: dokumentasi. - `build`: build/dependency. - `ci`:
continuous integration. - `perf`: performa. - `style`: format tanpa
perubahan logika. - `chore`: pemeliharaan.

Contoh: - `docs(security): add security audit guidelines` -
`test(auth): cover expired session handling` -
`fix(api): handle empty response safely`

## Prosedur commit

1.  Pastikan task dan test relevan selesai.
2.  Periksa seluruh perubahan dan file untracked.
3.  Pastikan tidak ada secret atau file tidak terkait.
4.  Stage hanya file yang relevan.
5.  Periksa staged diff.
6.  Buat commit dengan pesan spesifik.
7.  Verifikasi `git status` dan `git log -1 --oneline`.
8.  Laporkan hash commit dan ringkasan.

Jangan menjalankan `git add .` secara otomatis tanpa meninjau seluruh
perubahan.

## Operasi yang memerlukan persetujuan eksplisit

`git reset --hard`, `git clean -fd`, force push, rewriting shared
history, penghapusan branch, penggantian remote, dan operasi checkout
yang dapat menimpa perubahan lokal.

## Branch dan remote

Strategi branch, protected branch, review, remote, dan CI mengikuti
konfigurasi repository yang benar-benar tersedia. Jika belum ditentukan,
tandai `NEEDS CONFIRMATION`.

## Kriteria selesai

Status repository bersih atau sisa perubahan dijelaskan, commit dapat
ditelusuri jika dibuat, dan tidak ada file sensitif/tidak terkait yang
ikut masuk.
