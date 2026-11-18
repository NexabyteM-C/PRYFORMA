import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../organizations/presentation/providers/membership_provider.dart';
import '../providers/profile_provider.dart';
import 'measurements_screen.dart';

const _roleLabels = {
  'visitor': 'Visitante',
  'athlete': 'Atleta',
  'coach': 'Coach',
  'box_admin': 'Admin de box',
  'box_owner': 'Propietario',
  'superadmin': 'Superadministrador',
};

const _experienceLabels = {
  'beginner': 'Principiante',
  'intermediate': 'Intermedio',
  'advanced': 'Avanzado',
  'elite': 'Élite',
};

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final rawProfile = ref.watch(profileRawProvider);
    final memberships = ref.watch(myMembershipsProvider);
    final highestRole = ref.watch(highestRoleProvider);

    final raw = rawProfile.valueOrNull;
    final displayName =
        (raw?['display_name'] as String?) ?? authUser?.displayName ?? 'Atleta';
    final email = (raw?['email'] as String?) ?? authUser?.email ?? '';
    final athlete = raw != null ? athleteProfileFrom(raw) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(profileRawProvider);
            ref.invalidate(myMembershipsProvider);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(displayName,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(email,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(_roleLabels[highestRole] ?? highestRole,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(height: 24),

              // Athlete details
              _SectionLabel('Perfil de atleta'),
              const SizedBox(height: 10),
              _InfoCard(rows: [
                _InfoRow(
                    'Nivel',
                    _experienceLabels[athlete?['experience_level']] ??
                        'No definido'),
                _InfoRow(
                    'Unidad preferida',
                    (athlete?['preferred_unit'] as String?)?.toUpperCase() ??
                        'KG'),
                _InfoRow('Deporte principal',
                    (athlete?['primary_sport'] as String?) ?? 'No definido'),
                _InfoRow('Altura', _fmtHeight(athlete?['height_cm'])),
                _InfoRow('Peso', _fmtWeight(athlete?['weight_kg'])),
              ]),
              const SizedBox(height: 24),

              // Body measurements
              _SectionLabel('Medidas corporales'),
              const SizedBox(height: 10),
              _MeasurementsTeaserCard(
                measurements: ref.watch(measurementsProvider).valueOrNull,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MeasurementsScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Boxes + roles
              _SectionLabel('Mis boxes'),
              const SizedBox(height: 10),
              memberships.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const _InfoCard(rows: [
                  _InfoRow('Error', 'No se pudieron cargar tus boxes'),
                ]),
                data: (list) {
                  if (list.isEmpty) {
                    return _InfoCard(rows: const [
                      _InfoRow('Sin boxes', 'Aún no perteneces a ninguno'),
                    ]);
                  }
                  return Column(
                    children: list.map((m) {
                      final boxName = m.organization?.name ?? 'Box';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.store_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(boxName,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.badgeBackground,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                  _roleLabels[m.role] ?? m.role,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              _SectionLabel('Cuenta'),
              const SizedBox(height: 10),
              _ProfileMenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Editar perfil',
                  onTap: () => context.push('/athlete/profile/edit')),
              _ProfileMenuItem(
                  icon: Icons.store_rounded,
                  label: 'Mis boxes',
                  onTap: () => context.push('/athlete/profile/boxes')),
              _ProfileMenuItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notificaciones',
                  onTap: () =>
                      context.push('/athlete/profile/notifications')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(Icons.logout_rounded,
                      size: 18, color: AppColors.error),
                  label: Text('Cerrar sesión',
                      style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmtHeight(dynamic cm) {
    final v = (cm as num?)?.toDouble();
    if (v == null) return 'No definido';
    return '${v.toStringAsFixed(0)} cm';
  }

  String _fmtWeight(dynamic kg) {
    final v = (kg as num?)?.toDouble();
    if (v == null) return 'No definido';
    return '${v.toStringAsFixed(1)} kg';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: rows),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13.5, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _MeasurementsTeaserCard extends StatelessWidget {
  const _MeasurementsTeaserCard({
    required this.measurements,
    required this.onTap,
  });

  final List<Map<String, dynamic>>? measurements;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // measurements are ordered newest-first by the provider.
    final latest = (measurements != null && measurements!.isNotEmpty)
        ? measurements!.first
        : null;
    final weight = (latest?['weight_kg'] as num?)?.toDouble();
    final waist = (latest?['waist_cm'] as num?)?.toDouble();
    final parts = <String>[
      if (weight != null) 'Peso ${weight.toStringAsFixed(1)} kg',
      if (waist != null) 'Cintura ${waist.toStringAsFixed(1)} cm',
    ];
    final String subtitle;
    if (latest == null) {
      subtitle = 'Registra tu progreso mes a mes';
    } else if (parts.isEmpty) {
      subtitle = 'Ver historial y progreso';
    } else {
      subtitle = parts.join(' · ');
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.straighten_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Medidas antropométricas',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500))),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
