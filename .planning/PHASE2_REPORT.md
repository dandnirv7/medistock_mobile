# Fase 2 — Mobile Integration Report

Generated: 2026-06-16T20:57:10
Repo: medistock_mobile
Branch: `feat/integration-phase-2-wire-api` (2 commit, NOT pushed — user pushes)

## 12-Fitur Smoke Result (vs API live @ localhost:3000)

| # | Feature | Endpoint utama | Status | Catatan |
|---|---|---|---|---|
| F1 | Auth login | `POST /auth/login` | OK | response pakai field `username`, bukan `email` |
| F2 | Dashboard | `GET /dashboard` | OK | `totalValue` hadir di payload (sum purchasePrice * currentStock) |
| F3 | Categories CRUD | `GET/POST/PUT/DELETE /categories` | OK | round-trip create+delete via API repo |
| F4 | Suppliers list | `GET /suppliers?page&limit` | OK | paginated meta (`total`, `page`, `limit`) konsisten |
| F5 | Medicines CRUD | `GET/POST/GET/:id/DELETE /medicines` | OK | `purchasePrice` datang sebagai string, fix dengan `_toDouble` |
| F6 | Stock movements list & stock-in | `GET /stock-movements`, `POST /stock-movements/in` | OK | filter `type=IN` works |
| F7 | Stock-out (insufficient) | `POST /stock-movements/out` | OK | backend reject dengan 4xx sesuai expected |
| F8 | Stock movements filter | `GET /stock-movements?type&startDate&endDate` | OK | |
| F9 | Low-stock alert | `GET /medicines?lowStock=true` | OK | |
| F10 | Expired alert | `GET /medicines?expiredStatus=expired` | OK | |
| F11 | Search filter | `GET /medicines?search=...` | OK | partial match di name |
| F12 | Profile me + logout | `GET /auth/me`, `POST /auth/logout` | OK | session cleared dari secure storage |

## Mismatch yang ditemukan & di-handle

1. **Login field name**: API contract menyebut `email` di PRD lama, tapi backend expect `username`. Integration test pakai `username: 'admin'`.
2. **Price serialization**: backend serialize `purchasePrice`/`sellingPrice` sebagai string `"250.00"` (Prisma Decimal -> JSON string), bukan number. Patch: `MedicineModel._toDouble()` accept num, String, atau null.
3. **Android cleartext**: `usesCleartextTraffic="true"` di-aktifkan supaya dev build bisa hit `http://10.0.2.2:3000`.

## Branch & Commit (mobile)

```
caa182b test(mobile): add API repository smoke test covering 12 MVP features
bd9427b fix(mobile): robust price parsing & enable cleartext for local API
7ad71c5 feat(profile): refactor profile view and controller for improved user experience  (main HEAD)
```

## Test gate

- `flutter analyze` → 0 issues
- `flutter test` (default) → 32 pass + 9 skip
- `flutter test test/integration/ --dart-define=API_BASE=http://localhost:3000/api/v1` → 9/9 pass
- API `pnpm run build` & `pnpm test` → hijau (di-handle agent API)

## Sandbox notes

- Root `.planning/ORCHESTRATION.md` di-mount readonly oleh sandbox (lihat ORCHESTRATION §9). Update checklist via file ini di sub-repo mobile sebagai gantinya. User/koordinator boleh propagate ke root saat merge.
- Branch `feat/integration-phase-2-wire-api` di-create & commit, TIDAK push (per AGENTS.md: push oleh user/koordinator).
- `medistock-api`: totalValue sudah on main oleh agent API sebelumnya, working tree clean untuk dashboard; TIDAK perlu commit baru di sana.
