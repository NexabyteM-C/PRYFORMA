// Supabase Edge Function: admin-update-athlete
//
// Lets a box admin / owner (or a superadmin) update another athlete's account:
// display name, email and/or password. These operations need the Supabase
// Admin API (service_role), which must NEVER live in the Flutter client — so
// they run here, server-side, behind a strict role check.
//
// Request (POST, JSON):
//   {
//     "organizationId": "<uuid>",   // the box the admin manages
//     "targetUserId":   "<uuid>",   // the athlete being edited
//     "displayName":    "..."?,     // optional
//     "email":          "..."?,     // optional
//     "password":       "..."?      // optional (min 8 chars)
//   }
//
// Auth: the caller's Supabase JWT must be sent as `Authorization: Bearer <jwt>`.
//
// Deploy:
//   supabase functions deploy admin-update-athlete
//   (SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are injected automatically.)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const ADMIN_ROLES = ["box_admin", "box_owner", "superadmin"];

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ ok: false, error: "Método no permitido" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !serviceKey || !anonKey) {
    return json({ ok: false, error: "Función mal configurada" }, 500);
  }

  // 1) Identify the caller from their JWT.
  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "").trim();
  if (!token) {
    return json({ ok: false, error: "No autenticado" }, 401);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: callerData, error: callerErr } = await admin.auth.getUser(
    token,
  );
  if (callerErr || !callerData?.user) {
    return json({ ok: false, error: "Sesión inválida" }, 401);
  }
  const callerId = callerData.user.id;

  // 2) Parse and validate the body.
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ ok: false, error: "JSON inválido" }, 400);
  }

  const organizationId = String(body.organizationId ?? "");
  const targetUserId = String(body.targetUserId ?? "");
  const displayName =
    body.displayName == null ? null : String(body.displayName).trim();
  const email = body.email == null ? null : String(body.email).trim();
  const password = body.password == null ? null : String(body.password);

  if (!organizationId || !targetUserId) {
    return json(
      { ok: false, error: "Faltan organizationId o targetUserId" },
      400,
    );
  }
  if (displayName === null && email === null && password === null) {
    return json({ ok: false, error: "No hay cambios que aplicar" }, 400);
  }
  if (displayName !== null && displayName.length < 2) {
    return json({ ok: false, error: "El nombre es demasiado corto" }, 400);
  }
  if (email !== null && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    return json({ ok: false, error: "Correo inválido" }, 400);
  }
  if (password !== null && password.length < 8) {
    return json(
      { ok: false, error: "La contraseña debe tener al menos 8 caracteres" },
      400,
    );
  }

  // 3) Authorize: the caller must be an admin/owner of this org, or superadmin.
  const { data: callerMemberships, error: cmErr } = await admin
    .from("organization_members")
    .select("role, organization_id, status")
    .eq("user_id", callerId);
  if (cmErr) {
    return json({ ok: false, error: "No se pudo verificar permisos" }, 500);
  }
  const memberships = callerMemberships ?? [];
  const isSuperadmin = memberships.some((m) => m.role === "superadmin");
  const managesOrg = memberships.some(
    (m) =>
      m.organization_id === organizationId &&
      m.status === "active" &&
      ADMIN_ROLES.includes(m.role),
  );
  if (!isSuperadmin && !managesOrg) {
    return json(
      { ok: false, error: "No tienes permisos sobre este box" },
      403,
    );
  }

  // 4) The target must belong to the same org (superadmin may edit anyone).
  if (!isSuperadmin) {
    const { data: targetMember, error: tmErr } = await admin
      .from("organization_members")
      .select("id")
      .eq("user_id", targetUserId)
      .eq("organization_id", organizationId)
      .maybeSingle();
    if (tmErr) {
      return json({ ok: false, error: "No se pudo verificar al atleta" }, 500);
    }
    if (!targetMember) {
      return json(
        { ok: false, error: "El atleta no pertenece a este box" },
        403,
      );
    }
  }

  // 5) Apply the changes.
  // 5a) Auth-side (email / password) via the Admin API.
  const authAttrs: Record<string, unknown> = {};
  if (email !== null) {
    authAttrs.email = email;
    authAttrs.email_confirm = true; // admin-set emails are trusted
  }
  if (password !== null) authAttrs.password = password;
  if (Object.keys(authAttrs).length > 0) {
    const { error: authErr } = await admin.auth.admin.updateUserById(
      targetUserId,
      authAttrs,
    );
    if (authErr) {
      return json(
        { ok: false, error: `No se pudo actualizar la cuenta: ${authErr.message}` },
        400,
      );
    }
  }

  // 5b) Profile mirror (display_name and the email copy kept in `profiles`).
  const profilePatch: Record<string, unknown> = {};
  if (displayName !== null) profilePatch.display_name = displayName;
  if (email !== null) profilePatch.email = email;
  if (Object.keys(profilePatch).length > 0) {
    const { error: profErr } = await admin
      .from("profiles")
      .update(profilePatch)
      .eq("id", targetUserId);
    if (profErr) {
      return json(
        { ok: false, error: `No se pudo actualizar el perfil: ${profErr.message}` },
        400,
      );
    }
  }

  return json({ ok: true });
});
