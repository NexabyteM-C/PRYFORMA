import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remote;
  NotificationRepositoryImpl(this._remote);

  @override
  Future<List<NotificationItem>> list() async {
    final items = await _remote.list();
    return items.map(NotificationItem.fromJson).toList();
  }

  @override
  Future<void> markRead(String id) async {
    await _remote.markRead(id);
  }
}
