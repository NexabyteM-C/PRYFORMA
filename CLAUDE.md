# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cross-platform fitness and cross-training platform (Android, iOS, Web). Connects athletes' personal performance tracking with gym/box operations, class programming, and multi-organization membership.

**Core principle:** The athlete owns their training history; organizations manage the training experience and community the athlete chooses to join.

**Specification document:** `Especificación funcional y técnica — Plataforma Fitness & Cross-Training.md` contains the full requirements (RF-001 through RF-027), data model, screen definitions, and business rules.

**Design reference:** Artifact with 5 key screens defining the visual system — see canvas.json for layout.

## Tech Stack

- **Frontend:** Flutter + Dart (single codebase for Android, iOS, Web)
- **Backend (current):** Supabase (Auth + PostgREST + PostgreSQL)
- **Backend (future migration):** Dart server (`shelf` + `shelf_router`) on VPS with custom JWT — server code is in `server/`, ready for migration
- **Database:** PostgreSQL (via Supabase, migrating to VPS later)
- **Auth:** Supabase Auth (email/password, session management)
- **Notifications:** Firebase Cloud Messaging (FCM) + APNs

### Key Dependencies

| Layer | Purpose | Package |
|---|---|---|
| Flutter | Backend/Auth | `supabase_flutter` |
| Flutter | State management | `flutter_riverpod` |
| Flutter | Navigation | `go_router` |
| Flutter | Immutable models | `freezed` + `json_serializable` |
| Flutter | Local DB (offline) | `drift` |
| Flutter | Charts | `fl_chart` |
| Flutter | Push notifications | `firebase_messaging` |
| Flutter | Error tracking | `sentry_flutter` |
| Flutter | Secure storage | `flutter_secure_storage` |
| Server (legacy) | HTTP framework | `shelf` + `shelf_router` |
| Server (legacy) | PostgreSQL | `postgres` (v3) |
| Server (legacy) | JWT | `dart_jsonwebtoken` |
| Server (legacy) | Password hashing | `dbcrypt` |

## Build & Dev Commands

```bash
# --- Flutter App (from apps/fitness_app/) ---
# Requires Supabase URL and anon key via dart-define:
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
flutter run                          # Run on default device (uses defaults from environment.dart)
flutter run -d chrome                # Run on web (uses defaults from environment.dart)
flutter test                         # Run all tests
flutter test test/features/auth/     # Run tests for one feature
flutter test --coverage              # Tests with coverage
flutter analyze                      # Lint
dart format .                        # Format

# Generate freezed/json_serializable models (from apps/fitness_app/ or packages/domain_models/)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs

# --- Server (from server/) ---
dart run bin/server.dart             # Start API server
dart run bin/migrate.dart            # Apply SQL migrations
dart test                            # Run server tests

# --- Workspace (from root) ---
# Flutter workspace resolves all packages via pubspec.yaml workspace: field
# Server is NOT part of the Flutter workspace (separate Dart project)
```

## Project Structure

Monorepo with feature-first architecture. One Flutter app serves both athlete (mobile bottom nav) and admin (web sidebar).

```
fitness_platform/
├── apps/fitness_app/lib/
│   ├── app/              # App entry, router (GoRouter), theme
│   ├── core/             # Config, errors, networking, local storage, utils
│   ├── features/         # Feature modules (see pattern below)
│   └── shared/           # Cross-feature widgets and extensions
├── packages/
│   ├── design_system/    # UI tokens (colors, typography, spacing, radii) + components
│   └── domain_models/    # Freezed entities shared across features
├── server/
│   ├── bin/              # server.dart (entry), migrate.dart (CLI)
│   ├── lib/
│   │   ├── auth/         # JWT, bcrypt, auth middleware
│   │   ├── middleware/   # CORS, logging, rate limit, org scope
│   │   ├── routes/       # REST endpoint handlers by resource
│   │   ├── services/     # Business logic layer
│   │   ├── models/       # API response envelope, pagination
│   │   └── db/           # Connection pool, migration runner, queries/
│   └── sql/
│       ├── migrations/   # Numbered SQL files (001..037)
│       └── seed/         # Exercise catalog, dev data
```

### Feature Module Pattern

Every feature follows a three-layer structure:

```
features/<name>/
├── data/
│   ├── datasources/    # Remote (API client) and local (Drift) data sources
│   ├── models/         # DTOs, serialization (freezed)
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business objects
│   ├── repositories/   # Abstract repository interfaces
│   └── usecases/       # Business logic operations
└── presentation/
    ├── providers/      # Riverpod providers/notifiers
    ├── screens/        # Full-page widgets
    └── widgets/        # Feature-specific widgets
```

