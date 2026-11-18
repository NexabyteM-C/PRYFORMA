import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../classes/presentation/providers/class_format.dart';
import '../providers/admin_dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => _buildError(ref),
        data: (data) {
          if (data == null) {
            return Center(
              child: Text(
                'No administras ninguna organización todavía.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminDashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.56,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.orgName,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 16.0;
                      final maxW = constraints.maxWidth;
                      // 2-per-row on phones, otherwise fixed 240 cards that
                      // wrap naturally on wider screens.
                      final cardWidth = maxW < 600
                          ? (maxW - spacing) / 2
                          : 240.0;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          _StatCard(
                            width: cardWidth,
                            label: 'Atletas activos',
                            value: '${data.members}',
                            icon: Icons.groups_rounded,
                          ),
                          _StatCard(
                            width: cardWidth,
                            label: 'Publicadas esta semana',
                            value: '${data.publishedThisWeek}',
                            icon: Icons.event_available_rounded,
                          ),
                          _StatCard(
                            width: cardWidth,
                            label: 'Sesiones próximas',
                            value: '${data.upcomingSessions}',
                            icon: Icons.schedule_rounded,
                          ),
                          _StatCard(
                            width: cardWidth,
                            label: 'Borradores',
                            value: '${data.draftPrograms}',
                            icon: Icons.edit_note_rounded,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Sesiones de hoy',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TodaySessions(sessions: data.todaySessions),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 44, color: AppColors.border),
          const SizedBox(height: 12),
          Text('No pudimos cargar el dashboard.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => ref.invalidate(adminDashboardProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _TodaySessions extends StatelessWidget {
  const _TodaySessions({required this.sessions});
  final List<Map<String, dynamic>> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 40, color: AppColors.border),
            const SizedBox(height: 12),
            Text('No hay sesiones programadas para hoy.',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < sessions.length; i++) ...[
          _sessionTile(sessions[i]),
          if (i < sessions.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _sessionTile(Map<String, dynamic> row) {
    final program = (row['program'] as Map?)?.cast<String, dynamic>() ?? {};
    final location = (row['location'] as Map?)?.cast<String, dynamic>() ?? {};
    final title = program['title'] as String? ?? 'Sesión';
    final status = program['status'] as String?;
    final time = formatSessionTime(row['start_time'] as String?);
    final locationName = location['name'] as String?;
    final capacity = row['capacity'];
    final coaches = ((row['coaches'] as List?) ?? const [])
        .map((c) => ((c as Map)['coach'] as Map?)?['display_name'] as String?)
        .whereType<String>()
        .toList();

    final statusColors = {
      'published': AppColors.success,
      'scheduled': AppColors.secondaryAccent,
      'draft': AppColors.textSecondary,
      'cancelled': AppColors.error,
    };
    final statusColor = statusColors[status] ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            alignment: Alignment.center,
            child: Text(
              time,
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: AppColors.border,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(
                  [
                    ?locationName,
                    if (coaches.isNotEmpty) coaches.join(', '),
                    if (capacity != null) '$capacity cupos',
                  ].join(' · '),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _statusLabel(status),
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'published':
        return 'Publicada';
      case 'scheduled':
        return 'Programada';
      case 'draft':
        return 'Borrador';
      case 'cancelled':
        return 'Cancelada';
      default:
        return capitalize(status ?? '-');
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.width = 240,
  });

  final String label;
  final String value;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
