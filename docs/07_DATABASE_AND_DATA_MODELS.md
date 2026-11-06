# Database and Data Models — Conceptual

**Status:** konseptual, bukan schema final dan bukan instruksi migrasi backend.

## Prinsip
Tenant isolation, ownership eksplisit, lokasi dinamis, resource terkait lokasi, timestamp konsisten, backend sebagai sumber kebenaran, model mobile mengikuti API aktual.

## Entitas konseptual
- **User:** id, display name, identifier sesuai auth, status, timestamps.
- **Organization/Tenant:** id, name, status, configuration.
- **Membership:** user_id, tenant_id, role/permission assignment, status.
- **Personal Workspace:** scope milik pengguna; dapat berupa personal tenant atau ownership scope (TBD).
- **Property/Building:** id, owner/tenant scope, name, metadata.
- **Floor:** id, property_id, name/number; opsional.
- **Room/Area:** id, parent location, name, metadata.
- **Device:** id, owner/tenant scope, location, name, type, provider, capabilities, status metadata.
- **Camera:** id, owner/tenant scope, location, name, stream reference; credential tidak diekspos.
- **Energy Reading:** source, metric, value, unit, timestamp, quality.
- **Productivity Report:** user, location, period, completed_work, obstacles, next_plan.
- **Notification:** recipient/scope, type, content, timestamps.
- **Activity Event:** actor, tenant scope, action, target, outcome, timestamp.

## Relasi
Tenant memiliki membership, property, dan resource. Property memiliki floor/room. Room dapat memiliki device/camera. User dapat memiliki membership beberapa tenant jika diizinkan. Personal workspace memiliki ownership/share scope eksplisit.

## Aturan
Jangan mengarang field backend; jangan hardcode inventory Alwustho; jangan menganggap satu status mencakup semua; null bukan nol; timezone konsisten; jangan simpan secret di local storage.

## Open decisions
Database engine, schema tenant, soft delete, retention, audit, offline sync, personal workspace, migration strategy.
