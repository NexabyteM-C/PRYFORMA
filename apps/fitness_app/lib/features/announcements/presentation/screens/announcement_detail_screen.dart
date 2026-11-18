import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/announcement_provider.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});
  final String announcementId;

  Future<void> _delete(
      BuildContext context, WidgetRef ref, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Eliminar comunicado'),
        content: Text('¿Eliminar "$title"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text("Eliminar",
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(announcementDatasourceProvider).delete(announcementId);
      ref.invalidate(announcementListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Comunicado eliminado"),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo eliminar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementListProvider);
    final current =
        announcements.valueOrNull?.where((a) => a.id == announcementId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: current == null
            ? null
            : [
                IconButton(
                  tooltip: 'Editar',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () =>
                      context.push('/admin/announcements/$announcementId/edit'),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: () => _delete(context, ref, current.title),
                ),
                const SizedBox(width: 6),
              ],
      ),
      body: announcements.when(
        data: (list) {
          final a = list.where((a) => a.id == announcementId).firstOrNull;
          if (a == null) return const Center(child: Text('No encontrado'));
          final isDraft = a.publishedAt == null;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (a.pinned) ...[
                        Icon(
                          Icons.push_pin_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isDraft)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.badgeBackground,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Borrador',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (a.pinned || isDraft) const SizedBox(height: 10),
                  Text(
                    a.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.48,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${a.author?.displayName ?? ''} · ${DateFormat('d MMM y, h:mm a', 'es').format(a.publishedAt ?? a.createdAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    a.body,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
