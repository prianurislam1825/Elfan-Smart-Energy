import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/shared/utils/error_message.dart';
import 'package:elfan_mobile/data/services/api_exception.dart';

void main() {
  group('describeApiError', () {
    test('memakai pesan spesifik untuk aksi yang tidak didukung', () {
      const ApiException error = ApiException(
        kind: ApiExceptionKind.unsupported,
        message: 'Backend tidak mengirim DP kontrol untuk perangkat ini.',
      );

      expect(
        describeApiError(error),
        'Backend tidak mengirim DP kontrol untuk perangkat ini.',
      );
    });

    test('memakai pesan pengguna untuk kegagalan jaringan', () {
      const ApiException error = ApiException(
        kind: ApiExceptionKind.connection,
        message: 'detail teknis',
      );

      expect(
        describeApiError(error),
        'Tidak dapat terhubung ke server. '
        'Periksa koneksi Anda.',
      );
    });

    test('meneruskan pesan teks apa adanya', () {
      expect(
        describeApiError('Format respons daftar perangkat tidak sesuai.'),
        'Format respons daftar perangkat tidak sesuai.',
      );
    });

    test('memakai fallback untuk nilai kosong atau tidak dikenal', () {
      expect(describeApiError(null, fallback: 'Gagal.'), 'Gagal.');
      expect(describeApiError('   ', fallback: 'Gagal.'), 'Gagal.');
      expect(describeApiError(42, fallback: 'Gagal.'), 'Gagal.');
    });
  });
}
