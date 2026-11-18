import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return NotificationRepositoryImpl(NotificationRemoteDatasource(supabase));
});

final notificationListProvider = FutureProvider<List<NotificationItem>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.list();
});

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  return notifications.where((n) => n.readAt == null).length;
});

final notificationActionsProvider =
    Provider<NotificationActions>((ref) => NotificationActions(ref));

class NotificationActions {
  NotificationActions(this._ref);
  final Ref _ref;

  Future<void> markRead(String id) async {
    await _ref.read(notificationRepositoryProvider).markRead(id);
    _ref.invalidate(notificationListProvider);
  }

  Future<void> markAllRead(List<NotificationItem> items) async {
    final repo = _ref.read(notificationRepositoryProvider);
    for (final n in items.where((n) => n.readAt == null)) {
      await repo.markRead(n.id);
    }
    _ref.invalidate(notificationListProvider);
  }
}
