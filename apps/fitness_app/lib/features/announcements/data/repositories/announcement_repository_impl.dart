import 'package:domain_models/domain_models.dart';

import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDatasource _remote;
  AnnouncementRepositoryImpl(this._remote);

  @override
  Future<List<Announcement>> list(String orgId) async {
    final items = await _remote.list(orgId);
    return items.map(Announcement.fromJson).toList();
  }

  @override
  Future<Announcement> create(String orgId, Announcement announcement) async {
    final data = await _remote.create(orgId, announcement.toJson());
    return Announcement.fromJson(data);
  }
}
