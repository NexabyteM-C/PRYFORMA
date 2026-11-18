import 'package:domain_models/domain_models.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({String? displayName, String? avatarUrl});
}
