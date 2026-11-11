/// Konstanta identitas aplikasi.
///
/// Nilai di sini hanya teks branding dan tidak memuat konfigurasi lingkungan.
abstract final class AppConstants {
  static const String appName = 'ELFAN';
  static const String tagline = 'Smart Building Management';
  static const String description =
      'Pantau perangkat, CCTV, dan energi dalam satu aplikasi.';

  /// Label platform yang ditampilkan pada kartu sambutan Home.
  static const String platformLabel = 'Mobile V2';

  /// Versi yang ditampilkan pada halaman Pengaturan.
  ///
  /// Samakan dengan `version` di `pubspec.yaml` saat merilis build baru.
  /// Versi yang ditampilkan di aplikasi.
  ///
  /// Sumber kebenaran tetap `version:` pada `pubspec.yaml`; nilai ini harus
  /// sama dan dijaga oleh `test/core/app_version_test.dart`. Duplikasi tidak
  /// dapat dihilangkan tanpa menambah dependency pembaca metadata build.
  static const String appVersion = '1.0.0';
}
