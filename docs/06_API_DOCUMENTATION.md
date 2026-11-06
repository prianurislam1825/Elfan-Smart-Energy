# API Documentation and Audit Register

Dokumen ini bukan daftar endpoint final. Verifikasi dari FastAPI source/Swagger.

## Backend diketahui
FastAPI di Raspberry Pi; LAN base URL `http://192.168.20.137:8000`; Swagger `http://192.168.20.137:8000/docs`; source `~/cv-engine`. IP ini hanya untuk jaringan LAN.

## Endpoint yang pernah diketahui
| Method | Path | Catatan |
|---|---|---|
| GET | `/api/v1/monitoring/status` | Pernah digunakan; audit schema/auth |
| POST | `/api/v1/monitoring/check` | Pernah digunakan; audit body/response |
| GET | `/api/v1/devices` | Pernah disebut tersedia; audit schema/auth |

Jangan mengarang endpoint auth, location, voice, CCTV, energy, productivity, history.

## Audit checklist
Catat method/path, auth, permission/tenant scope, parameters, request, response, error codes, pagination, timeout, idempotency, status, dan file backend sumber.

## Domain yang diaudit
Auth/session; user/profile; organization/membership; property/building/floor/room; device list/detail/control; monitoring; voice; CCTV; energy; productivity; notifications; activity history.

## Template inventaris
| Domain | Method | Path | Auth | Request/Response | Status |
|---|---|---|---|---|---|
| Auth | TBD | TBD | TBD | TBD | Audit |
| Devices | TBD | TBD | TBD | TBD | Audit |
| Locations | TBD | TBD | TBD | TBD | Audit |
| Voice | TBD | TBD | TBD | TBD | Audit |
| CCTV | TBD | TBD | TBD | TBD | Audit |
| Energy | TBD | TBD | TBD | TBD | Audit |
| Productivity | TBD | TBD | TBD | TBD | Audit |

## Integrasi mobile
Dio melalui service/repository; base URL environment; typed models; error mapping; tidak ada secret di aplikasi; jangan retry kontrol secara buta; backend memvalidasi tenant. Jangan tempel `.env` atau credential ke prompt. Contoh dokumentasi harus memakai data dummy yang jelas.
