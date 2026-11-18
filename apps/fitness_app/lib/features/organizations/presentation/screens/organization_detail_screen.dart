import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/membership_provider.dart';
import '../providers/organization_provider.dart';

class OrganizationDetailScreen extends ConsumerWidget {
  const OrganizationDetailScreen({super.key, required this.orgId});
  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(organizationDetailProvider(orgId));
    final membersAsync = ref.watch(organizationMembersProvider(orgId));
    final memberships = ref.watch(myMembershipsProvider).valueOrNull ?? [];
    final myRole = memberships
        .where((m) => m.organizationId == orgId)
        .map((m) => m.role)
        .firstOrNull;
    final canEdit = myRole != null && roleRank(myRole) >= roleRank('box_owner');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (canEdit)
            orgAsync.maybeWhen(
              data: (org) => IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Editar box',
                onPressed: () => _showEditDialog(context, ref, org),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          final locations = org.locations ?? const [];
          final memberCount = membersAsync.valueOrNull?.length;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        org.name.isNotEmpty ? org.name[0] : '?',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    org.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    org.slug,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (org.description != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      org.description!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups_rounded,
                        value: memberCount?.toString() ?? '—',
                        label: 'Miembros',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.location_on_rounded,
                        value: '${locations.length}',
                        label: locations.length == 1 ? 'Sede' : 'Sedes',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (locations.isNotEmpty) ...[
                  Text(
                    'Ubicaciones',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...locations.map((l) => _LocationTile(location: l)),
                  const SizedBox(height: 24),
                ],
                if (myRole != null) ...[
                  Text(
                    'Tu rol',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _roleLabel(myRole),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Organization org,
  ) async {
    final nameCtrl = TextEditingController(text: org.name);
    final descCtrl = TextEditingController(text: org.description ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool loading = false;
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> submit() async {
              setState(() => loading = true);
              try {
                await ref.read(organizationDatasourceProvider).update(org.id, {
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                });
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                setState(() => loading = false);
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Editar box'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved == true) {
      ref.invalidate(organizationDetailProvider(orgId));
      ref.invalidate(myMembershipsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Box actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

String _roleLabel(String role) =>
    const {
      'visitor': 'Visitante',
      'athlete': 'Atleta',
      'coach': 'Coach',
      'box_admin': 'Admin de box',
      'box_owner': 'Propietario',
      'superadmin': 'Superadmin',
    }[role] ??
    role;

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({required this.location});
  final OrganizationLocation location;

  @override
  Widget build(BuildContext context) {
    final parts = [
      location.address,
      location.city,
      location.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (location.isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (parts.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    parts,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                Text(
                  location.timezone,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
