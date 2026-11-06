# Testing Guidelines

## Quality gates
Jalankan dari root Flutter project:
```cmd
dart format .
flutter analyze
flutter test
```
Jika test suite belum tersedia, laporkan.

## Unit tests
Parsing model/null fields, repository mapping, Dio error mapping, state transitions, permission logic, timestamp/unit formatting.

## Widget tests
Loading/success/empty/error, navigation, confirmation dialog, device status, PTT states, responsive overflow.

## Integration tests
Auth/session, tenant context, device list/status/control, Voice, CCTV lifecycle, energy, productivity. Jangan kontrol perangkat fisik tanpa target uji dan persetujuan.

## Security tests
Cross-tenant ditolak backend; permission device/CCTV; token tidak masuk log; logout membersihkan session; invalid/expired token ditangani.

## Network tests
Server unreachable, timeout, network switch, malformed response, HTTP errors sesuai kontrak, retry aman.

## CCTV tests
Stream valid/unavailable, permission denied, background/foreground, player teardown, multi-camera resource usage.

## Audio tests
Permission grant/deny, start/stop/cancel, empty/long audio, upload timeout, TTS interruption, lifecycle/audio focus.

## Release checklist
Analyze bersih, test relevan lulus, Android build berhasil, no secrets, production URL bukan IP LAN dev, permissions benar, tenant isolation diuji, version/build number benar, known limitations dicatat.
