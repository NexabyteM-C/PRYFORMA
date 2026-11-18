# PRYFORMA

Plataforma de fitness y cross-training (Android, iOS, Web) que conecta el
rendimiento personal del atleta con la operación del box: programación de
clases, membresías, pagos y contabilidad.

> **Principio:** el atleta es dueño de su historial de entrenamiento; las
> organizaciones (boxes) gestionan la experiencia y la comunidad a la que el
> atleta decide unirse.

---

## Stack

| Capa | Tecnología |
|---|---|
| Frontend | **Flutter + Dart** (un solo código para Android, iOS y Web) |
| Estado | `flutter_riverpod` |
| Navegación | `go_router` |
| Modelos | `freezed` + `json_serializable` |
| Backend | **Supabase** (Auth + PostgREST + PostgreSQL) |
| Funciones server | Supabase **Edge Functions** (Deno/TypeScript) |
| Gráficas | `fl_chart` |

## Estructura

```
PRYFORMA/
├── apps/fitness_app/        # App Flutter (atleta + admin en un solo binario)
│   └── lib/
│       ├── app/             # Entry, router (GoRouter), tema (claro/oscuro)
│       ├── core/            # Config, networking, almacenamiento, utils
│       └── features/        # Módulos por funcionalidad (data/domain/presentation)
├── packages/
│   ├── design_system/       # Tokens de color/tipografía + componentes (FitColors…)
│   └── domain_models/        # Entidades Freezed compartidas
├── supabase/
│   ├── schema.sql           # Esquema de la base de datos
│   └── functions/           # Edge Functions (p.ej. admin-update-athlete)
├── render.yaml              # Blueprint de despliegue web en Render
└── render-build.sh          # Script de build web para Render
```

## Funcionalidades principales

- **Atleta:** inicio con próxima clase, entrenar, clases (inscripción + player
  guiado con reloj), progreso y RM, objetivos por movimiento, medidas
  antropométricas, comunicados, multi-box.
- **Admin / box:** programación de clases por bloques (con esquema por series
  Sets·Reps·%), comunicados (crear/editar/eliminar), **Atletas y socios**
  (gestión, membresías, planes, pagos) y **Resultados** (dashboard contable
  mes a mes con filtros, solo admin/propietario).
- **Tema claro/oscuro** conmutable (oscuro por defecto), persistido en el
  dispositivo.

---

## Desarrollo local

Requisitos: Flutter (canal stable) y Dart.

```bash
# desde la raíz del repo
flutter pub get

# Web (usa los valores de Supabase por defecto de environment.dart)
cd apps/fitness_app
flutter run -d chrome

# o especificando el backend explícitamente:
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxxxx
```

Comandos útiles (desde `apps/fitness_app/`):

```bash
flutter analyze          # Lint
flutter test             # Tests
flutter build web --release   # Build web → build/web
flutter build apk --release   # APK → build/app/outputs/flutter-apk/app-release.apk

# Regenerar modelos freezed/json (los generados están commiteados):
dart run build_runner build --delete-conflicting-outputs
```

> El **anon key** de Supabase es público (rol `anon`) y puede ir en el cliente.
> El `service_role` **nunca** va en el cliente: vive solo en las Edge Functions.

---

## Despliegue de la etapa de pruebas en Render

La app web se publica como **Static Site** en [Render](https://render.com).

1. En Render: **New +** → **Blueprint** y conecta este repositorio
   (`NexabyteM-C/PRYFORMA`). Render lee `render.yaml` y crea el sitio
   `pryforma-test`.
2. Build: ejecuta `render-build.sh`, que instala Flutter, hace `pub get` y
   `flutter build web --release`. Publica `apps/fitness_app/build/web`.
3. Variables (ya vienen por defecto en `render.yaml`, se pueden sobreescribir en
   el panel): `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
4. El `routes` con *rewrite* a `/index.html` permite que `go_router` maneje las
   rutas (SPA).

> Alternativa manual (sin blueprint): Static Site → Build Command
> `bash render-build.sh`, Publish Directory `apps/fitness_app/build/web`.

### Edge Functions (Supabase)

Algunas acciones de admin (editar correo/contraseña de un atleta) requieren el
`service_role` y corren en una Edge Function, **no** en el cliente:

```bash
supabase functions deploy admin-update-athlete
```

(`SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SUPABASE_SERVICE_ROLE_KEY` los inyecta
Supabase automáticamente.)

---

## Notas de la etapa de pruebas

- Backend de pruebas: proyecto Supabase `sxrnykzboumtpqcokkxf`.
- Moneda COP (es_CO) en la gestión de socios/pagos.
- Esta es una etapa de **pruebas**; no usar datos reales de pacientes/empleados.
