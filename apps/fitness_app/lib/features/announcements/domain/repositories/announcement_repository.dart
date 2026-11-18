import 'package:domain_models/domain_models.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> list(String orgId);
  Future<Announcement> create(String orgId, Announcement announcement);
}
