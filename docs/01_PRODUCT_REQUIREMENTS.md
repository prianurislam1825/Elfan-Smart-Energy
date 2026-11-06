# Product Requirements Document — ELFAN Mobile V2

**Versi:** 1.0 | **Status:** Baseline untuk elaborasi dan validasi  
**Platform awal:** Android | **Implementasi pertama:** Alwustho  
**Arah produk:** Multi-organization dan personal use

## 1. Ringkasan
ELFAN adalah platform Smart Building Management yang mengintegrasikan perangkat IoT, AI Voice Assistant, CCTV, pemantauan energi, dan produktivitas. ELFAN Mobile V2 menjadi aplikasi Android untuk memantau, mengontrol, dan mengelola fasilitas sesuai hak akses.

Alwustho adalah implementasi pertama, bukan batasan arsitektur. Produk harus dapat dikonfigurasi untuk organisasi lain dan pengguna perseorangan.

## 2. Masalah dan tujuan
Pengelolaan perangkat, CCTV, energi, dan aktivitas fasilitas sering tersebar pada aplikasi berbeda. ELFAN menyatukan antarmuka, status, kontrol, dan akses.
- Menyatukan pengelolaan fasilitas pintar.
- Menyediakan status perangkat yang dapat dipercaya.
- Memudahkan kontrol melalui UI dan Push-to-Talk.
- Menyatukan CCTV dan informasi energi.
- Mendukung laporan produktivitas.
- Mendukung banyak organisasi dan akun personal.

## 3. Target
**Organisasi:** pesantren, sekolah, universitas, kantor, perusahaan, gedung komersial. Setiap organisasi memiliki lokasi, pengguna, perangkat, kamera, dan konfigurasi sendiri.

**Personal:** pengguna dapat mengelola satu atau lebih properti/rumah. Struktur tidak mewajibkan organisasi formal, banyak gedung, atau banyak lantai.

## 4. Prinsip multi-tenant
- Data organisasi terisolasi.
- Pengguna hanya mengakses tenant/resource yang diizinkan.
- Akun personal memiliki ownership scope yang jelas.
- Lokasi dan resource dikelola dinamis.
- Backend memvalidasi tenant dan permission setiap operasi.
- Filter UI bukan mekanisme keamanan.

## 5. Peran
Dua kategori utama:
- **Super Admin:** mengelola platform dan organisasi sesuai kebijakan platform.
- **User:** menggunakan resource organisasi atau personal sesuai permission.

Permission granular dapat dikembangkan sebagai assignment, tanpa mengubah dua kategori akun utama tanpa keputusan produk.

## 6. Navigasi
Bottom navigation lima menu: Home, Perangkat, Voice, CCTV, Energi.
Modul pendukung: Productivity, Activity History, Notifications, Profile, Settings, Organization Management.

## 7. Ruang lingkup modul
### Home
Konteks organisasi/properti aktif, ringkasan perangkat, online/offline, lokasi, monitoring, quick controls, energi, notifikasi. Data harus berasal dari API aktual atau diberi label data contoh.

### Perangkat
Daftar, detail, status, kontrol, pengelompokan lokasi, monitoring, histori. Hierarki: Organization/Personal → Property/Building → Floor (opsional) → Room/Area → Device. Jenis awal: switch, plug, bulb, Universal IR Controller, dan appliance IR jika didukung backend.

### Voice
Push-to-Talk: tekan mic, rekam, kirim audio, proses STT/intent, command engine, DeviceController bila perlu, respons/TTS. Wake word “Oke Elfan” tidak masuk MVP. Perintah ambigu meminta klarifikasi dan kontrol memerlukan permission.

### CCTV
Daftar kamera, live view, multi-camera, lokasi, status, loading, error, reconnect. Teknologi yang telah digunakan adalah MediaMTX WebRTC; kontrak endpoint dan autentikasi perlu audit.

### Energi
Data yang benar-benar tersedia: daya, tegangan, arus, energi, grafik, histori, solar/inverter/data logger jika terintegrasi. Jangan mengasumsikan semua metrik tersedia.

### Productivity
Laporan berisi pengguna, periode, lokasi, pekerjaan selesai, kendala, dan rencana berikutnya. Pola dua jam merupakan kebutuhan operasional awal; API dan workflow perlu diverifikasi.

### Notifications dan History
Pemberitahuan perangkat offline, kegagalan kontrol, gangguan koneksi, dan peringatan yang didukung backend. Riwayat memuat waktu, pelaku, objek, tindakan, hasil jika tersedia.

### Profile dan Settings
Informasi akun, konteks aktif, preferensi, notifikasi, koneksi, logout, dan versi aplikasi.

## 8. Non-functional requirements
Responsif; operasi jaringan tidak memblokir UI; timeout/error/koneksi putus ditangani; tidak ada secret di source; tenant terisolasi di backend; arsitektur modular; izin Android sesuai fitur; produksi menggunakan HTTPS; data real-time memiliki timestamp/stale indicator bila tersedia.

## 9. Baseline teknologi
Flutter/Dart, Riverpod, GoRouter, Dio, Shared Preferences. Backend existing FastAPI pada Raspberry Pi. Integrasi perangkat melalui backend/DeviceController; Tuya tidak dipanggil langsung dari mobile. CCTV melalui MediaMTX WebRTC. Detail Voice dan Energy API perlu audit.

## 10. Di luar MVP
Wake word always-listening, analisis video AI menyeluruh, face recognition penuh, prediksi energi, automasi AI kompleks, marketplace, billing/subscription, white-label, web dashboard.

## 11. Kriteria penerimaan MVP
1. Login/session sesuai kontrak backend.
2. Konteks personal/organisasi dapat ditentukan.
3. Data antar-tenant terisolasi.
4. Dashboard memakai data backend.
5. Lokasi/perangkat tampil sesuai akses.
6. Kontrol perangkat melalui backend.
7. Status sesuai hasil monitoring.
8. PTT merekam dan memproses audio sesuai API.
9. CCTV tampil melalui WebRTC sesuai akses.
10. Data energi ditampilkan jika sumber tersedia.
11. Laporan produktivitas dapat dibuat jika API tersedia.
12. Loading, empty, error, dan koneksi putus ditangani.
13. APK dapat dibangun dan diuji.

## 12. Keputusan terbuka
Registrasi organisasi, autentikasi/token, database multi-tenant, permission granular, deployment eksternal, koneksi remote Raspberry Pi, kontrak Voice/CCTV/Energy API, dan billing perlu keputusan sebelum implementasi.
