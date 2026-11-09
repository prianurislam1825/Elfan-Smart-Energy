// Widget test untuk aplikasi ELFAN Mobile V2.
//
// Tes ini memvalidasi inisialisasi aplikasi dan navigasi antar lima menu
// utama tanpa memanggil backend sungguhan.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elfan_mobile/app.dart';
import 'package:elfan_mobile/core/routing/app_destinations.dart';
import 'package:elfan_mobile/core/theme/color_tokens.dart';
import 'package:elfan_mobile/data/services/api_client_provider.dart';
import 'package:elfan_mobile/core/config/app_config_provider.dart';
import 'package:elfan_mobile/core/config/app_config.dart';

void main() {
  group('ElfanApp widget', () {
    testWidgets('menampilkan aplikasi ELFAN dan lima menu utama',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWith(
              (ref) => AppConfig(
                apiBaseUrl: 'https://api.example.test',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 30),
              ),
            ),
            apiClientProvider.overrideWith(
              (ref) => throw UnimplementedError(
                'apiClientProvider tidak boleh dipakai dalam tes ini.',
              ),
            ),
          ],
          child: const ElfanApp(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(AppDestination.home.label), findsWidgets);

      for (final AppDestination destination in AppDestination.values) {
        expect(find.text(destination.label), findsWidgets);
      }

      expect(find.text('ELFAN'), findsOneWidget);

      final ThemeData themeData =
          tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
      expect(themeData.colorScheme.primary, ColorTokens.primary);
      expect(themeData.brightness, Brightness.light);
    });

    testWidgets('memindahkan antar menu utama',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWith(
              (ref) => AppConfig(
                apiBaseUrl: 'https://api.example.test',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 30),
              ),
            ),
            apiClientProvider.overrideWith(
              (ref) => throw UnimplementedError(
                'apiClientProvider tidak boleh dipakai dalam tes ini.',
              ),
            ),
          ],
          child: const ElfanApp(),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text(AppDestination.home.label), findsWidgets);
      expect(find.text(AppDestination.devices.label), findsWidgets);

      await tester.tap(find.text(AppDestination.devices.label));
      await tester.pumpAndSettle();
      expect(find.text(AppDestination.devices.label), findsWidgets);

      await tester.tap(find.text(AppDestination.voice.label));
      await tester.pumpAndSettle();
      expect(find.text(AppDestination.voice.label), findsWidgets);

      await tester.tap(find.text(AppDestination.cctv.label));
      await tester.pumpAndSettle();
      expect(find.text(AppDestination.cctv.label), findsWidgets);

      await tester.tap(find.text(AppDestination.energy.label));
      await tester.pumpAndSettle();
      expect(find.text(AppDestination.energy.label), findsWidgets);
    });
  });
}
