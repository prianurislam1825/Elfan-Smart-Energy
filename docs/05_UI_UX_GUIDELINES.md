# UI/UX Guidelines

## Arah visual
Minimalis, modern, profesional, mobile-first, mudah dipahami, tidak padat.

## Warna baseline
| Token | Hex |
|---|---|
| Primary | `#2563EB` |
| Background | `#F7F8FA` |
| Surface | `#FFFFFF` |
| Text Primary | `#172033` |
| Text Secondary | `#7B8494` |

## Navigasi
Bottom navigation: Home, Perangkat, Voice, CCTV, Energi. Productivity, History, Profile, Settings, dan Organization Management berada di menu pendukung.

## Komponen dan state
Cards, status chips, tombol berlabel jelas, konfirmasi aksi berisiko, skeleton/progress, empty state, error state. Setiap layar data mempertimbangkan loading, success, empty, error, dan stale/partial.

## Status perangkat
Online, Offline, Unknown, Unsupported, Loading, Command pending, Command failed. Unsupported tidak sama dengan offline.

## Voice
Tombol PTT mudah dijangkau; indikator rekaman/durasi; stop/cancel; transkrip bila ada; processing state; respons teks/audio. Jangan merekam background.

## CCTV
Indikator koneksi, placeholder, error/reconnect, multi-camera usable di layar kecil, tanpa penyimpanan snapshot/rekaman tanpa kebutuhan dan izin.

## Accessibility
Teks terbaca, target sentuh memadai, kontras baik, tidak overflow, label semantik, uji beberapa ukuran layar.