Domain depends on nothing. Data implements domain interfaces. Presentation depends on domain (via Riverpod providers that call use cases).

## Architecture Decisions

### API Design

All endpoints under `/api/v1/`. Standard response envelope:
```json
{"ok": true, "data": {...}}
{"ok": false, "error": {"message": "...", "code": "..."}}
```

Auth via `Authorization: Bearer <jwt>` header. Public routes (register, login, health) bypass auth middleware.

Organization-scoped routes under `/api/v1/organizations/:orgId/...` — the `org_scope_middleware` verifies the caller has an active membership and attaches their role to the request context.

### Multi-Tenant Isolation

Every organization query must be scoped by `organization_id` and enforced at the API service layer (no RLS — using application-level authorization). Never rely on client-side permission checks alone.

### Class Programming: Three-Tier Model

The system distinguishes three concepts that must not be conflated:

1. **Program Template** (`program_templates`) — reusable workout blueprint, not tied to a date
2. **Class Program** (`class_programs`) — a specific day's programming, optionally derived from a template, with its own published version
3. **Class Session** (`class_sessions`) — a specific timeslot (e.g., 6 AM, 7 AM, 6 PM) all sharing the same program without duplication

### Publication State Machine

```
draft → scheduled → published → updated (new version)
                  → cancelled
draft → published (immediate)
scheduled → cancelled
```

Scheduled publications are processed server-side (Dart Isolate timer or pg_cron, never client-side timers). The publication transaction uses `SELECT ... FOR UPDATE SKIP LOCKED` for idempotent processing, with unique constraints per event/user/channel to prevent duplicate notifications.

### Athlete Data Ownership

- An athlete's workout sessions, personal records, and goals belong to the athlete's identity, not to any organization
- `workout_sessions.organization_id` is nullable — athletes can train independently
- When an athlete leaves a box, their personal records remain intact
- Organizations cannot delete or claim athlete personal data

### Offline-First (Workouts Only)

Workout sessions, sets, and results are stored locally (Drift) and synced when online. Each operation uses a unique client-generated `client_id` (UUID) to prevent duplicates on retry. Class publication, role changes, and payment operations require connectivity.

### RM/PR System

- All weights stored as `NUMERIC` in **kilograms** (canonical unit); convert to lb only for display based on user preference
- All durations stored as **integer milliseconds**
- Distinguish between: real marks, estimated marks, weighted results, and assisted results
- Personal records are derived indices — recalculate from history when a result is corrected, never treat PR entries as the sole source of truth

## Database Conventions

- UUID primary keys (`gen_random_uuid()`) on all tables
- `created_at`, `updated_at` audit columns on every table (auto-updated via trigger)
- All timestamps as `TIMESTAMPTZ`
- Weights as `NUMERIC(7,2)` in kg
- Durations as `INT` in milliseconds
- Unique constraint on `(organization_id, user_id)` in `organization_members`
- Publication timestamps interpreted in the box location's timezone (`organization_locations.timezone`)
- Notification deduplication via unique constraint on `(event_id, user_id, channel)`
- Parameterized queries only (`Sql.named()` with `@param` syntax) — never string interpolation in SQL

## Design System

Tokens extracted from the design artifact:

- **Colors:** Background `#F4F7FC`, Primary `#1E4FD8`, Dark `#0B2A6F`, Text `#0A1A3F`, Secondary text `#4B5A7A`, Border `#DDE5F2`
- **Typography:** Space Grotesk for headings (500-700, letter-spacing -0.02em), Inter for body (400-700)
- **Radii:** Cards 18px, Buttons 12px, Pills 18px, Inputs 10px
- **Components:** Located in `packages/design_system/lib/components/`
- **Layouts:** `AthleteShell` (bottom nav) and `AdminShell` (sidebar) in `packages/design_system/lib/layouts/`

## Navigation

**Athlete (mobile, bottom tabs):** Inicio → Entrenar → Clases → Progreso → Perfil

**Admin (web, sidebar):** Dashboard → Programación → Atletas → Comunicados → Resultados → Configuración

GoRouter uses `ShellRoute` for each paradigm. A `currentModeProvider` (Riverpod) tracks athlete vs admin mode. Router redirects unauthenticated users to `/auth/login`.

## Roles & Permissions

Six roles with escalating privileges: Visitante → Atleta → Coach → Admin de box → Propietario de box → Superadministrador.

Coach permissions (create/publish classes, publish announcements) are configurable per organization. Superadministrador does **not** have unrestricted access to athlete private data — exceptional support operations must be justified and audited.

## Environments

Three environments: `development`, `staging`, `production`. Each with its own PostgreSQL database. SQL migrations are versioned and applied sequentially via `dart run bin/migrate.dart`. Server config via `.env` file.
