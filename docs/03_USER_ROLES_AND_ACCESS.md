# User Roles and Access

## Prinsip
Kategori akun utama baseline hanya dua: Super Admin dan User. Hak akses aktual ditegakkan backend. Menyembunyikan tombol di UI bukan keamanan.

## Super Admin
Mengelola organisasi, akun platform, status tenant, konfigurasi global, integrasi global, dan monitoring platform sesuai kebijakan. Akses ke isi CCTV/data privat tenant tidak otomatis diberikan kecuali kebijakan menetapkannya.

## User
Mengakses dashboard, lokasi, perangkat, kontrol, CCTV, energi, Voice Assistant, produktivitas, histori, dan preferensi sesuai permission.

## Permission konseptual (usulan)
`dashboard.view`, `location.view`, `location.manage`, `device.view`, `device.control`, `device.manage`, `cctv.view`, `energy.view`, `productivity.create`, `productivity.view`, `productivity.manage`, `history.view`, `notification.view`, `member.manage`, `organization.manage`.

Daftar ini usulan, bukan klaim sudah tersedia di backend.

## Resource scope
Platform, organisasi, properti/gedung, lantai/ruangan, perangkat/kamera, atau data milik sendiri.

## Matriks awal
| Aksi | Super Admin | User |
|---|---|---|
| Kelola organisasi | Ya, sesuai kebijakan | Tidak |
| Kelola akun platform | Ya, sesuai kebijakan | Tidak |
| Dashboard tenant | Sesuai cakupan | Sesuai izin |
| Lihat lokasi | Sesuai cakupan | Sesuai izin |
| Kontrol perangkat | Jika diberi izin | Jika diberi izin |
| Lihat CCTV | Jika diberi izin | Jika diberi izin |
| Lihat energi | Jika diberi izin | Jika diberi izin |
| Produktivitas | Sesuai kebijakan | Sesuai izin |
| Preferensi sendiri | Ya | Ya |

## Personal
Akun personal memiliki scope properti milik/dibagikan. Tidak wajib menampilkan organisasi formal. Representasi database masih TBD.

## Aturan keamanan
Deny by default; validasi ownership di backend; validasi permission setiap endpoint; audit aksi sensitif; jangan percaya tenant ID dari client.
