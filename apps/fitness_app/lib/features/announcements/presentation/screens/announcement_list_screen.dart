import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/announcement_provider.dart';

class AnnouncementListScreen extends ConsumerWidget {
  const AnnouncementListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementListProvider);
    final org = ref.watch(resolvedAdminOrgProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(28),
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
                        'Comunicados',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.56,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (org != null)
                        Text(
                          org.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/announcements/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: announcements.when(
                data: (list) => list.isEmpty
                    ? _empty(context)
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(announcementListProvider),
                        child: ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            final isDraft = a.publishedAt == null;
                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () =>
                                  context.push('/admin/announcements/${a.id}'),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: a.pinned
                                        ? AppColors.primaryLighter
                                        : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (a.pinned) ...[
                                          Icon(
                                            Icons.push_pin_rounded,
                                            size: 15,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Expanded(
                                          child: Text(
                                            a.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (isDraft)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.badgeBackground,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                    const SizedBox(height: 6),
                                    Text(
                                      a.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${a.author?.displayName ?? ''} · ${DateFormat('d MMM y, h:mm a', 'es').format(a.publishedAt ?? a.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_rounded, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Sin comunicados',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.push('/admin/announcements/new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Crear el primero'),
          ),
        ],
      ),
    );
  }
}
