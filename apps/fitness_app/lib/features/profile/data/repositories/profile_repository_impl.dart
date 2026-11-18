import 'package:domain_models/domain_models.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remote;
  ProfileRepositoryImpl(this._remote);

  @override
  Future<User> getProfile() async {
    final data = await _remote.getProfile();
    return User.fromJson(data);
  }

  @override
  Future<User> updateProfile({String? displayName, String? avatarUrl}) async {
    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    final data = await _remote.updateProfile(body);
    return User.fromJson(data);
  }
}
