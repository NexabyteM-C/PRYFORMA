import 'package:domain_models/domain_models.dart';

abstract class NotificationRepository {
  Future<List<NotificationItem>> list();
  Future<void> markRead(String id);
}
