import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/membership_provider.dart';
import '../providers/organization_provider.dart';

const _roleLabels = <String, String>{
  'visitor': 'Visitante',
  'athlete': 'Atleta',
  'coach': 'Coach',
  'box_admin': 'Admin de box',
  'box_owner': 'Propietario',
  'superadmin': 'Superadmin',
};

class MyBoxesScreen extends ConsumerWidget {
  const MyBoxesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberships = ref.watch(myMembershipsProvider);
    final highestRole = ref.watch(highestRoleProvider);
    final canCreate = roleRank(highestRole) >= roleRank('box_owner');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'Mis Boxes',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showJoinDialog(context, ref),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Unirse a un box'),
      ),
      body: memberships.when(
        data: (list) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            children: [
              if (canCreate) ...[
                OutlinedButton.icon(
                  onPressed: () => _showCreateDialog(context, ref),
                  icon: const Icon(Icons.add_business_rounded, size: 18),
                  label: const Text('Crear box'),
                ),
                const SizedBox(height: 16),
              ],
              if (list.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      'No estás vinculado a ningún box',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                ...list.map((m) => _BoxCard(membership: m)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _showJoinDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final joined = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool loading = false;
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> submit() async {
              final code = controller.text.trim();
              if (code.isEmpty) return;
              setState(() => loading = true);
              try {
                await ref.read(organizationDatasourceProvider).join(code);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                setState(() => loading = false);
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: const Text('Código inválido o expirado'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Unirse a un box'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ingresa el código de invitación que te compartió tu box.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      hintText: 'Ej: k3f9x2ab12',
                    ),
                    onSubmitted: (_) => submit(),
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
                      : const Text('Unirse'),
                ),
              ],
            );
          },
        );
      },
    );
    if (joined == true) {
      ref.invalidate(myMembershipsProvider);
      ref.invalidate(myOrganizationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Te has unido al box'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool loading = false;
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            Future<void> submit() async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final slug = name
                  .toLowerCase()
                  .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                  .replaceAll(RegExp(r'(^-+|-+$)'), '');
              setState(() => loading = true);
              try {
                await ref.read(organizationDatasourceProvider).create({
                  'name': name,
                  'slug':
                      '$slug-${DateTime.now().millisecondsSinceEpoch % 10000}',
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
              title: const Text('Crear box'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del box',
                    ),
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
                      : const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
    if (created == true) {
      ref.invalidate(myMembershipsProvider);
      ref.invalidate(myOrganizationsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Box creado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _BoxCard extends StatelessWidget {
  const _BoxCard({required this.membership});
  final OrganizationMember membership;

  @override
  Widget build(BuildContext context) {
    final org = membership.organization;
    final name = org?.name ?? 'Box';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: org == null
            ? null
            : () => context.push('/athlete/profile/box/${org.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _roleLabels[membership.role] ?? membership.role,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
