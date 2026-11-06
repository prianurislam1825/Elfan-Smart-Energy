# ELFAN Mobile V2

Dokumentasi baseline produk dan pengembangan ELFAN Mobile V2.

ELFAN adalah platform Smart Building Management yang pertama kali diterapkan di Alwustho, tetapi dirancang agar dapat digunakan organisasi lain dan pengguna perseorangan.

## Isi
- `AI_RULES.md`: aturan wajib coding agent.
- `docs/01_PRODUCT_REQUIREMENTS.md`: kebutuhan dan ruang lingkup produk.
- `docs/02_SYSTEM_ARCHITECTURE.md`: arsitektur aplikasi dan integrasi.
- `docs/03_USER_ROLES_AND_ACCESS.md`: peran dan akses.
- `docs/04_FEATURE_SPECIFICATION.md`: spesifikasi modul.
- `docs/05_UI_UX_GUIDELINES.md`: pedoman antarmuka.
- `docs/06_API_DOCUMENTATION.md`: audit dan kontrak API.
- `docs/07_DATABASE_AND_DATA_MODELS.md`: konsep data.
- `docs/08_SYSTEM_FLOW.md`: alur sistem.
- `docs/09_DEVELOPMENT_ROADMAP.md`: tahapan pengembangan.
- `docs/10_TESTING_GUIDELINES.md`: standar pengujian.
- `CHANGELOG.md`: riwayat dokumentasi.

## Lingkungan yang diketahui
- Flutter 3.35.4 stable, Dart 3.9.2.
- Proyek: `D:\Alwustho\Elfan Mobile\elfan_mobile`.
- FastAPI pada Raspberry Pi `192.168.20.137:8000`.
- Swagger: `http://192.168.20.137:8000/docs`.
- Backend source: `~/cv-engine`.
- Tuya adapter dan DeviceController telah ada.
- MediaMTX WebRTC telah digunakan untuk CCTV.

IP di atas adalah alamat LAN development, bukan alamat produksi. Endpoint, payload, autentikasi, dan schema harus diverifikasi dari backend aktual.
