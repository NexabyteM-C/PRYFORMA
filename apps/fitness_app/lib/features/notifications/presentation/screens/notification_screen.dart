import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  String _relativeEs(DateTime utc) {
    final dt = utc.toLocal();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return DateFormat('d MMM', 'es').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);
    final unread = notifications.valueOrNull
            ?.where((n) => n.readAt == null)
            .isNotEmpty ??
        false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Notificaciones',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          if (unread)
            TextButton(
              onPressed: () => ref
                  .read(notificationActionsProvider)
                  .markAllRead(notifications.value ?? const []),
              child: Text('Marcar todas',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (list) {
          if (list.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final n = list[i];
                final isRead = n.readAt != null;
                return _NotificationTile(
                  notification: n,
                  isRead: isRead,
                  time: _relativeEs(n.createdAt),
                  onTap: isRead
                      ? null
                      : () => ref
                          .read(notificationActionsProvider)
                          .markRead(n.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isRead,
    required this.time,
    required this.onTap,
  });

  final NotificationItem notification;
  final bool isRead;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.surface
              : AppColors.primaryLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6, right: 8),
              decoration: BoxDecoration(
                color: isRead ? Colors.transparent : AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: 8),
                      Text(time,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(n.body,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('No tienes notificaciones',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
