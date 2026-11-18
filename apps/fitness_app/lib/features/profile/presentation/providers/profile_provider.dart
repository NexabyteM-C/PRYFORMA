import 'package:domain_models/domain_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/networking/supabase_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProfileRepositoryImpl(ProfileRemoteDatasource(supabase));
});

final profileProvider = FutureProvider<User>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});

final profileDatasourceProvider = Provider<ProfileRemoteDatasource>((ref) {
  return ProfileRemoteDatasource(ref.watch(supabaseProvider));
});

/// Raw profile map including the nested `athlete_profiles` join.
final profileRawProvider = FutureProvider<Map<String, dynamic>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(profileDatasourceProvider).getProfile();
});

/// Extracts the single athlete_profiles record from the raw profile map.
Map<String, dynamic>? athleteProfileFrom(Map<String, dynamic> raw) {
  final ap = raw['athlete_profiles'];
  if (ap is List && ap.isNotEmpty) return Map<String, dynamic>.from(ap.first);
  if (ap is Map) return Map<String, dynamic>.from(ap);
  return null;
}

/// All body-measurement records for the current user, newest first.
final measurementsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(profileDatasourceProvider).listMeasurements();
});

final measurementActionsProvider =
    Provider<MeasurementActions>((ref) => MeasurementActions(ref));

class MeasurementActions {
  MeasurementActions(this._ref);
  final Ref _ref;

  Future<void> create(Map<String, dynamic> body) async {
    await _ref.read(profileDatasourceProvider).createMeasurement(body);
    _ref.invalidate(measurementsProvider);
  }

  Future<void> delete(String id) async {
    await _ref.read(profileDatasourceProvider).deleteMeasurement(id);
    _ref.invalidate(measurementsProvider);
  }
}

final profileActionsProvider =
    Provider<ProfileActions>((ref) => ProfileActions(ref));

class ProfileActions {
  ProfileActions(this._ref);
  final Ref _ref;

  Future<void> save({
    required String displayName,
    String? experienceLevel,
    String? preferredUnit,
    String? primarySport,
    double? heightCm,
    double? weightKg,
  }) async {
    final ds = _ref.read(profileDatasourceProvider);
    await ds.updateProfile({'display_name': displayName});
    await ds.updateAthleteProfile({
      'experience_level': experienceLevel,
      'preferred_unit': preferredUnit,
      'primary_sport': primarySport,
      'height_cm': heightCm,
      'weight_kg': weightKg,
    });
    _ref.invalidate(profileRawProvider);
    _ref.invalidate(profileProvider);
    _ref.invalidate(authStateProvider);
  }
}
