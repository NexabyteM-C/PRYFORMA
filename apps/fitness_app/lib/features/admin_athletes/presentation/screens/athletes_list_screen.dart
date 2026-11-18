import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/admin_athletes_provider.dart';
import 'athlete_edit_screen.dart';

const _roleLabels = <String, String>{
  'visitor': 'Visitante',
  'athlete': 'Atleta',
  'coach': 'Coach',
  'box_admin': 'Admin de box',
  'box_owner': 'Propietario',
  'superadmin': 'Superadmin',
};

String roleLabel(String role) => _roleLabels[role] ?? role;

class AthletesListScreen extends ConsumerStatefulWidget {
  const AthletesListScreen({super.key});

  @override
  ConsumerState<AthletesListScreen> createState() => _AthletesListScreenState();
}

class _AthletesListScreenState extends ConsumerState<AthletesListScreen> {
  String _search = '';

  Future<void> _changeRole(OrganizationMember m) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Cambiar rol'),
        children: [
          for (final entry in _roleLabels.entries)
            if (entry.key != 'superadmin')
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == m.role
                    ? Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(dialogContext).pop(entry.key),
              ),
        ],
      ),
    );
    if (selected == null || selected == m.role) return;
    try {
      await ref
          .read(organizationDatasourceProvider)
          .updateMemberRole(m.id, selected);
      ref.invalidate(adminAthletesProvider);
      _snack('Rol actualizado a ${roleLabel(selected)}');
    } catch (e) {
      _snack('Error: $e', isError: true);
    }
  }

  Future<void> _editAthlete(OrganizationMember m) async {
    final org = ref.read(resolvedAdminOrgProvider);
    if (org == null) {
      _snack('Sin box seleccionado', isError: true);
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AthleteEditScreen(member: m, organizationId: org.id),
      ),
    );
    if (saved == true) ref.invalidate(adminAthletesProvider);
  }

  Future<void> _removeMember(OrganizationMember m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar atleta'),
        content: Text(
          '¿Quitar a ${m.user?.displayName ?? 'este miembro'} del box?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(organizationDatasourceProvider).removeMember(m.id);
      ref.invalidate(adminAthletesProvider);
      _snack('Miembro eliminado');
    } catch (e) {
      _snack('Error: $e', isError: true);
    }
  }

  Future<void> _invite() async {
    final org = ref.read(resolvedAdminOrgProvider);
    if (org == null) {
      _snack('Sin box seleccionado', isError: true);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _InviteDialog(orgId: org.id),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final athletes = ref.watch(adminAthletesProvider);
    final org = ref.watch(resolvedAdminOrgProvider);
    final narrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: narrow
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _invite,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Invitar'),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.fromLTRB(narrow ? 16 : 28, 24, narrow ? 16 : 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atletas',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: narrow ? 24 : 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.56,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (org != null)
                        Text(
                          org.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                // On wider screens the primary action sits in the header; on
                // phones it moves to the FloatingActionButton above.
                if (!narrow)
                  ElevatedButton.icon(
                    onPressed: _invite,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('Invitar atleta'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Buscar atleta...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: athletes.when(
                data: (list) {
                  final filtered = _search.isEmpty
                      ? list
                      : list.where((m) {
                          final name = (m.user?.displayName ?? '')
                              .toLowerCase();
                          final email = (m.user?.email ?? '').toLowerCase();
                          return name.contains(_search) ||
                              email.contains(_search);
                        }).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        'Sin atletas',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(adminAthletesProvider),
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _MemberRow(
                        member: filtered[i],
                        compact: narrow,
                        onEdit: () => _editAthlete(filtered[i]),
                        onChangeRole: () => _changeRole(filtered[i]),
                        onRemove: () => _removeMember(filtered[i]),
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.onEdit,
    required this.onChangeRole,
    required this.onRemove,
    this.compact = false,
  });
  final OrganizationMember member;
  final VoidCallback onEdit;
  final VoidCallback onChangeRole;
  final VoidCallback onRemove;

  /// Phone layout: hide the join date to keep the row from overflowing.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final name = member.user?.displayName ?? 'Sin nombre';
    final email = member.user?.email ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (!compact && member.joinedAt != null) ...[
            Text(
              DateFormat('d MMM y', 'es').format(member.joinedAt!),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
          ],
          _RoleBadge(role: member.role),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
            ),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'role') onChangeRole();
              if (v == 'remove') onRemove();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text('Editar datos')),
              PopupMenuItem(value: 'role', child: Text('Cambiar rol')),
              PopupMenuItem(
                value: 'remove',
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isStaff =
        role == 'coach' ||
        role == 'box_admin' ||
        role == 'box_owner' ||
        role == 'superadmin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isStaff ? AppColors.primaryLight : AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        roleLabel(role),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isStaff ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _InviteDialog extends ConsumerStatefulWidget {
  const _InviteDialog({required this.orgId});
  final String orgId;

  @override
  ConsumerState<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<_InviteDialog> {
  String _role = 'athlete';
  String? _token;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    try {
      final token = await ref
          .read(organizationDatasourceProvider)
          .createInvitation(widget.orgId, _role);
      setState(() => _token = token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Invitar atleta',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_token == null) ...[
              Text(
                'Rol de la invitación',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in const ['athlete', 'coach', 'box_admin'])
                    ChoiceChip(
                      label: Text(roleLabel(r)),
                      selected: _role == r,
                      onSelected: (_) => setState(() => _role = r),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _generate,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Generar código'),
                ),
              ),
            ] else
              _InviteResult(token: _token!),
          ],
        ),
      ),
    );
  }
}

class _InviteResult extends StatelessWidget {
  const _InviteResult({required this.token});
  final String token;

  @override
  Widget build(BuildContext context) {
    final link = 'fitnessapp://join/$token';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Comparte este código con el atleta:',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        // QR placeholder (no qr package available).
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 90,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  token,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: AppColors.primary),
                tooltip: 'Copiar código',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Código copiado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.link_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SelectableText(
                link,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enlace copiado'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Listo'),
        ),
      ],
    );
  }
}
