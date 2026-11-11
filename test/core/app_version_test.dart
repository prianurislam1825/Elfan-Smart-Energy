// Menjaga agar versi yang ditampilkan aplikasi tetap sinkron dengan pubspec.
//
// `pubspec.yaml` adalah sumber kebenaran. Tanpa dependency tambahan, satu-
// satunya cara memastikan tidak ada drift adalah memeriksanya di test.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:elfan_mobile/core/constants/app_constants.dart';

void main() {
  test('AppConstants.appVersion sama dengan versi di pubspec.yaml', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExpMatch? match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull, reason: 'version tidak ditemukan di pubspec.yaml');
    expect(
      AppConstants.appVersion,
      match!.group(1),
      reason: 'Perbarui AppConstants.appVersion agar sama dengan pubspec.yaml.',
    );
  });
}
