# Sanad monorepo

This repository hosts multiple deliverables for the Sanad Cemetery / Ministry ecosystem.

## Layout

| Path | Description |
|------|-------------|
| **`/`** (repo root) | **Flutter mobile app** (`lib/`, `android/`, `ios/`, `pubspec.yaml`) — visitor app, roles (demo), localization, requests hub, location hub. |
| **`apps/dashboard/`** | Web dashboard (Vite + TypeScript) for future admin / analytics. |
| **`packages/`** | Reserved for shared Dart/TS libraries (models, API clients). Add packages here as needed. |

## Product directions (roadmap)

- **Ministry of Municipality**: official statistics feed, audit logging, super-admin vs admin (UI hooks + demo roles).
- **Ministry of Awqaf**: elevated role, high-priority submissions (flag on tickets when wired to backend).
- **Municipality crew**: operational access (role flag for future portal).
- **Accessibility portal**: text size, bolder labels, simplified layout (larger tap targets); optional birth year remains in profile settings only.

## Development

```bash
# Mobile
flutter pub get
flutter run

# Dashboard (when used)
cd apps/dashboard && npm install && npm run dev
```
