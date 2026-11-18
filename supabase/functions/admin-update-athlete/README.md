# admin-update-athlete

Edge Function that lets a **box admin / owner** (or a **superadmin**) update
another athlete's account — display name, email and/or password — using the
Supabase **service_role** key, which must never ship inside the Flutter client.

## What it does

1. Identifies the caller from their `Authorization: Bearer <jwt>` token.
2. Authorizes: the caller must be `box_admin` / `box_owner` of the given
   `organizationId` (and the target must belong to that org), **or** a
   `superadmin` (who may edit anyone).
3. Applies the changes:
   - `email` / `password` → Supabase Admin API (`auth.admin.updateUserById`).
   - `display_name` / `email` mirror → `profiles` table.

## Deploy

Requires the [Supabase CLI](https://supabase.com/docs/guides/cli) logged in and
linked to the project (`supabase link --project-ref sxrnykzboumtpqcokkxf`).

```bash
# from the repo root
supabase functions deploy admin-update-athlete
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are injected
automatically by the platform — you do **not** set them manually.

The function keeps `verify_jwt = true` (default), so Supabase rejects
unauthenticated calls before our code runs; the client call
(`supabase.functions.invoke`) attaches the signed-in user's token automatically.

## Client

Called from `AdminAthleteEditDatasource.updateAthlete(...)`
(`apps/fitness_app/lib/features/admin_athletes/data/admin_athlete_edit_datasource.dart`),
reached from the admin **Atletas** list → row menu → **Editar datos**.
