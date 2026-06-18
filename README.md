# MediStock Mobile

Flutter Android app for **MediStock** — a medicine inventory management system
for clinics, pharmacies, and small hospitals. Part of the MediStock monorepo
(`medistock-docs`, `medistock-api`, `medistock_mobile`).

This client targets the NestJS REST API in `medistock-api/` and ships a
parallel **in-memory dummy data** layer for offline development and demos.

---

## 12 MVP Features

| # | Feature | Notes |
|---|---|---|
| F1  | Auth (login / logout)     | JWT in `flutter_secure_storage` |
| F2  | Dashboard                 | total medicines, total stock, low-stock count, expired count, total value, recent movements |
| F3  | Categories CRUD           | admin only |
| F4  | Suppliers CRUD            | paginated list |
| F5  | Medicines CRUD + filter   | by category, supplier, low stock, expired, search |
| F6  | Stock-in                  | increments `currentStock`, records movement |
| F7  | Stock-out                 | decrements stock, rejects insufficient |
| F8  | Stock movements history   | filter by type, date range, medicine |
| F9  | Low-stock alert           | `stock < minimumStock` |
| F10 | Expired-soon alert        | `expiredDate < now()` |
| F11 | Medicine search           | partial match on name |
| F12 | Profile (me + logout)     | self-service |

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.x` (stable channel)
- Android SDK & emulator/device for `flutter run`
- Backend (`medistock-api`) running locally on port 3000 — see its README

### Install
```sh
flutter pub get
```

### Run (dev, real backend — default)
The default mode talks to the NestJS backend in `medistock-api/`. Make sure
the API is running locally on port 3000 (see its README) before launching
the app.

```sh
# Android emulator (10.0.2.2 is the loopback alias to the host)
flutter run
# — uses API_BASE=http://10.0.2.2:3000/api/v1 by default —

# Physical device on the same Wi-Fi: pass your host LAN IP
flutter run --dart-define=API_BASE=http://192.168.1.10:3000/api/v1
```

Login with the credentials seeded by the backend (default: `admin` / `admin123`,
see `medistock-api` README).

### Run (offline demo, no backend)
For UI demos without a running API, switch to the in-memory dummy layer
(uses `lib/features/<x>/data/repositories/<x>_repository_dummy.dart`):

```sh
flutter run --dart-define=USE_DUMMY=true
```

> **Note:** The `USE_DUMMY` flag defaults to `false` since this app is
> API-first. The flag is only needed for offline demos.

### Build APK (release)
```sh
flutter build apk --release \
  --dart-define=USE_DUMMY=false \
  --dart-define=API_BASE=https://api.medistock.example/api/v1
```

---

## Environment Variables (compile-time)

| Flag                | Default                                  | Description |
|---------------------|------------------------------------------|-------------|
| `USE_DUMMY`         | `false`                                  | `true` = in-memory dummy repos (offline demo). `false` = real API via Dio (default). |
| `API_BASE`          | `10.0.2.2:3000` on Android, `127.0.0.1:3000` on desktop | Base URL prepended to every endpoint. Always wins when set explicitly. |

Without an explicit `API_BASE`, the app picks the right loopback alias for
the platform at runtime (Android emulator: `10.0.2.2`; Linux/Windows/macOS
desktop: `127.0.0.1`; web: `localhost`). For a physical Android device on
the same Wi-Fi, pass `--dart-define=API_BASE=http://<host-LAN-IP>:3000/api/v1`.

Defined in `lib/core/config/dummy_flag.dart` and `lib/core/network/api_client.dart`.

---

## Testing

```sh
# Static analysis
flutter analyze

# Unit + widget tests (default: integration suite self-skips)
flutter test

# End-to-end smoke vs a running API (login -> 12 fitur)
flutter test test/integration/ \
  --dart-define=API_BASE=http://localhost:3000/api/v1
```

Test layers:
- `test/features/<x>/models/` — JSON round-trip per model
- `test/features/<x>/data/` — dummy repo filter/search/pagination
- `test/features/<x>/views/` — widget renders with injected dummy repo
- `test/integration/` — real API repository smoke (9 tests covering 12 features)

---

## Project Structure

```
lib/
├── main.dart                  # entry: init storage, GetMaterialApp
├── app/
│   ├── app.dart               # GetMaterialApp + theme + initial route
│   ├── routes/                # AppRoutes + AppPages
│   └── bindings/              # InitialBinding (ApiClient, SecureStorage, Auth)
├── core/
│   ├── config/                # kUseDummyData flag
│   ├── constants/             # API path constants
│   ├── network/               # Dio ApiClient, JWT interceptor, ApiException
│   ├── storage/               # SecureStorageService + AuthSession
│   ├── theme/                 # AppTheme, AppColors
│   ├── utils/                 # date + currency formatters
│   └── widgets/               # LoadingOverlay, EmptyState, ErrorView
└── features/
    ├── auth/                  # F1
    ├── dashboard/             # F2
    ├── categories/            # F3
    ├── suppliers/             # F4
    ├── medicines/             # F5, F9, F10, F11
    ├── stock_movements/       # F6, F7, F8
    ├── alerts/                # F9, F10 (aggregated)
    └── profile/               # F12
```

Each feature follows the same shape:
```
features/<x>/
├── controllers/<x>_controller.dart
├── views/<x>_view.dart
├── bindings/<x>_binding.dart   # Get.lazyPut<Repo>(kUseDummyData ? Dummy : Api)
├── models/<x>.dart
└── data/
    ├── dummy/<x>_dummy_data.dart
    └── repositories/
        ├── <x>_repository.dart          # abstract
        ├── <x>_repository_dummy.dart    # in-memory
        └── <x>_repository_api.dart      # Dio-backed
```

---

## Branch & Commit Convention

- Branch: `feat/mobile-<unit>` or `feat/integration-phase-2-...`
- Commit: Conventional Commits with scope `mobile`
  - `feat(mobile): ...`
  - `fix(mobile): ...`
  - `test(mobile): ...`
  - `docs(mobile): ...`
  - `chore(mobile): ...`

Pre-commit gate: `flutter analyze` + `flutter test` both green.

---

## API Contract

The canonical REST contract lives in `medistock-docs/docs/`. A working copy
is bundled in `docs/contracts/` (per poly-repo sync rules) containing:
`AGENTS.md`, `api_contract.md`, `prd.md`, `database_schema_mvp.md`,
`folder_structure.md`. When the contract changes upstream, copy the updated
file(s) into `docs/contracts/` and commit as
`docs(mobile): sync contracts from medistock-docs`.

---

## License

Internal project. All rights reserved.
